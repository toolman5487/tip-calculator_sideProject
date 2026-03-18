//
//  UIBarButtonItem+Factory.swift
//  tip-calculator
//

import UIKit

enum Haptic {
    static func barButtonImpact() {
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
    }
}

extension UIBarButtonItem {

    static func closeButton(action: @escaping () -> Void) -> UIBarButtonItem {
        barButton(systemImage: "xmark", weight: .bold, action: action)
    }

    static func backButton(action: @escaping () -> Void) -> UIBarButtonItem {
        barButton(systemImage: "chevron.left", weight: .bold, action: action)
    }

    static func shareButton(action: @escaping () -> Void) -> UIBarButtonItem {
        barButton(systemImage: "square.and.arrow.up", weight: .bold, action: action)
    }

    static func editButton(action: @escaping () -> Void) -> UIBarButtonItem {
        barButton(systemImage: "slider.horizontal.3", weight: .bold, action: action)
    }

    static func deleteButton(action: @escaping () -> Void) -> UIBarButtonItem {
        barButton(systemImage: "trash", weight: .bold, action: action)
    }

    static func locationButton(action: @escaping () -> Void) -> UIBarButtonItem {
        barButton(systemImage: "location.fill", weight: .medium, action: action)
    }

    static func doneToolbarButton(action: @escaping () -> Void) -> UIBarButtonItem {
        UIBarButtonItem(title: "完成", primaryAction: UIAction { _ in
            Haptic.barButtonImpact()
            action()
        })
    }

    private static func barButton(
        systemImage: String,
        weight: UIImage.SymbolWeight = .bold,
        action: @escaping () -> Void
    ) -> UIBarButtonItem {
        let config = UIImage.SymbolConfiguration(weight: weight)
        let image = UIImage(systemName: systemImage, withConfiguration: config)
        return UIBarButtonItem(image: image, primaryAction: UIAction { _ in
            Haptic.barButtonImpact()
            action()
        })
    }
}
