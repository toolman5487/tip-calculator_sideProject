//
//  CalculatorCells.swift
//  tip-calculator
//

import UIKit
import SnapKit

private let cellInsetHorizontal: CGFloat = 16
private let cellInsetVertical: CGFloat = 8
private var cellContentInsets: UIEdgeInsets {
    UIEdgeInsets(top: cellInsetVertical, left: cellInsetHorizontal, bottom: cellInsetVertical, right: cellInsetHorizontal)
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
            make.left.right.equalToSuperview().inset(16)
            make.top.bottom.equalToSuperview()
        }
    }

    func configure() {}
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

