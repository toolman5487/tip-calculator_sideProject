//
//  TabBarViewModel.swift
//  tip-calculator
//

import Combine
import Foundation

@MainActor
final class TabBarViewModel: ObservableObject {

    // MARK: - Published Properties

    @Published private(set) var visitedTabs: Set<MainTabBarTab> = []
    @Published private(set) var tabTypes: [MainTabBarTab] = []
    @Published private(set) var notifications: Set<MainTabBarTab> = []
    @Published var selectedTab: MainTabBarTab? {
        didSet {
            guard let selectedTab = selectedTab, selectedTab != oldValue else { return }
            markAsVisited(selectedTab)
            clearNotification(for: selectedTab)
        }
    }

    // MARK: - Private Properties

    private var tabTypeToIndex: [MainTabBarTab: Int] = [:]

    // MARK: - Configuration

    func configure(with tabTypes: [MainTabBarTab]) {
        self.tabTypes = tabTypes
        tabTypeToIndex = Dictionary(uniqueKeysWithValues: tabTypes.enumerated().map { ($0.element, $0.offset) })
        visitedTabs.removeAll()
    }

    // MARK: - Animation State

    private(set) var colorAnimatingTabs: Set<MainTabBarTab> = []

    func startColorAnimation(for tab: MainTabBarTab) {
        colorAnimatingTabs.insert(tab)
    }

    func stopColorAnimation(for tab: MainTabBarTab) {
        colorAnimatingTabs.remove(tab)
    }

    func isColorAnimating(_ tab: MainTabBarTab) -> Bool {
        colorAnimatingTabs.contains(tab)
    }

    func markAsVisited(_ tab: MainTabBarTab) {
        visitedTabs.insert(tab)
    }

    func needsAnimation(at index: Int) -> Bool {
        guard let tab = tab(at: index) else { return false }
        return needsAnimation(for: tab)
    }

    func needsAnimation(for tab: MainTabBarTab) -> Bool {
        if notifications.contains(tab) { return true }

        let item = tab.customTabBarItem
        guard case .animated = item.animationStyle else { return false }
        return !visitedTabs.contains(tab)
    }

    func animationKind(for tab: MainTabBarTab) -> TabBarAnimationKind? {
        let item = tab.customTabBarItem
        guard case .animated(let kind) = item.animationStyle else { return nil }
        return kind
    }

    // MARK: - Notifications

    func setNotification(for tab: MainTabBarTab, hasNotification: Bool) {
        if hasNotification {
            notifications.insert(tab)
        } else {
            notifications.remove(tab)
        }
    }

    func clearNotification(for tab: MainTabBarTab) {
        notifications.remove(tab)
    }

    func clearAllNotifications() {
        notifications.removeAll()
    }

    func resetVisitedState() {
        visitedTabs.removeAll()
    }

    // MARK: - Index Mapping

    func index(for tab: MainTabBarTab) -> Int? {
        tabTypeToIndex[tab]
    }

    func tab(at index: Int) -> MainTabBarTab? {
        guard index >= 0 && index < tabTypes.count else { return nil }
        return tabTypes[index]
    }
}
