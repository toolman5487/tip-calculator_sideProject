//
//  MainTabBarTab.swift
//  tip-calculator
//

import UIKit

// MARK: - MainTabBarTab

enum MainTabBarTab: Int, CaseIterable {
    case calculator = 0
    case userInfo = 1
    case illustration = 2
    case accountDetail = 3

    var animationStyle: TabBarAnimationStyle {
        switch self {
        case .userInfo: return .animated(.pulse)
        default: return .none
        }
    }

    var tabItemConfig: TabItemConfig {
        switch self {
        case .calculator:
            return TabItemConfig(
                id: rawValue,
                iconProvider: .sfSymbol("plus.circle.fill"),
                selectedTintColor: TabBarAppearance.selectedColor,
                badgeAnimation: .none,
                preferredIconSize: nil
            )
        case .userInfo:
            return TabItemConfig(
                id: rawValue,
                iconProvider: .sfSymbol("rectangle.stack.fill"),
                selectedTintColor: nil,
                badgeAnimation: .animated(.pulse),
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
        case .accountDetail:
            return TabItemConfig(
                id: rawValue,
                iconProvider: .sfSymbol("square.stack.3d.up.fill"),
                selectedTintColor: nil,
                badgeAnimation: .none,
                preferredIconSize: nil
            )
        }
    }

    var viewController: UIViewController {
        switch self {
        case .calculator:
            return NavigationBarAppearance.wrapInNavigationController(rootViewController: CalculatorVC())
        case .userInfo:
            return NavigationBarAppearance.wrapInNavigationController(rootViewController: MainUserInfoViewController())
        case .illustration:
            return NavigationBarAppearance.wrapInNavigationController(rootViewController: MainIllustrationViewController())
        case .accountDetail:
            return NavigationBarAppearance.wrapInNavigationController(rootViewController: MainAccountDetailViewController())
        }
    }

    var customTabBarItem: TabBarItem {
        TabBarItem(from: tabItemConfig)
    }
}
