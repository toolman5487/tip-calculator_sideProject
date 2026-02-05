//
//  NavigationBarAppearance.swift
//  tip-calculator
//

import UIKit

enum NavigationBarAppearance {

    static var useLargeTitle = true

    static func apply() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .systemOrange
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]

        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().tintColor = .white
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
