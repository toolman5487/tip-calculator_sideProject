//
//  MainTabBarViewController.swift
//  tip-calculator
//
//  Created by Willy Hsu on 2026/2/5.
//

import UIKit

final class MainTabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabs()
    }

    private func setupTabs() {
        tabBar.tintColor = ThemeColor.primary
        let calculator = CalculatorVC()
        calculator.tabBarItem = UITabBarItem(
            title: "消費計算",
            image: UIImage(systemName: "square.grid.3x3.fill"),
            selectedImage: UIImage(systemName: "square.grid.3x3.fill")
        )
        let calculatorNav = NavigationBarAppearance.wrapInNavigationController(rootViewController: calculator)

        let userInfo = MainUserInfoViewController()
        userInfo.tabBarItem = UITabBarItem(
            title: "消費紀錄",
            image: UIImage(systemName: "person.circle"),
            selectedImage: UIImage(systemName: "person.circle.fill")
        )
        let profileNav = NavigationBarAppearance.wrapInNavigationController(rootViewController: userInfo)

        viewControllers = [calculatorNav, profileNav]
    }
}
