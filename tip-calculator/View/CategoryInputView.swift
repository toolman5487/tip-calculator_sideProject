//
//  CategoryInputView.swift
//  tip-calculator
//

import UIKit
import Combine
import CombineCocoa
import SnapKit

final class CategoryInputView: UIView {

    private static let displayCategories: [Category] = [.food, .clothing, .housing, .transport]

    private var cancellables = Set<AnyCancellable>()
    private let categorySubject = CurrentValueSubject<Category, Never>(.none)
    var valuePublisher: AnyPublisher<Category, Never> { categorySubject.eraseToAnyPublisher() }
    var currentCategory: Category { categorySubject.value }
    var onMoreOptionsTap: (() -> Void)?

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

    init() {
        super.init(frame: .zero)
        setupLayout()
        bindButtons()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func bindButtons() {
        for (index, button) in categoryButtons.enumerated() {
            guard index < Self.displayCategories.count else { continue }
            let category = Self.displayCategories[index]
            button.tapPublisher
                .sink { [weak self] _ in
                    guard let self else { return }
                    if categorySubject.value == category {
                        categorySubject.send(.none)
                    } else {
                        categorySubject.send(category)
                    }
                }
                .store(in: &cancellables)
        }
        moreButton.tapPublisher
            .sink { [weak self] _ in
                self?.onMoreOptionsTap?()
            }
            .store(in: &cancellables)
        categorySubject
            .sink { [weak self] selected in
                self?.updateButtonSelection(selected: selected)
            }
            .store(in: &cancellables)
    }

    private func updateButtonSelection(selected: Category) {
        for (index, button) in categoryButtons.enumerated() {
            guard index < Self.displayCategories.count else { continue }
            let isSelected = Self.displayCategories[index] == selected
            button.backgroundColor = isSelected ? ThemeColor.secondary : ThemeColor.primary
        }
        moreButton.backgroundColor = ThemeColor.primary
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
        let imageName = selected.systemImageName ?? "ellipsis"
        moreButton.setImage(UIImage(systemName: imageName, withConfiguration: config), for: .normal)
    }

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

    func categoryReset() {
        categorySubject.send(.none)
    }

    func selectCategory(_ category: Category) {
        categorySubject.send(category)
    }
}
