//
//  MainTabBarTab.swift
//  tip-calculator
//

import UIKit

// MARK: - MainTabBarTab

enum MainTabBarTab: Int, CaseIterable {
    case accountDetail = 0
    case illustration = 1
    case calculator = 2
    case userInfo = 3
    case setting = 4

    var animationStyle: TabBarAnimationStyle {
        switch self {
        case .accountDetail:
            return .none
        case .illustration:
            return .none
        case .calculator:
            return .none
        case .userInfo:
            return .animated(.pulse)
        case .setting:
            return .none
        }
    }

    var tabItemConfig: TabItemConfig {
        switch self {
        case .accountDetail:
            return TabItemConfig(
                id: rawValue,
                iconProvider: .sfSymbol("square.grid.2x2.fill"),
                selectedTintColor: nil,
                badgeAnimation: .none,
                preferredIconSize: nil
            )
        case .illustration:
            return TabItemConfig(
                id: rawValue,
                iconProvider: .sfSymbol("chart.bar.fill"),
                selectedTintColor: nil,
                badgeAnimation: .none,
                preferredIconSize: nil
            )
        case .calculator:
            return TabItemConfig(
                id: rawValue,
                iconProvider: .sfSymbol("plus.app.fill"),
                selectedTintColor: TabBarAppearance.selectedColor,
                badgeAnimation: .none,
                preferredIconSize: nil
            )
        case .userInfo:
            return TabItemConfig(
                id: rawValue,
                iconProvider: .sfSymbol("square.stack.3d.up.fill"),
                selectedTintColor: nil,
                badgeAnimation: .animated(.pulse),
                preferredIconSize: nil
            )
        case .setting:
            return TabItemConfig(
                id: rawValue,
                iconProvider: .sfSymbol("gearshape.fill"),
                selectedTintColor: TabBarAppearance.selectedColor,
                badgeAnimation: .none,
                preferredIconSize: nil
            )
        }
    }

    var viewController: UIViewController {
        switch self {
        case .accountDetail:
            return NavigationBarAppearance.wrapInNavigationController(
                rootViewController: MainAccountDetailViewController()
            )
        case .illustration:
            return NavigationBarAppearance.wrapInNavigationController(
                rootViewController: MainIllustrationViewController()
            )
        case .calculator:
            return NavigationBarAppearance.wrapInNavigationController(
                rootViewController: CalculatorVC()
            )
        case .userInfo:
            return NavigationBarAppearance.wrapInNavigationController(
                rootViewController: MainUserInfoViewController()
            )
        case .setting:
            return NavigationBarAppearance.wrapInNavigationController(
                rootViewController: MainSettingViewController()
            )
        }
    }

    var customTabBarItem: TabBarItem {
        TabBarItem(from: tabItemConfig)
    }
}
