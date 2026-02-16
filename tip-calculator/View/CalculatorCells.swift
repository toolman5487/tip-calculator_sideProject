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
        case food
        case clothing
        case housing
        case transport
        case education
        case entertainment

        var title: String {
            switch self {
            case .food: return "食"
            case .clothing: return "衣"
            case .housing: return "住"
            case .transport: return "行"
            case .education: return "育"
            case .entertainment: return "樂"
            }
        }

        var identifier: String {
            switch self {
            case .food: return "food"
            case .clothing: return "clothing"
            case .housing: return "housing"
            case .transport: return "transport"
            case .education: return "education"
            case .entertainment: return "entertainment"
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

    private let categorySubject = CurrentValueSubject<Category, Never>(.food)
    var valuePublisher: AnyPublisher<Category, Never> { categorySubject.eraseToAnyPublisher() }

    private lazy var categoryLabels: [UILabel] = Category.allCases.map { cat in
        let l = UILabel()
        l.text = cat.title
        l.font = ThemeFont.regular(Ofsize: 14)
        l.textColor = ThemeColor.text.withAlphaComponent(0.6)
        l.textAlignment = .center
        return l
    }

    private lazy var labelsStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: categoryLabels)
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 0
        return stack
    }()

    private lazy var slider: UISlider = {
        let s = UISlider()
        s.minimumValue = 0
        s.maximumValue = 5
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
        let clamped = min(max(step, 0), 5)
        slider.value = Float(clamped)
        let category = Category(rawValue: clamped) ?? .food
        categorySubject.send(category)
        updateLabelsHighlight(index: clamped)
        onCategoryTap?(category)
    }

    private func updateLabelsHighlight(index: Int) {
        for (i, label) in categoryLabels.enumerated() {
            let isSelected = (i == index)
            label.font = isSelected ? ThemeFont.bold(Ofsize: 16) : ThemeFont.regular(Ofsize: 14)
            label.textColor = isSelected ? ThemeColor.secondary : ThemeColor.text.withAlphaComponent(0.6)
        }
    }

    private func setupView() {
        contentView.addSubview(containerView)
        containerView.addSubview(headerView)
        containerView.addSubview(slider)
        containerView.addSubview(labelsStack)
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(cellContentInsets)
        }
        headerView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(12)
            make.width.equalTo(68)
            make.centerY.equalToSuperview()
        }
        slider.snp.makeConstraints { make in
            make.leading.equalTo(headerView.snp.trailing).offset(24)
            make.trailing.equalToSuperview().offset(-12)
            make.centerY.equalToSuperview().offset(-12)
        }
        labelsStack.snp.makeConstraints { make in
            make.leading.trailing.equalTo(slider)
            make.top.equalTo(slider.snp.bottom).offset(8)
        }
        updateLabelsHighlight(index: 0)
    }

    func configure(selectedCategory: Category? = nil) {
        let category = selectedCategory ?? .food
        categorySubject.send(category)
        slider.value = Float(category.rawValue)
        updateLabelsHighlight(index: category.rawValue)
    }

    func configure() {
        configure(selectedCategory: .food)
    }
}

extension CategoriesInputCell: Resettable {
    func reset() {
        configure(selectedCategory: .food)
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
