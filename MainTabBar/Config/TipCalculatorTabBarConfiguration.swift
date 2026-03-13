//
//  TipCalculatorTabBarConfiguration.swift
//  tip-calculator
//

import UIKit

enum TipCalculatorTabBarConfiguration {

    @MainActor
    static func makeTabBarController() -> CustomTabBarController {
        let tabBarController = CustomTabBarController()

        let factories: [() -> UIViewController] = MainTabBarTab.allCases.map { tab in
            { tab.viewController }
        }

        let tabBarItems = MainTabBarTab.allCases.map { $0.customTabBarItem }

        tabBarController.setViewControllers(
            factories: factories,
            tabBarItems: tabBarItems,
            tabTypes: Array(MainTabBarTab.allCases)
        )
        return tabBarController
    }
}
