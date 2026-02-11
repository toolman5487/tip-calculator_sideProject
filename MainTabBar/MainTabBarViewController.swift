//
//  MainTabBarViewController.swift
//  tip-calculator
//
//  Created by Willy Hsu on 2026/2/5.
//

import Combine
import UIKit

@MainActor
final class MainTabBarViewController: UITabBarController {

    private var cancellables = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        delegate = self
        setupTabs()
        setupBadgeBinding()
    }

    private func setupTabs() {
        tabBar.tintColor = ThemeColor.primary
        viewControllers = MainTabBarTab.allCases.map { tab in
            let vc = tab.viewController
            vc.tabBarItem = tab.tabBarItem
            return vc
        }
    }

    private func setupBadgeBinding() {
        TabBarBadgePublisher.updates
            .receive(on: DispatchQueue.main)
            .sink { [weak self] tab, count in
                self?.updateBadge(count: count, on: tab)
            }
            .store(in: &cancellables)
    }

    private func updateBadge(count: Int, on tab: MainTabBarTab) {
        guard let index = MainTabBarTab.allCases.firstIndex(of: tab),
              index < (viewControllers?.count ?? 0),
              let vc = viewControllers?[index] else { return }
        vc.tabBarItem.badgeValue = count > 0 ? "\(count)" : nil
    }

    private func clearBadge(on tab: MainTabBarTab) {
        TabBarBadgePublisher.hide(on: tab)
    }
}

// MARK: - UITabBarControllerDelegate

extension MainTabBarViewController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if let index = viewControllers?.firstIndex(of: viewController),
           index < MainTabBarTab.allCases.count {
            clearBadge(on: MainTabBarTab.allCases[index])
        }
    }
}
