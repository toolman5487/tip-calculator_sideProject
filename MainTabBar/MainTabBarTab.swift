//
//  MainTabBarTab.swift
//  tip-calculator
//

import UIKit

enum MainTabBarTab: CaseIterable {
    case calculator
    case userInfo
    case illustration
    case accountDetail

    var title: String {
        switch self {
        case .calculator: return "消費計算"
        case .userInfo: return "消費紀錄"
        case .illustration: return "統計資料"
        case .accountDetail: return "帳戶"
        }
    }

    var image: UIImage? {
        switch self {
        case .calculator: return UIImage(systemName: "square.grid.3x3.fill")
        case .userInfo: return UIImage(systemName: "list.bullet.rectangle")
        case .illustration: return UIImage(systemName: "chart.bar.xaxis")
        case .accountDetail: return UIImage(systemName: "person.fill")
        }
    }

    var selectedImage: UIImage? {
        switch self {
        case .calculator: return UIImage(systemName: "square.grid.3x3.fill")
        case .userInfo: return UIImage(systemName: "list.bullet.rectangle.fill")
        case .illustration: return UIImage(systemName: "chart.bar.xaxis.ascending")
        case .accountDetail: return UIImage(systemName: "person.fill")
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

    var tabBarItem: UITabBarItem {
        UITabBarItem(title: title, image: image, selectedImage: selectedImage)
    }

    var customTabBarItem: TabBarItem {
        TabBarItem(
            title: title,
            icon: image,
            selectedIcon: selectedImage,
            displayMode: .iconOnly,
            animationStyle: self == .userInfo ? .animated(.pulse) : .none
        )
    }
}
