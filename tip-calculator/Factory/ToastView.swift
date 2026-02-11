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
                     systemImageName: String = "exclamationmark.triangle.fill",
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
        container.layer.cornerRadius = 16
        container.layer.masksToBounds = true

        let imageView = UIImageView()
        imageView.image = UIImage(systemName: systemImageName, withConfiguration: UIImage.SymbolConfiguration(weight: .bold))
        imageView.tintColor = tintColor
        imageView.contentMode = .scaleAspectFit

        let label = UILabel()
        label.text = message
        label.font = ThemeFont.bold(Ofsize: 20)
        label.textColor = ThemeColor.text
        label.textAlignment = .center
        label.numberOfLines = 0

        container.addSubview(imageView)
        container.addSubview(label)

        imageView.snp.makeConstraints { make in
            make.height.width.equalTo(60)
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().inset(16)
        }

        label.snp.makeConstraints { make in
            make.top.equalTo(container.snp.centerY).offset(8)
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().inset(16)
        }

        overlay.addSubview(container)
        container.alpha = 0

        container.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.lessThanOrEqualTo(320)
            make.width.lessThanOrEqualTo(parentView).offset(-40)
            make.width.greaterThanOrEqualTo(200)
            make.leading.greaterThanOrEqualTo(parentView).offset(20)
            make.trailing.lessThanOrEqualTo(parentView).offset(-20)
            make.height.equalTo(container.snp.width)
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

