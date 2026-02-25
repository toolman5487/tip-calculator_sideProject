//
//  RefreshBarButton.swift
//  tip-calculator
//

import UIKit

extension UIBarButtonItem {
    static func refreshBarButton(
        onTap: @escaping () -> Void,
        debounceInterval: TimeInterval = 0.8,
        accessibilityIdentifier: String? = nil
    ) -> UIBarButtonItem {
        let button = RefreshBarButton(debounceInterval: debounceInterval)
        button.onTap = onTap
        button.accessibilityIdentifier = accessibilityIdentifier
        return UIBarButtonItem(customView: button)
    }
}

final class RefreshBarButton: UIButton {

    var onTap: (() -> Void)?

    private let debounceInterval: TimeInterval
    private var lastTapTime: TimeInterval = 0

    private enum Constant {
        static let rotationDuration: CFTimeInterval = 0.4
        static let rotationKey = "rotation"
    }

    init(frame: CGRect = .zero, debounceInterval: TimeInterval = 0.5) {
        self.debounceInterval = debounceInterval
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        self.debounceInterval = 0.5
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        let config = UIImage.SymbolConfiguration(weight: .bold)
        setImage(UIImage(systemName: "arrow.clockwise", withConfiguration: config), for: .normal)
        addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
    }

    @objc private func buttonTapped() {
        if debounceInterval > 0 {
            let now = CACurrentMediaTime()
            guard now - lastTapTime >= debounceInterval else { return }
            lastTapTime = now
        }

        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        addRotationAnimation()
        onTap?()
    }

    private func addRotationAnimation() {
        let rotation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotation.fromValue = 0
        rotation.toValue = CGFloat.pi * 2
        rotation.duration = Constant.rotationDuration
        rotation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        layer.add(rotation, forKey: Constant.rotationKey)
    }
}
