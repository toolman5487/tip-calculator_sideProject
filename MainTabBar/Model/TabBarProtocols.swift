//
//  TabBarProtocols.swift
//  tip-calculator
//

import UIKit

@MainActor
protocol CustomTabBarDelegate: AnyObject {
    func didSelectTab(at index: Int)
}

@MainActor
protocol CustomTabBarControllerDelegate: AnyObject {
    func tabBarController(_ tabBarController: CustomTabBarController, shouldSelectTabAt index: Int) -> Bool
    func tabBarController(_ tabBarController: CustomTabBarController, didSelect viewController: UIViewController, at index: Int)
}

extension CustomTabBarControllerDelegate {
    func tabBarController(_ tabBarController: CustomTabBarController, shouldSelectTabAt index: Int) -> Bool {
        true
    }
}

@MainActor
protocol TabBarRefreshable: AnyObject {
    func refreshContent()
}
