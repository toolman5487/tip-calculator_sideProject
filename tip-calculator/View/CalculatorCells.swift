//
//  CalculatorCells.swift
//  tip-calculator
//

import Combine
import CombineCocoa
import SnapKit
import UIKit

private let cellInsetHorizontal: CGFloat = 16
private let cellInsetVertical: CGFloat = 8
private var cellContentInsets: UIEdgeInsets {
    UIEdgeInsets(top: cellInsetVertical, left: cellInsetHorizontal, bottom: cellInsetVertical, right: cellInsetHorizontal)
}

// MARK: - CalculatorCells

struct CalculatorCells {
    let result = ResultCell()
    let billInput = BillInputCell()
    let categoriesInput = CategoriesInputCell()
    let tipInput = TipInputCell()
    let splitInput = SplitInputCell()
    let confirmButton = ConfirmButtonCell()

    var resettables: [Resettable] {
        [billInput, categoriesInput, tipInput, splitInput].compactMap { $0 as? Resettable }
    }
}

// MARK: - Resettable Protocol
protocol Resettable: AnyObject {
    func reset()
}

// MARK: - ResultCell

final class ResultCell: UITableViewCell {

    static let reuseId = "ResultCell"

    var onTap: (() -> Void)?

    // MARK: - UI Components

    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()

    private(set) lazy var resultView = ResultView()

    // MARK: - Lifecycle

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        contentView.backgroundColor = .clear
        backgroundColor = .clear
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Configuration

    func configure() {}

    // MARK: - Setup

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
        let tap = UITapGestureRecognizer(target: self, action: #selector(resultViewTapped))
        resultView.isUserInteractionEnabled = true
        resultView.addGestureRecognizer(tap)
    }

    @objc private func resultViewTapped() {
        onTap?()
    }
}

// MARK: - BillInputCell

final class BillInputCell: UITableViewCell {

    static let reuseId = "BillInputCell"

    // MARK: - UI Components

    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
        return view
    }()

    private(set) lazy var billInputView = BillInputView()

    // MARK: - Lifecycle

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        contentView.backgroundColor = .clear
        backgroundColor = .clear
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Configuration

    func configure() {}

    // MARK: - Setup

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
}

extension BillInputCell: Resettable {
    func reset() {
        billInputView.billReset()
    }
}

extension BillInputCell {
    func focusInput() {
        billInputView.focusTextField()
    }
}

// MARK: - CategoriesInputCell

final class CategoriesInputCell: UITableViewCell {

    static let reuseId = "CategoriesInputCell"

    // MARK: - UI Components

    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
        return view
    }()

    private(set) lazy var categoryInputView = CategoryInputView()

    var mainGridCategoryTapPublisher: AnyPublisher<Category, Never> { categoryInputView.mainGridCategoryTapPublisher }
    var onMoreOptionsTap: (() -> Void)? {
        get { categoryInputView.onMoreOptionsTap }
        set { categoryInputView.onMoreOptionsTap = newValue }
    }

    // MARK: - Lifecycle

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        contentView.backgroundColor = .clear
        backgroundColor = .clear
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Configuration

    func configure() {}

    // MARK: - Setup

    private func setupView() {
        contentView.addSubview(containerView)
        containerView.addSubview(categoryInputView)
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(cellContentInsets)
        }
        categoryInputView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(16)
        }
    }
}

extension CategoriesInputCell: Resettable {
    func reset() {
        categoryInputView.categoryReset()
    }
}

// MARK: - TipInputCell

final class TipInputCell: UITableViewCell {

    static let reuseId = "TipInputCell"

    // MARK: - UI Components

    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
        return view
    }()

    private(set) lazy var tipInputView = TipInputView()

    // MARK: - Lifecycle

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        contentView.backgroundColor = .clear
        backgroundColor = .clear
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Configuration

    func configure() {}

    // MARK: - Setup

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
}

extension TipInputCell: Resettable {
    func reset() {
        tipInputView.tipReset()
    }
}

// MARK: - SplitInputCell

final class SplitInputCell: UITableViewCell {

    static let reuseId = "SplitInputCell"

    // MARK: - UI Components

    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
        return view
    }()

    private(set) lazy var splitInputView = SplitInputView()

    // MARK: - Lifecycle

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        contentView.backgroundColor = .clear
        backgroundColor = .clear
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Configuration

    func configure() {}

    // MARK: - Setup

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

    // MARK: - UI Components

    private(set) lazy var confirmButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("確認", for: .normal)
        button.titleLabel?.font = ThemeFont.bold(Ofsize: 20)
        button.backgroundColor = ThemeColor.selected
        button.setTitleColor(.white, for: .normal)
        button.addCornerRadius(radius: 8)
        return button
    }()

    // MARK: - Lifecycle

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        contentView.backgroundColor = .clear
        backgroundColor = .clear
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Configuration

    func configure() {}

    // MARK: - Setup

    private func setupView() {
        contentView.addSubview(confirmButton)
        confirmButton.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(cellContentInsets)
        }
        confirmButton.addTarget(self, action: #selector(didTapConfirm), for: .touchUpInside)
    }

    // MARK: - Actions

    @objc private func didTapConfirm() {
        onTap?()
    }
}
