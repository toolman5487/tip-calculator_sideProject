//
//  TabBarRestoration.swift
//  tip-calculator
//

import Foundation

enum TabBarRestoration {
    private static let selectedIndexKey = "CustomTabBarController.selectedIndex"

    static func loadSelectedIndex(validRange: Range<Int>) -> Int {
        let raw = UserDefaults.standard.integer(forKey: selectedIndexKey)
        return validRange.contains(raw) ? raw : 0
    }

    static func saveSelectedIndex(_ index: Int) {
        UserDefaults.standard.set(index, forKey: selectedIndexKey)
    }
}
