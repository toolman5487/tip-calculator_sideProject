//
//  MainTabBarTab.swift
//  tip-calculator
//

import UIKit

enum MainTabBarTab: CaseIterable {
    case calculator
    case userInfo

    var title: String {
        switch self {
        case .calculator: return "消費計算"
        case .userInfo: return "消費紀錄"
        }
    }

    var image: UIImage? {
        switch self {
        case .calculator: return UIImage(systemName: "square.grid.3x3.fill")
        case .userInfo: return UIImage(systemName: "person.circle")
        }
    }

    var selectedImage: UIImage? {
        switch self {
        case .calculator: return UIImage(systemName: "square.grid.3x3.fill")
        case .userInfo: return UIImage(systemName: "person.circle.fill")
        }
    }

    var viewController: UIViewController {
        switch self {
        case .calculator:
            return NavigationBarAppearance.wrapInNavigationController(rootViewController: CalculatorVC())
        case .userInfo:
            return NavigationBarAppearance.wrapInNavigationController(rootViewController: MainUserInfoViewController())
        }
    }

    var tabBarItem: UITabBarItem {
        UITabBarItem(title: title, image: image, selectedImage: selectedImage)
    }
}
