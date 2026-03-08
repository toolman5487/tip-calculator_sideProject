//
//  TabBarViewModel.swift
//  tip-calculator
//

import Combine
import Foundation

@MainActor
final class TabBarViewModel: ObservableObject {

    // MARK: - Published Properties

    @Published private(set) var tabTypes: [MainTabBarTab] = []
    @Published var selectedTab: MainTabBarTab?

    // MARK: - Private Properties

    private var tabTypeToIndex: [MainTabBarTab: Int] = [:]

    // MARK: - Configuration

    func configure(with tabTypes: [MainTabBarTab]) {
        self.tabTypes = tabTypes
        tabTypeToIndex = Dictionary(uniqueKeysWithValues: tabTypes.enumerated().map { ($0.element, $0.offset) })
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
