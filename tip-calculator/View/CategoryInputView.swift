//
//  CategoryInputView.swift
//  tip-calculator
//

import UIKit
import Combine
import CombineCocoa
import SnapKit

enum Category: Int, CaseIterable {
    case none
    case food
    case clothing
    case housing
    case transport
    case education
    case entertainment

    var identifier: String {
        switch self {
        case .none: return ""
        case .food: return "food"
        case .clothing: return "clothing"
        case .housing: return "housing"
        case .transport: return "transport"
        case .education: return "education"
        case .entertainment: return "entertainment"
        }
    }

    var systemImageName: String? {
        switch self {
        case .none: return nil
        case .food: return "fork.knife"
        case .clothing: return "tshirt.fill"
        case .housing: return "house.fill"
        case .transport: return "car.fill"
        case .education: return "book.fill"
        case .entertainment: return "gamecontroller.fill"
        }
    }

    var displayName: String {
        switch self {
        case .none: return "無"
        case .food: return "食"
        case .clothing: return "衣"
        case .housing: return "住"
        case .transport: return "行"
        case .education: return "育"
        case .entertainment: return "樂"
        }
    }

    init?(identifier: String) {
        guard !identifier.isEmpty,
              let match = Self.allCases.first(where: { $0.identifier == identifier })
        else { return nil }
        self = match
    }
}

final class CategoryInputView: UIView {

    private static let displayCategories: [Category] = [.food, .clothing, .housing, .transport, .education, .entertainment]

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

    private lazy var row1Stack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: Array(categoryButtons.prefix(3)))
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 8
        return stack
    }()

    private lazy var row2Stack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: Array(categoryButtons.suffix(3)))
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 8
        return stack
    }()

    private lazy var bottomButton: UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = ThemeColor.primary
        button.tintColor = .white
        button.addCornerRadius(radius: 8)
        button.layer.cornerRadius = 12
        button.clipsToBounds = true
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
        button.setImage(UIImage(systemName: "ellipsis", withConfiguration: config), for: .normal)
        return button
    }()

    private lazy var gridStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [row1Stack, row2Stack, bottomButton])
        stack.axis = .vertical
        stack.spacing = 8
        stack.distribution = .fillEqually
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
        bottomButton.tapPublisher
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
        bottomButton.backgroundColor = ThemeColor.primary
    }

    private func setupLayout() {
        addSubview(headerView)
        addSubview(gridStack)
        headerView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.width.equalTo(68)
            make.centerY.equalToSuperview()
        }
        gridStack.snp.makeConstraints { make in
            make.leading.equalTo(headerView.snp.trailing).offset(24)
            make.trailing.equalToSuperview()
            make.top.bottom.equalToSuperview()
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
