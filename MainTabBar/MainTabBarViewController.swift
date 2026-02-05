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
        let calculator = CalculatorVC()
        calculator.tabBarItem = UITabBarItem(
            title: "Calculator",
            image: UIImage(systemName: "percent"),
            selectedImage: UIImage(systemName: "percent")
        )
        let calculatorNav = NavigationBarAppearance.wrapInNavigationController(rootViewController: calculator)

        let userInfo = MainUserInfoViewController()
        userInfo.tabBarItem = UITabBarItem(
            title: "Profile",
            image: UIImage(systemName: "person.circle"),
            selectedImage: UIImage(systemName: "person.circle.fill")
        )
        let profileNav = NavigationBarAppearance.wrapInNavigationController(rootViewController: userInfo)

        viewControllers = [calculatorNav, profileNav]
    }
}
