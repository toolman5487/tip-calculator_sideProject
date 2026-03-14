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
    private var pulseAnimationKeys: [Int: String] = [:]

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
                guard let self,
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
                self.updateBadge(count: count, at: index)
                guard let iconView = container.viewWithTag(IconTag.value) else { return }
                if count > 0, case .animated(let kind) = tab.animationStyle {
                    self.startAnimation(for: kind, on: iconView, at: index)
                } else {
                    self.stopAnimation(on: iconView, at: index)
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
            make.top.equalTo(safeAreaLayoutGuide.snp.top).offset(4)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(safeAreaLayoutGuide.snp.bottom).inset(4)
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
        self.items = items
        customHeight = 49
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        items.enumerated().forEach { index, item in
            stackView.addArrangedSubview(createContainer(for: item, at: index))
        }
        let initialIndex = selectedIndex < items.count ? selectedIndex : 0
        selectedIndex = initialIndex
        applySelectionWithoutAnimation(at: initialIndex)
    }

    private func applySelectionWithoutAnimation(at index: Int) {
        for (i, container) in stackView.arrangedSubviews.enumerated() {
            guard i < items.count else { break }
            let isSelected = (i == index)
            guard let iconView = container.viewWithTag(IconTag.value),
                  let button = container.subviews.first(where: { $0 is UIButton }) as? UIButton else { continue }
            let tintColor = items[i].selectedTintColor ?? TabBarAppearance.selectedColor
            items[i].iconProvider.applySelection(to: iconView, isSelected: isSelected, tintColor: tintColor)
            button.isSelected = isSelected
            iconView.transform = isSelected ? CGAffineTransform(scaleX: TabBarAppearance.selectionScale, y: TabBarAppearance.selectionScale) : .identity
        }
    }

    // MARK: - Badge

    private enum BadgeTag { static let value = 999 }
    private enum IconTag { static let value = 997 }

    func updateBadge(count: Int, at index: Int) {
        guard index >= 0, index < stackView.arrangedSubviews.count else { return }
        let container = stackView.arrangedSubviews[index]
        guard let iconView = container.viewWithTag(IconTag.value) else { return }

        let badge: UILabel = {
            if let existing = container.viewWithTag(BadgeTag.value) as? UILabel { return existing }
            let label = UILabel()
            label.tag = BadgeTag.value
            label.backgroundColor = .systemRed
            label.textColor = .systemBackground
            label.font = .systemFont(ofSize: 12, weight: .bold)
            label.textAlignment = .center
            label.layer.cornerRadius = 6
            label.clipsToBounds = true
            container.addSubview(label)
            label.snp.makeConstraints { make in
                make.centerX.equalTo(iconView.snp.trailing)
                make.centerY.equalTo(iconView.snp.bottom)
                make.width.height.greaterThanOrEqualTo(12)
            }
            return label
        }()

        badge.text = count > 99 ? "99+" : "\(count)"
        badge.isHidden = count <= 0
    }

    // MARK: - Private Methods

    private func createContainer(for item: TabBarItem, at index: Int) -> UIView {
        let container = UIView()
        container.backgroundColor = .clear

        let button = makeTapButton(at: index)
        container.addSubview(button)
        button.snp.makeConstraints { make in make.edges.equalToSuperview() }

        let iconView = item.iconProvider.makeView()
        iconView.tag = IconTag.value
        iconView.isUserInteractionEnabled = false
        container.addSubview(iconView)
        let iconSize = item.preferredIconSize ?? 28
        iconView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(iconSize)
        }

        let tintColor = item.selectedTintColor ?? TabBarAppearance.selectedColor
        item.iconProvider.applySelection(to: iconView, isSelected: false, tintColor: tintColor)

        return container
    }

    private func makeTapButton(at index: Int) -> UIButton {
        var configuration = UIButton.Configuration.plain()
        configuration.background.backgroundColor = .clear
        let button = UIButton(configuration: configuration)
        button.tag = index
        button.addTarget(self, action: #selector(tabButtonTapped(_:)), for: .touchUpInside)
        return button
    }

    @objc private func tabButtonTapped(_ sender: UIButton) {
        delegate?.didSelectTab(at: sender.tag)
        feedbackGenerator.impactOccurred()
        feedbackGenerator.prepare()
    }

    private func updateSelection(from oldIndex: Int, to newIndex: Int) {
        let duration = TabBarAppearance.animationDuration
        let scale = TabBarAppearance.selectionScale
        let indicesToUpdate = Set([oldIndex, newIndex]).filter { $0 >= 0 && $0 < items.count }

        for index in indicesToUpdate {
            let container = stackView.arrangedSubviews[index]
            let shouldBeSelected = (index == newIndex)
            guard let iconView = container.viewWithTag(IconTag.value),
                  let button = container.subviews.first(where: { $0 is UIButton }) as? UIButton,
                  button.isSelected != shouldBeSelected else { continue }

            let tintColor = items[index].selectedTintColor ?? TabBarAppearance.selectedColor
            items[index].iconProvider.applySelection(to: iconView, isSelected: shouldBeSelected, tintColor: tintColor)

            UIView.animate(withDuration: duration, delay: 0, options: [.allowUserInteraction, .beginFromCurrentState]) {
                button.isSelected = shouldBeSelected
                iconView.transform = shouldBeSelected ? CGAffineTransform(scaleX: scale, y: scale) : .identity
            } completion: { [weak self] _ in
                guard let self, shouldBeSelected else { return }
                self.stopAnimation(on: iconView, at: index)
            }
        }
    }

    // MARK: - Animation

    private func startContinuousPulseAnimation(on view: UIView, at index: Int) {
        guard pulseAnimationKeys[index] == nil else { return }
        let key = "continuousPulse_\(index)"
        pulseAnimationKeys[index] = key
        let pulse = CABasicAnimation(keyPath: "transform.scale")
        pulse.fromValue = 1.0
        pulse.toValue = TabBarAppearance.pulseScale
        pulse.duration = TabBarAppearance.pulseDuration
        pulse.autoreverses = true
        pulse.repeatCount = .greatestFiniteMagnitude
        pulse.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        view.layer.add(pulse, forKey: key)
    }

    private func stopContinuousPulseAnimation(on view: UIView, at index: Int) {
        guard let key = pulseAnimationKeys.removeValue(forKey: index) else { return }
        view.layer.removeAnimation(forKey: key)
    }

    private func startAnimation(for kind: TabBarAnimationKind, on view: UIView, at index: Int) {
        startContinuousPulseAnimation(on: view, at: index)
    }

    private func stopAnimation(on view: UIView, at index: Int) {
        pulseAnimationKeys.removeValue(forKey: index)
        view.layer.removeAllAnimations()
    }
}
