//
//  TabBarTypes.swift
//  tip-calculator
//

import UIKit

enum TabBarAppearance {
    static let selectedColor: UIColor = ThemeColor.selected
    static let normalColor: UIColor = .label
    static let separatorColor: UIColor = .separator
    static let selectionScale: CGFloat = 1.1
    static let animationDuration: TimeInterval = 0.2
    static let tabTransitionDuration: TimeInterval = 0.25
    static let pulseScale: CGFloat = 1.15
    static let pulseDuration: TimeInterval = 0.8
}

enum TabBarContentTransition {
    static func performSlide(
        from fromIndex: Int,
        to toIndex: Int,
        outgoingView: UIView,
        incomingView: UIView,
        containerWidth: CGFloat,
        duration: TimeInterval,
        completion: @escaping () -> Void
    ) {
        let slideRight = toIndex > fromIndex

        incomingView.transform = CGAffineTransform(translationX: slideRight ? containerWidth : -containerWidth, y: 0)

        UIView.animate(withDuration: duration, delay: 0, options: [.curveEaseInOut]) {
            outgoingView.transform = CGAffineTransform(translationX: slideRight ? -containerWidth : containerWidth, y: 0)
            incomingView.transform = .identity
        } completion: { _ in
            completion()
        }
    }
}

enum TabBarRestoration {
    private static let selectedIndexKey = "CustomTabBarController.selectedIndex"

    static func loadSelectedIndex(validRange: Range<Int>) -> Int {
        let raw = UserDefaults.standard.integer(forKey: selectedIndexKey)
        return validRange.contains(raw) ? raw : 0
    }

    static func saveSelectedIndex(_ index: Int) {
        UserDefaults.standard.set(index, forKey: selectedIndexKey)
    }
}
