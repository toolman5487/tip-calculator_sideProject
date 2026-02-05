//
//  ToastView.swift
//  tip-calculator
//
//  Created by Willy Hsu on 2026/2/5.
//

import UIKit
import SnapKit

@MainActor
enum ToastView {

    static func show(message: String,
                     in parentView: UIView,
                     autoDismissAfter seconds: TimeInterval = 1.6,
                     systemImageName: String = "square.and.arrow.down.badge.checkmark",
                     tintColor: UIColor = ThemeColor.primary,
                     completion: (() -> Void)? = nil) {

        let overlay = UIView()
        overlay.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        parentView.addSubview(overlay)
        overlay.alpha = 0
        overlay.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        let container = UIView()
        container.backgroundColor = .white
        container.layer.cornerRadius = 12
        container.layer.masksToBounds = true

        let imageView = UIImageView()
        imageView.image = UIImage(systemName: systemImageName)
        imageView.tintColor = tintColor
        imageView.contentMode = .scaleAspectFit

        let label = UILabel()
        label.text = message
        label.font = ThemeFont.bold(Ofsize: 20)
        label.textColor = ThemeColor.text
        label.textAlignment = .center
        label.numberOfLines = 0

        let stack = UIStackView(arrangedSubviews: [imageView, label])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 12

        container.addSubview(stack)
        stack.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(16)
        }

        imageView.snp.makeConstraints { make in
            make.height.width.equalTo(40)
        }

        overlay.addSubview(container)
        container.alpha = 0

        container.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
            make.leading.greaterThanOrEqualToSuperview().offset(32)
            make.trailing.lessThanOrEqualToSuperview().inset(32)
        }

        UIView.animate(withDuration: 0.25) {
            overlay.alpha = 1
            container.alpha = 1
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            UIView.animate(withDuration: 0.25, animations: {
                overlay.alpha = 0
                container.alpha = 0
            }, completion: { _ in
                container.removeFromSuperview()
                overlay.removeFromSuperview()
                completion?()
            })
        }
    }
}

