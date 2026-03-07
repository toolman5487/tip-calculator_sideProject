//
//  CustomTabBarDelegate.swift
//  tip-calculator
//

import Foundation

@MainActor
protocol CustomTabBarDelegate: AnyObject {
    func didSelectTab(at index: Int)
}
