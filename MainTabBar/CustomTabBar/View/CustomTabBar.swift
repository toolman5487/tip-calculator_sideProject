//
//  CustomTabBar.swift
//  tip-calculator
//

import Combine
import SnapKit
import UIKit

@MainActor
final class CustomTabBar: UIView {

    // MARK: - Properties

    weak var delegate: CustomTabBarDelegate?

    var viewModel: TabBarViewModel? {
        didSet { bindViewModel() }
    }

    private var cancellables = Set<AnyCancellable>()

    private var items: [TabBarItem] = []

    private var selectedIndex: Int = 0 {
        didSet {
            guard selectedIndex != oldValue else { return }
            updateSelection(from: oldValue, to: selectedIndex)
        }
    }

    private(set) var customHeight: CGFloat = 49 {
        didSet {
            guard customHeight != oldValue else { return }
            invalidateIntrinsicContentSize()
        }
    }

    private var pulseAnimationKeys: [Int: String] = [:]

    private lazy var feedbackGenerator: UIImpactFeedbackGenerator = {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        return generator
    }()

    override var intrinsicContentSize: CGSize {
        CGSize(width: UIView.noIntrinsicMetric, height: customHeight + safeAreaInsets.bottom)
    }

    // MARK: - UI Components

    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.alignment = .fill
        stack.spacing = 4
        return stack
    }()

    private let backgroundView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .systemUltraThinMaterialLight)
        let view = UIVisualEffectView(effect: blurEffect)
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return view
    }()

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        isOpaque = false
        backgroundColor = .clear
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        isOpaque = false
        backgroundColor = .clear
        setupUI()
    }

    override func safeAreaInsetsDidChange() {
        super.safeAreaInsetsDidChange()
        invalidateIntrinsicContentSize()
    }

    // MARK: - Setup

    private func bindViewModel() {
        cancellables.removeAll()

        guard let viewModel = viewModel else { return }

        bindBadgePublisher()

        viewModel.$selectedTab
            .compactMap { $0 }
            .sink { [weak self] tab in
                guard let self = self,
                      let index = self.viewModel?.index(for: tab),
                      index != self.selectedIndex else { return }
                self.selectedIndex = index
            }
            .store(in: &cancellables)
    }

    private func bindBadgePublisher() {
        TabBarBadgePublisher.updates
            .sink { [weak self] tab, count in
                guard let self else { return }
                let index = self.viewModel?.index(for: tab) ?? -1
                guard index >= 0, index < self.stackView.arrangedSubviews.count else { return }
                let container = self.stackView.arrangedSubviews[index]
                guard let button = container.subviews.compactMap({ $0 as? UIButton }).first else { return }
                self.updateBadge(count: count, at: index)
                if count > 0, case .animated(let kind) = tab.customTabBarItem.animationStyle {
                    self.startAnimation(for: kind, on: button, at: index)
                } else {
                    self.stopAnimation(on: button, at: index)
                }
            }
            .store(in: &cancellables)
    }

    private func setupUI() {
        backgroundColor = .clear

        addSubview(backgroundView)
        addSubview(stackView)

        backgroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        stackView.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide.snp.top).offset(8)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(safeAreaLayoutGuide.snp.bottom).offset(-8)
        }

        let borderView = UIView()
        borderView.backgroundColor = TabBarAppearance.separatorColor
        addSubview(borderView)
        borderView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(0.5)
        }
    }

    // MARK: - Public Methods

    func configure(with items: [TabBarItem]) {
        guard self.items != items else { return }

        let oldCount = self.items.count
        self.items = items

        if oldCount == items.count && oldCount > 0 {
            items.enumerated().forEach { index, item in
                guard index < stackView.arrangedSubviews.count else { return }
                let container = stackView.arrangedSubviews[index]
                guard let button = container.subviews.compactMap({ $0 as? UIButton }).first else { return }
                updateButton(button, with: item, at: index)
            }
        } else {
            stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
            items.enumerated().forEach { index, item in
                let container = createTabItemContainer(for: item, at: index)
                stackView.addArrangedSubview(container)
            }
        }

        if selectedIndex >= items.count {
            selectedIndex = 0
            if let tab = viewModel?.tab(at: 0) {
                viewModel?.setSelectedTab(tab)
            }
        } else {
            updateSelection(from: -1, to: selectedIndex)
        }

    }

    private func updateButton(_ button: UIButton, with item: TabBarItem, at index: Int) {
        button.tag = index
        var config = button.configuration ?? UIButton.Configuration.plain()
        config.image = item.icon
        if item.displayMode == .iconWithText {
            config.title = item.title
        }
        button.configuration = config
    }

    // MARK: - Badge

    private enum BadgeConstants {
        static let tag = 999
    }

    func updateBadge(count: Int, at index: Int) {
        guard index >= 0 && index < stackView.arrangedSubviews.count else { return }
        let container = stackView.arrangedSubviews[index]
        guard let button = container.subviews.compactMap({ $0 as? UIButton }).first,
              let imageView = button.imageView else { return }

        let badgeLabel: UILabel = {
            if let existing = container.viewWithTag(BadgeConstants.tag) as? UILabel {
                return existing
            }
            let label = UILabel()
            label.tag = BadgeConstants.tag
            label.backgroundColor = .systemRed
            label.textColor = .systemBackground
            label.font = .systemFont(ofSize: 12, weight: .bold)
            label.textAlignment = .center
            label.layer.cornerRadius = 8
            label.clipsToBounds = true
            container.addSubview(label)
            label.snp.makeConstraints { make in
                make.centerX.equalTo(imageView.snp.trailing)
                make.centerY.equalTo(imageView.snp.top)
                make.width.height.greaterThanOrEqualTo(16)
            }
            return label
        }()

        if count > 0 {
            badgeLabel.text = count > 99 ? "99+" : "\(count)"
            badgeLabel.isHidden = false
        } else {
            badgeLabel.isHidden = true
        }
    }

    // MARK: - Private Methods

    private func createTabItemContainer(for item: TabBarItem, at index: Int) -> UIView {
        let container = UIView()
        container.backgroundColor = .clear

        let button = createTabButton(for: item, at: index)
        container.addSubview(button)
        button.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        return container
    }

    private func createTabButton(for item: TabBarItem, at index: Int) -> UIButton {
        var configuration = UIButton.Configuration.plain()
        configuration.imagePlacement = .top
        configuration.imagePadding = 4
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)
        configuration.background.backgroundColor = .clear

        let button = UIButton(configuration: configuration)
        button.tag = index
        button.addTarget(self, action: #selector(tabButtonTapped(_:)), for: .touchUpInside)

        let attributedTitle: AttributedString? = {
            guard item.displayMode == .iconWithText else { return nil }
            var attributed = AttributedString(item.title)
            attributed.font = .preferredFont(forTextStyle: .caption1)
            return attributed
        }()

        switch item.displayMode {
        case .iconOnly:
            configuration.image = item.icon
            configuration.title = nil
        case .iconWithText:
            configuration.image = item.icon
            configuration.title = item.title
            if let attributed = attributedTitle {
                configuration.attributedTitle = attributed
            }
        }

        configuration.baseForegroundColor = TabBarAppearance.normalColor
        button.configuration = configuration

        button.configurationUpdateHandler = { btn in
            var config = btn.configuration
            let isSelected = btn.isSelected
            config?.image = isSelected ? (item.selectedIcon ?? item.icon) : item.icon
            config?.baseForegroundColor = isSelected ? TabBarAppearance.selectedColor : TabBarAppearance.normalColor
            config?.background.backgroundColor = .clear
            btn.configuration = config
        }

        return button
    }

    @objc private func tabButtonTapped(_ sender: UIButton) {
        delegate?.didSelectTab(at: sender.tag)
        feedbackGenerator.impactOccurred()
    }

    private func updateSelection(from oldIndex: Int, to newIndex: Int) {
        let duration = TabBarAppearance.animationDuration
        let scale = TabBarAppearance.selectionScale

        UIView.animate(withDuration: duration, delay: 0, options: [.allowUserInteraction, .beginFromCurrentState]) {
            for (index, container) in self.stackView.arrangedSubviews.enumerated() {
                guard let button = container.subviews.compactMap({ $0 as? UIButton }).first else { continue }
                let shouldBeSelected = (index == newIndex)
                guard button.isSelected != shouldBeSelected else { continue }

                button.isSelected = shouldBeSelected
                button.transform = shouldBeSelected ? CGAffineTransform(scaleX: scale, y: scale) : .identity
            }
        } completion: { [weak self] _ in
            guard let self else { return }
            if newIndex >= 0 && newIndex < self.stackView.arrangedSubviews.count {
                let container = self.stackView.arrangedSubviews[newIndex]
                if let button = container.subviews.compactMap({ $0 as? UIButton }).first {
                    self.stopAnimation(on: button, at: newIndex)
                }
            }
        }
    }

    private func startContinuousPulseAnimation(on button: UIButton, at index: Int) {
        guard pulseAnimationKeys[index] == nil else { return }
        stopContinuousColorChangeAnimation(on: button, at: index)

        let animationKey = "continuousPulse_\(index)"
        pulseAnimationKeys[index] = animationKey

        let pulseAnimation = CABasicAnimation(keyPath: "transform.scale")
        pulseAnimation.fromValue = 1.0
        pulseAnimation.toValue = TabBarAppearance.pulseScale
        pulseAnimation.duration = TabBarAppearance.pulseDuration
        pulseAnimation.autoreverses = true
        pulseAnimation.repeatCount = .greatestFiniteMagnitude
        pulseAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)

        button.layer.add(pulseAnimation, forKey: animationKey)
    }

    private func stopContinuousPulseAnimation(on button: UIButton, at index: Int) {
        guard let animationKey = pulseAnimationKeys.removeValue(forKey: index) else { return }
        button.layer.removeAnimation(forKey: animationKey)
    }

    private func startContinuousColorChangeAnimation(on button: UIButton, at index: Int) {
        stopContinuousPulseAnimation(on: button, at: index)
        button.layer.removeAllAnimations()
        button.setNeedsUpdateConfiguration()
    }

    private func stopContinuousColorChangeAnimation(on button: UIButton, at index: Int) {
        button.setNeedsUpdateConfiguration()
        button.layer.removeAllAnimations()
    }

    private func startAnimation(for kind: TabBarAnimationKind, on button: UIButton, at index: Int) {
        switch kind {
        case .pulse:
            startContinuousPulseAnimation(on: button, at: index)
        case .colorChange:
            startContinuousColorChangeAnimation(on: button, at: index)
        }
    }

    private func stopAnimation(on button: UIButton, at index: Int) {
        pulseAnimationKeys.removeValue(forKey: index)
        button.layer.removeAllAnimations()
        button.setNeedsUpdateConfiguration()
    }

}
