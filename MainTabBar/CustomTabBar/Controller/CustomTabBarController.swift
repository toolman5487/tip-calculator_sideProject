//
//  CustomTabBarController.swift
//  tip-calculator
//

import Combine
import SnapKit
import UIKit

@MainActor
final class CustomTabBarController: UIViewController {

    // MARK: - Properties

    private let viewModel = TabBarViewModel()

    private var viewControllerFactories: [() -> UIViewController] = []

    private var cachedViewControllers: [Int: UIViewController] = [:]

    private var currentViewController: UIViewController?

    private var cancellables = Set<AnyCancellable>()

    // MARK: - UI Components

    private(set) var customTabBar: CustomTabBar = {
        let tabBar = CustomTabBar()
        return tabBar
    }()

    private let containerView: UIView = {
        let view = UIView()
        return view
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBadgeBinding()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.bringSubviewToFront(customTabBar)
        updateChildContentInset()
    }

    private func updateChildContentInset() {
        let tabBarHeight = customTabBar.intrinsicContentSize.height
        cachedViewControllers.values.forEach { vc in
            vc.additionalSafeAreaInsets = UIEdgeInsets(top: 0, left: 0, bottom: tabBarHeight, right: 0)
        }
    }

    // MARK: - Setup

    private func setupUI() {
        view.backgroundColor = .clear

        view.addSubview(containerView)
        view.addSubview(customTabBar)

        customTabBar.delegate = self
        customTabBar.viewModel = viewModel

        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        customTabBar.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
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
        guard let index = MainTabBarTab.allCases.firstIndex(of: tab) else { return }
        viewModel.setNotification(for: tab, hasNotification: count > 0)
        customTabBar.updateBadge(count: count, at: index)
    }

    // MARK: - Public Methods

    func setViewControllers(factories: [() -> UIViewController], tabBarItems: [TabBarItem], tabTypes: [MainTabBarTab]) {
        viewControllerFactories = factories
        viewModel.configure(with: tabTypes)
        customTabBar.configure(with: tabBarItems)

        if let firstTab = tabTypes.first {
            viewModel.selectedTab = firstTab

            if let firstVC = getOrCreateViewController(at: 0) {
                showViewController(firstVC)
            }
        }
    }

    // MARK: - Private Methods

    private func getOrCreateViewController(at index: Int) -> UIViewController? {
        if let cachedVC = cachedViewControllers[index] {
            return cachedVC
        }

        guard index >= 0 && index < viewControllerFactories.count else { return nil }
        let factory = viewControllerFactories[index]
        let newVC = factory()
        cachedViewControllers[index] = newVC

        addChild(newVC)
        containerView.addSubview(newVC.view)
        newVC.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        newVC.didMove(toParent: self)

        newVC.view.isHidden = true
        updateChildContentInset()

        return newVC
    }

    private func showViewController(_ viewController: UIViewController) {
        guard viewController !== currentViewController else { return }

        currentViewController?.view.isHidden = true

        viewController.view.isHidden = false
        containerView.bringSubviewToFront(viewController.view)

        currentViewController = viewController

        if let refreshable = Self.refreshableViewController(from: viewController) {
            refreshable.refreshContent()
        }
    }

    private static func refreshableViewController(from vc: UIViewController) -> TabBarRefreshable? {
        if let refreshable = vc as? TabBarRefreshable { return refreshable }
        if let nav = vc as? UINavigationController, let root = nav.viewControllers.first as? TabBarRefreshable {
            return root
        }
        return nil
    }
}

// MARK: - CustomTabBarDelegate

extension CustomTabBarController: CustomTabBarDelegate {
    func didSelectTab(at index: Int) {
        guard let viewController = getOrCreateViewController(at: index) else { return }

        if index < MainTabBarTab.allCases.count {
            TabBarBadgePublisher.hide(on: MainTabBarTab.allCases[index])
        }

        if viewController === currentViewController {
            if let refreshable = Self.refreshableViewController(from: viewController) {
                refreshable.refreshContent()
            }
            return
        }

        showViewController(viewController)
        customTabBar.selectTab(at: index)
    }
}

// MARK: - TabBarRefreshable Protocol

@MainActor
protocol TabBarRefreshable {
    func refreshContent()
}
