//
//  CustomTabBarController.swift
//  tip-calculator
//

import Combine
import SnapKit
import UIKit

@MainActor
final class CustomTabBarController: UIViewController {

    // MARK: - Delegate

    weak var delegate: CustomTabBarControllerDelegate?

    // MARK: - View Model & State

    private let viewModel = TabBarViewModel()
    private var cancellables = Set<AnyCancellable>()
    private var lastAppliedTabBarHeight: CGFloat = 0

    // MARK: - View Controller Management

    private var viewControllerFactories: [() -> UIViewController] = []
    private var cachedViewControllers: [Int: UIViewController] = [:]
    private var viewControllerIndex: [ObjectIdentifier: Int] = [:]
    private var currentViewController: UIViewController?

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
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateChildContentInsetIfNeeded()
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

        bindSelectedTab()
    }

    private func bindSelectedTab() {
        viewModel.$selectedTab
            .compactMap { $0 }
            .sink { [weak self] tab in
                guard let self = self,
                      let index = self.viewModel.index(for: tab),
                      let vc = self.getOrCreateViewController(at: index) else { return }
                self.showViewController(vc, animated: self.currentViewController != nil)
            }
            .store(in: &cancellables)
    }

    // MARK: - Public API

    func setViewControllers(factories: [() -> UIViewController], tabBarItems: [TabBarItem], tabTypes: [MainTabBarTab]) {
        viewControllerFactories = factories
        viewModel.configure(with: tabTypes)

        if let initialTab = viewModel.loadInitialTab(validRange: 0 ..< tabTypes.count) {
            viewModel.setSelectedTab(initialTab)
        }
        customTabBar.configure(with: tabBarItems)
    }

    func tabType(at index: Int) -> MainTabBarTab? {
        viewModel.tab(at: index)
    }

    // MARK: - View Controller Lifecycle

    private func getOrCreateViewController(at index: Int) -> UIViewController? {
        if let cachedVC = cachedViewControllers[index] {
            return cachedVC
        }

        guard index >= 0 && index < viewControllerFactories.count else { return nil }
        let factory = viewControllerFactories[index]
        let newVC = factory()
        cachedViewControllers[index] = newVC
        viewControllerIndex[ObjectIdentifier(newVC)] = index

        addChild(newVC)
        containerView.addSubview(newVC.view)
        newVC.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        newVC.didMove(toParent: self)

        newVC.view.isHidden = true
        lastAppliedTabBarHeight = 0
        updateChildContentInsetIfNeeded()

        return newVC
    }

    private func showViewController(_ viewController: UIViewController, animated: Bool = true) {
        guard viewController !== currentViewController else { return }

        let outgoingVC = currentViewController
        currentViewController = viewController

        viewController.view.isHidden = false
        containerView.bringSubviewToFront(viewController.view)

        let incomingIndex = viewControllerIndex[ObjectIdentifier(viewController)]

        if animated,
           let outgoingVC,
           let fromIndex = viewControllerIndex[ObjectIdentifier(outgoingVC)],
           let toIndex = incomingIndex {
            prepareForTransition(outgoing: outgoingVC, incoming: viewController)
            TabBarContentTransition.performSlide(
                from: fromIndex,
                to: toIndex,
                outgoingView: outgoingVC.view,
                incomingView: viewController.view,
                containerWidth: containerView.bounds.width,
                duration: TabBarAppearance.tabTransitionDuration
            ) { [weak self] in
                guard let self else { return }
                guard self.currentViewController === viewController else { return }
                outgoingVC.view.transform = .identity
                self.syncViewVisibilityToCurrent()
                self.notifyDidSelect(viewController: viewController, at: toIndex)
            }
        } else {
            syncViewVisibilityToCurrent()
            if let index = incomingIndex {
                notifyDidSelect(viewController: viewController, at: index)
            }
        }

        if let refreshable = Self.refreshableViewController(from: viewController) {
            refreshable.refreshContent()
        }
    }

    private func syncViewVisibilityToCurrent() {
        guard let current = currentViewController else { return }
        for vc in cachedViewControllers.values {
            vc.viewIfLoaded?.isHidden = (vc !== current)
        }
    }

    private func prepareForTransition(outgoing: UIViewController?, incoming: UIViewController) {
        for vc in cachedViewControllers.values {
            guard let v = vc.viewIfLoaded else { continue }
            let isParticipant = (vc === outgoing || vc === incoming)
            if isParticipant {
                v.layer.removeAllAnimations()
                v.transform = .identity
            }
            v.isHidden = !isParticipant
        }
    }

    func select(tab: MainTabBarTab) {
        guard let index = viewModel.index(for: tab) else { return }
        handleSelection(at: index)
    }

    // MARK: - Layout

    private func updateChildContentInsetIfNeeded() {
        let tabBarHeight = customTabBar.intrinsicContentSize.height
        guard tabBarHeight != lastAppliedTabBarHeight, !cachedViewControllers.isEmpty else { return }
        lastAppliedTabBarHeight = tabBarHeight
        let insets = UIEdgeInsets(top: 0, left: 0, bottom: tabBarHeight, right: 0)
        for vc in cachedViewControllers.values {
            vc.additionalSafeAreaInsets = insets
        }
    }

    // MARK: - Delegate Notification

    private func notifyDidSelect(viewController: UIViewController, at index: Int) {
        delegate?.tabBarController(self, didSelect: viewController, at: index)
    }

    // MARK: - Helpers

    private static func refreshableViewController(from vc: UIViewController) -> TabBarRefreshable? {
        if let refreshable = vc as? TabBarRefreshable { return refreshable }
        if let nav = vc as? UINavigationController, let root = nav.viewControllers.first as? TabBarRefreshable {
            return root
        }
        return nil
    }

    private func popToRootIfNeeded(from viewController: UIViewController) {
        guard let nav = viewController as? UINavigationController, nav.viewControllers.count > 1 else { return }
        nav.popToRootViewController(animated: true)
    }
}

extension CustomTabBarController {
    func focus(on tab: MainTabBarTab) {
        guard let index = viewModel.index(for: tab) else { return }
        handleSelection(at: index)
    }
}

// MARK: - CustomTabBarDelegate

extension CustomTabBarController: CustomTabBarDelegate {
    func didSelectTab(at index: Int) {
        guard delegate?.tabBarController(self, shouldSelectTabAt: index) ?? true else { return }
        handleSelection(at: index)
    }
}

// MARK: - Selection Handling

private extension CustomTabBarController {
    func handleSelection(at index: Int) {
        guard let viewController = getOrCreateViewController(at: index) else { return }

        if index < MainTabBarTab.allCases.count {
            TabBarBadgePublisher.hide(on: MainTabBarTab.allCases[index])
        }

        if viewController === currentViewController {
            popToRootIfNeeded(from: viewController)
            if let refreshable = Self.refreshableViewController(from: viewController) {
                refreshable.refreshContent()
            }
            notifyDidSelect(viewController: viewController, at: index)
            return
        }

        viewModel.selectTab(at: index)
    }
}
