//
//  CalculatorCells.swift
//  tip-calculator
//

import UIKit
import SnapKit
import Combine

private let cellInsetHorizontal: CGFloat = 16
private let cellInsetVertical: CGFloat = 8
private var cellContentInsets: UIEdgeInsets {
    UIEdgeInsets(top: cellInsetVertical, left: cellInsetHorizontal, bottom: cellInsetVertical, right: cellInsetHorizontal)
}

// MARK: - Resettable Protocol
protocol Resettable: AnyObject {
    func reset()
}

// MARK: - ResultCell
final class ResultCell: UITableViewCell {
    static let reuseId = "ResultCell"
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    private(set) lazy var resultView = ResultView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        contentView.backgroundColor = .clear
        backgroundColor = .clear
        setupView()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setupView() {
        contentView.addSubview(containerView)
        containerView.addSubview(resultView)
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(cellContentInsets)
        }
        resultView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(8)
            make.right.left.bottom.equalToSuperview()
        }
    }

    func configure() {}
}

// MARK: - BillInputCell
final class BillInputCell: UITableViewCell {
    static let reuseId = "BillInputCell"

    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
        return view
    }()
    private(set) lazy var billInputView = BillInputView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        contentView.backgroundColor = .clear
        backgroundColor = .clear
        setupView()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setupView() {
        contentView.addSubview(containerView)
        containerView.addSubview(billInputView)
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(cellContentInsets)
        }
        billInputView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(16)
        }
    }

    func configure() {}
}

extension BillInputCell: Resettable {
    func reset() {
        billInputView.billReset()
    }
}

// MARK: - CategoriesInputCell
final class CategoriesInputCell: UITableViewCell {
    static let reuseId = "CategoriesInputCell"

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

        var systemImageName: String {
            switch self {
            case .none: return "person.fill.questionmark"
            case .food: return "fork.knife"
            case .clothing: return "tshirt.fill"
            case .housing: return "house.fill"
            case .transport: return "car.fill"
            case .education: return "book.fill"
            case .entertainment: return "gamecontroller.fill"
            }
        }
    }

    var onCategoryTap: ((Category) -> Void)?

    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
        return view
    }()

    private let headerView: HeaderView = {
        let view = HeaderView()
        view.configure(topText: "選擇", bottomText: "消費種類")
        return view
    }()

    private let categorySubject = CurrentValueSubject<Category, Never>(.none)
    var valuePublisher: AnyPublisher<Category, Never> { categorySubject.eraseToAnyPublisher() }

    private lazy var categoryImageViews: [UIImageView] = Category.allCases.map { cat in
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.image = UIImage(systemName: cat.systemImageName)
        iv.tintColor = ThemeColor.text.withAlphaComponent(0.6)
        return iv
    }

    private lazy var iconsStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: categoryImageViews)
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 0
        return stack
    }()

    private let sliderIconsContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()

    private lazy var slider: UISlider = {
        let s = UISlider()
        s.minimumValue = 0
        s.maximumValue = Float(Category.allCases.count - 1)
        s.value = 0
        s.minimumTrackTintColor = ThemeColor.secondary
        s.maximumTrackTintColor = ThemeColor.primary.withAlphaComponent(0.3)
        s.addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)
        return s
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        contentView.backgroundColor = .clear
        backgroundColor = .clear
        setupView()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    @objc private func sliderValueChanged() {
        let step = Int(slider.value.rounded())
        let clamped = min(max(step, 0), Category.allCases.count - 1)
        slider.value = Float(clamped)
        let category = Category(rawValue: clamped) ?? .none
        categorySubject.send(category)
        updateIconsHighlight(index: clamped)
        onCategoryTap?(category)
    }

    private func updateIconsHighlight(index: Int) {
        for (i, imageView) in categoryImageViews.enumerated() {
            let isSelected = (i == index)
            imageView.tintColor = isSelected ? ThemeColor.secondary : ThemeColor.text.withAlphaComponent(0.6)
        }
    }

    private func setupView() {
        contentView.addSubview(containerView)
        containerView.addSubview(headerView)
        containerView.addSubview(sliderIconsContainerView)
        sliderIconsContainerView.addSubview(iconsStack)
        sliderIconsContainerView.addSubview(slider)
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(cellContentInsets)
        }
        headerView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(12)
            make.width.equalTo(68)
            make.centerY.equalToSuperview()
        }
        sliderIconsContainerView.snp.makeConstraints { make in
            make.leading.equalTo(headerView.snp.trailing).offset(24)
            make.trailing.equalToSuperview().offset(-12)
            make.centerY.equalTo(headerView)
        }
        iconsStack.snp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview()
        }
        slider.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.top.equalTo(iconsStack.snp.bottom).offset(8)
        }
        updateIconsHighlight(index: 0)
    }

    func configure(selectedCategory: Category? = nil) {
        let category = selectedCategory ?? .none
        categorySubject.send(category)
        slider.value = Float(category.rawValue)
        updateIconsHighlight(index: category.rawValue)
    }

    func configure() {
        configure(selectedCategory: .none)
    }
}

extension CategoriesInputCell: Resettable {
    func reset() {
        configure(selectedCategory: .none)
    }
}

// MARK: - TipInputCell
final class TipInputCell: UITableViewCell {
    static let reuseId = "TipInputCell"
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
        return view
    }()
    private(set) lazy var tipInputView = TipInputView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        contentView.backgroundColor = .clear
        backgroundColor = .clear
        setupView()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setupView() {
        contentView.addSubview(containerView)
        containerView.addSubview(tipInputView)
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(cellContentInsets)
        }
        tipInputView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(16)
        }
    }

    func configure() {}
}

extension TipInputCell: Resettable {
    func reset() {
        tipInputView.tipReset()
    }
}

// MARK: - SplitInputCell
final class SplitInputCell: UITableViewCell {
    static let reuseId = "SplitInputCell"
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
        return view
    }()
    private(set) lazy var splitInputView = SplitInputView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        contentView.backgroundColor = .clear
        backgroundColor = .clear
        setupView()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setupView() {
        contentView.addSubview(containerView)
        containerView.addSubview(splitInputView)
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(cellContentInsets)
        }
        splitInputView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(16)
            make.top.bottom.equalToSuperview()
        }
    }

    func configure() {}
}

extension SplitInputCell: Resettable {
    func reset() {
        splitInputView.splitReset()
    }
}

// MARK: - ConfirmButtonCell
final class ConfirmButtonCell: UITableViewCell {
    static let reuseId = "ConfirmButtonCell"
    
    var onTap: (() -> Void)?
    
    private(set) lazy var confirmButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("確認", for: .normal)
        button.titleLabel?.font = ThemeFont.bold(Ofsize: 18)
        button.backgroundColor = ThemeColor.secondary
        button.setTitleColor(.white, for: .normal)
        button.addCornerRadius(radius: 8)
        return button
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        contentView.backgroundColor = .clear
        backgroundColor = .clear
        setupView()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setupView() {
        contentView.addSubview(confirmButton)
        confirmButton.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(cellContentInsets)
        }
        confirmButton.addTarget(self, action: #selector(didTapConfirm), for: .touchUpInside)
    }

    func configure() {}
    
    @objc private func didTapConfirm() {
        onTap?()
    }
}
