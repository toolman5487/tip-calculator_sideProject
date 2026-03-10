//
//  CategoryInputView.swift
//  tip-calculator
//

import Combine
import CombineCocoa
import SnapKit
import UIKit

final class CategoryInputView: UIView {

    // MARK: - Constants

    private static let displayCategories: [Category] = Category.mainGridCategories

    // MARK: - State & Publishers

    private var cancellables = Set<AnyCancellable>()
    private let mainGridCategoryTapSubject = PassthroughSubject<Category, Never>()
    var mainGridCategoryTapPublisher: AnyPublisher<Category, Never> { mainGridCategoryTapSubject.eraseToAnyPublisher() }
    var onMoreOptionsTap: (() -> Void)?

    // MARK: - UI Components

    private let headerView: HeaderView = {
        let view = HeaderView()
        view.configure(topText: "選擇", bottomText: "消費種類")
        return view
    }()

    private lazy var categoryButtons: [UIButton] = Self.displayCategories.map { category in
        let button = UIButton(type: .custom)
        button.backgroundColor = ThemeColor.primary
        button.tintColor = .white
        button.addCornerRadius(radius: 8)
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
        button.setImage(UIImage(systemName: category.systemImageName!, withConfiguration: config), for: .normal)
        return button
    }

    private lazy var categoryRowStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: categoryButtons)
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 8
        return stack
    }()

    private lazy var moreButton: UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = ThemeColor.primary
        button.tintColor = .white
        button.addCornerRadius(radius: 8)
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
        button.setImage(UIImage(systemName: "ellipsis", withConfiguration: config), for: .normal)
        return button
    }()

    private lazy var contentStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [categoryRowStack, moreButton])
        stack.axis = .vertical
        stack.spacing = 8
        return stack
    }()

    // MARK: - Lifecycle

    init() {
        super.init(frame: .zero)
        setupLayout()
        bind()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Configuration

    func updateSelection(_ category: Category) {
        updateButtonSelection(selected: category)
    }

    func categoryReset() {
        updateSelection(.none)
    }

    // MARK: - Setup

    private func setupLayout() {
        addSubview(headerView)
        addSubview(contentStackView)
        contentStackView.snp.makeConstraints { make in
            make.top.bottom.trailing.equalToSuperview()
            make.leading.equalTo(headerView.snp.trailing).offset(24)
        }
        headerView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.width.equalTo(68)
            make.centerY.equalTo(contentStackView)
        }
        moreButton.snp.makeConstraints { make in
            make.height.equalTo(44)
        }
        categoryButtons.forEach { button in
            button.snp.makeConstraints { make in
                make.height.equalTo(button.snp.width).priority(.high)
            }
        }
    }

    private func bind() {
        for (index, button) in categoryButtons.enumerated() {
            guard index < Self.displayCategories.count else { continue }
            let category = Self.displayCategories[index]
            button.tapPublisher
                .sink { [weak self] _ in
                    self?.mainGridCategoryTapSubject.send(category)
                }
                .store(in: &cancellables)
        }
        moreButton.tapPublisher
            .sink { [weak self] _ in
                self?.onMoreOptionsTap?()
            }
            .store(in: &cancellables)
    }

    private func updateButtonSelection(selected: Category) {
        for (index, button) in categoryButtons.enumerated() {
            guard index < Self.displayCategories.count else { continue }
            let isSelected = Self.displayCategories[index] == selected
            button.backgroundColor = isSelected ? ThemeColor.selected : ThemeColor.primary
        }
        let isMoreSelected = Category.sheetCategories.contains(selected)
        moreButton.backgroundColor = isMoreSelected ? ThemeColor.selected : ThemeColor.primary
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
        let imageName = isMoreSelected ? (selected.systemImageName ?? "ellipsis") : "ellipsis"
        moreButton.setImage(UIImage(systemName: imageName, withConfiguration: config), for: .normal)
    }
}
