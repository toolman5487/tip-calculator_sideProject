//
//  CustomTabBarControllerDelegate.swift
//  tip-calculator
//

import UIKit

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
