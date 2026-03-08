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
        didSet {
            bindViewModel()
            if let viewModel = viewModel,
               let tab = viewModel.tab(at: selectedIndex) {
                viewModel.selectedTab = tab
            }
        }
    }

    private var cancellables = Set<AnyCancellable>()

    private var items: [TabBarItem] = []
    private var selectedIndex: Int = 0 {
        didSet {
            guard selectedIndex != oldValue else { return }
            if let viewModel = viewModel,
               let tab = viewModel.tab(at: selectedIndex) {
                viewModel.selectedTab = tab
            }
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
        let blurEffect = UIBlurEffect(style: .systemMaterial)
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
            .dropFirst()
            .sink { [weak self] tab in
                guard let self = self,
                      let tab = tab,
                      let index = self.viewModel?.index(for: tab),
                      index != self.selectedIndex else { return }
                self.selectedIndex = index
            }
            .store(in: &cancellables)
    }

    private func bindBadgePublisher() {
        TabBarBadgePublisher.updates
            .receive(on: DispatchQueue.main)
            .sink { [weak self] tab, count in
                guard let self else { return }
                let index = MainTabBarTab.allCases.firstIndex(of: tab) ?? -1
                guard index >= 0, index < self.stackView.arrangedSubviews.count,
                      let button = self.stackView.arrangedSubviews[index] as? UIButton else { return }
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
                guard index < stackView.arrangedSubviews.count,
                      let button = stackView.arrangedSubviews[index] as? UIButton else { return }
                updateButton(button, with: item, at: index)
            }
        } else {
            stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
            items.enumerated().forEach { index, item in
                let button = createTabButton(for: item, at: index)
                stackView.addArrangedSubview(button)
            }
        }

        if selectedIndex >= items.count {
            selectedIndex = 0
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

    func selectTab(at index: Int) {
        guard index >= 0 && index < items.count else { return }
        selectedIndex = index
    }


    // MARK: - Badge

    func updateBadge(count: Int, at index: Int) {
        guard index >= 0 && index < stackView.arrangedSubviews.count,
              let button = stackView.arrangedSubviews[index] as? UIButton,
              let imageView = button.imageView else { return }

        let badgeLabel: UILabel = {
            if let existing = button.viewWithTag(999) as? UILabel {
                return existing
            }
            let label = UILabel()
            label.tag = 999
            label.backgroundColor = .systemRed
            label.textColor = .white
            label.font = .systemFont(ofSize: 10, weight: .bold)
            label.textAlignment = .center
            label.layer.cornerRadius = 8
            label.clipsToBounds = true
            button.addSubview(label)
            return label
        }()

        badgeLabel.snp.remakeConstraints { make in
            make.centerX.equalTo(imageView.snp.trailing)
            make.centerY.equalTo(imageView.snp.top)
            make.width.height.greaterThanOrEqualTo(16)
        }

        if count > 0 {
            badgeLabel.text = count > 99 ? "99+" : "\(count)"
            badgeLabel.isHidden = false
        } else {
            badgeLabel.isHidden = true
        }
    }

    // MARK: - Private Methods

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
        let index = sender.tag
        delegate?.didSelectTab(at: index)
        feedbackGenerator.impactOccurred()

        guard index != selectedIndex else { return }
        selectedIndex = index
    }

    private func updateSelection(from oldIndex: Int, to newIndex: Int) {
        CATransaction.begin()
        CATransaction.setAnimationDuration(TabBarAppearance.animationDuration)
        CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(name: .easeInEaseOut))

        stackView.arrangedSubviews.enumerated().forEach { index, subview in
            guard let button = subview as? UIButton else { return }
            let shouldBeSelected = (index == newIndex)

            guard button.isSelected != shouldBeSelected else { return }

            button.isSelected = shouldBeSelected

            UIView.animate(withDuration: TabBarAppearance.animationDuration, delay: 0, options: [.allowUserInteraction, .beginFromCurrentState]) {
                let scale = TabBarAppearance.selectionScale
                button.transform = shouldBeSelected
                    ? CGAffineTransform(scaleX: scale, y: scale)
                    : .identity
            }

            if shouldBeSelected {
                stopAnimation(on: button, at: index)
            }
        }

        CATransaction.commit()
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
        stopContinuousPulseAnimation(on: button, at: index)
        stopContinuousColorChangeAnimation(on: button, at: index)
    }

}
