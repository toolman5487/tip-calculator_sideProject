//
//  TabBarBadgePublisher.swift
//  tip-calculator
//

import Combine
import Foundation

enum TabBarBadgePublisher {
    private static let subject = PassthroughSubject<(MainTabBarTab, Int), Never>()
    private static var newCounts: [MainTabBarTab: Int] = [:]

    static var updates: AnyPublisher<(MainTabBarTab, Int), Never> {
        subject.eraseToAnyPublisher()
    }

    static func showCount(_ count: Int, on tab: MainTabBarTab) {
        let value = max(0, min(count, 99))
        newCounts[tab] = value
        subject.send((tab, value))
    }

    static func increment(on tab: MainTabBarTab) {
        let current = newCounts[tab] ?? 0
        let next = min(current + 1, 99)
        newCounts[tab] = next
        subject.send((tab, next))
    }

    static func hide(on tab: MainTabBarTab) {
        newCounts[tab] = 0
        subject.send((tab, 0))
    }
}

typealias TabBarBadgeNotification = TabBarBadgePublisher
