//
//  ToastView.swift
//  tip-calculator
//
//  Created by Willy Hsu on 2026/3/5.
//

import SnapKit
import UIKit

private final class ToastCapsuleView: UIView {
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = min(bounds.width, bounds.height) / 2
    }
}

enum ToastView {

    enum Position {
        case top(offset: CGFloat)
        case center
        case bottom(offset: CGFloat)

        static var top: Position { .top(offset: 80) }
        static var bottom: Position { .bottom(offset: 80) }
    }
}

// MARK: - UIView + Toast

extension UIView {

    @MainActor
    func showToast(message: String) {
        showToast(message: message, position: .center, displayDuration: 3, completion: nil)
    }

    @MainActor
    func showToast(
        message: String,
        position: ToastView.Position,
        displayDuration: TimeInterval = 3,
        completion: (() -> Void)? = nil
    ) {
        let container = ToastCapsuleView()
        container.clipsToBounds = true
        container.backgroundColor = .clear
        addSubview(container)

        let blurView: UIVisualEffectView = {
            let effect = UIBlurEffect(style: .systemUltraThinMaterial)
            let v = UIVisualEffectView(effect: effect)
            v.alpha = 0.9
            return v
        }()
        container.addSubview(blurView)

        let label: UILabel = {
            let l = UILabel()
            l.text = message
            l.font = .preferredFont(forTextStyle: .title3)
            l.textColor = .secondaryLabel
            l.textAlignment = .center
            l.numberOfLines = 1
            l.backgroundColor = .clear
            return l
        }()
        container.addSubview(label)

        blurView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        label.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16))
        }
        switch position {
        case .top(let offset):
            container.snp.makeConstraints { make in
                make.centerX.equalToSuperview()
                make.top.equalTo(self.safeAreaLayoutGuide).offset(offset)
                make.leading.greaterThanOrEqualTo(self).offset(24)
                make.trailing.lessThanOrEqualTo(self).offset(-24)
            }
        case .center:
            container.snp.makeConstraints { make in
                make.center.equalToSuperview()
                make.leading.greaterThanOrEqualTo(self).offset(24)
                make.trailing.lessThanOrEqualTo(self).offset(-24)
            }
        case .bottom(let offset):
            container.snp.makeConstraints { make in
                make.centerX.equalToSuperview()
                make.bottom.equalTo(self.safeAreaLayoutGuide).offset(-offset)
                make.leading.greaterThanOrEqualTo(self).offset(24)
                make.trailing.lessThanOrEqualTo(self).offset(-24)
            }
        }

        container.alpha = 0
        UIView.animate(withDuration: 0.2) {
            container.alpha = 1
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + displayDuration) {
            UIView.animate(withDuration: 0.2, animations: {
                container.alpha = 0
            }, completion: { _ in
                container.removeFromSuperview()
                completion?()
            })
        }
    }
}
