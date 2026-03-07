//
//  NavigationBarAppearance.swift
//  tip-calculator
//

import UIKit

enum NavigationBarAppearance {

    static var useLargeTitle = true

    static func apply() {
        let appearance = UINavigationBarAppearance()
        if UIAccessibility.isReduceTransparencyEnabled || infoReduceEffects {
            appearance.configureWithDefaultBackground()
        } else {
            appearance.configureWithTransparentBackground()
            appearance.backgroundColor = .clear
            appearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterial)
        }
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.label]
        appearance.titleTextAttributes = [.foregroundColor: UIColor.label]

        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().tintColor = .label
    }

    private static var infoReduceEffects: Bool {
        (Bundle.main.object(forInfoDictionaryKey: "AppReduceEffects") as? Bool) ?? false
    }

    static func wrapInNavigationController(rootViewController: UIViewController) -> UINavigationController {
        let nav = UINavigationController(rootViewController: rootViewController)
        let respectReduceMotion = UIAccessibility.isReduceMotionEnabled
        let forceReduceFromInfo = infoReduceEffects
        nav.navigationBar.prefersLargeTitles = useLargeTitle && !respectReduceMotion && !forceReduceFromInfo
        return nav
    }
}
