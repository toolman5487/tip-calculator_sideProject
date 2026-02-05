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

// MARK: - LogoCell
final class LogoCell: UITableViewCell {
    static let reuseId = "LogoCell"

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        contentView.backgroundColor = .clear
        backgroundColor = .clear
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func prepareForReuse() {
        super.prepareForReuse()
        contentView.subviews.forEach { $0.removeFromSuperview() }
    }

    func configure(with view: LogoView) {
        contentView.subviews.forEach { $0.removeFromSuperview() }
        contentView.addSubview(view)
        view.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(cellContentInsets)
        }
    }
}

// MARK: - ResultCell
final class ResultCell: UITableViewCell {
    static let reuseId = "ResultCell"

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        contentView.backgroundColor = .clear
        backgroundColor = .clear
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func prepareForReuse() {
        super.prepareForReuse()
        contentView.subviews.forEach { $0.removeFromSuperview() }
    }

    func configure(with view: ResultView) {
        contentView.subviews.forEach { $0.removeFromSuperview() }
        contentView.addSubview(view)
        view.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(cellContentInsets)
        }
    }
}

// MARK: - BillInputCell
final class BillInputCell: UITableViewCell {
    static let reuseId = "BillInputCell"

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        contentView.backgroundColor = .clear
        backgroundColor = .clear
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func prepareForReuse() {
        super.prepareForReuse()
        contentView.subviews.forEach { $0.removeFromSuperview() }
    }

    func configure(with view: BillInputView) {
        contentView.subviews.forEach { $0.removeFromSuperview() }
        contentView.addSubview(view)
        view.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(cellContentInsets)
        }
    }
}

// MARK: - TipInputCell
final class TipInputCell: UITableViewCell {
    static let reuseId = "TipInputCell"

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        contentView.backgroundColor = .clear
        backgroundColor = .clear
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func prepareForReuse() {
        super.prepareForReuse()
        contentView.subviews.forEach { $0.removeFromSuperview() }
    }

    func configure(with view: TipInputView) {
        contentView.subviews.forEach { $0.removeFromSuperview() }
        contentView.addSubview(view)
        view.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(cellContentInsets)
        }
    }
}

// MARK: - SplitInputCell
final class SplitInputCell: UITableViewCell {
    static let reuseId = "SplitInputCell"

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        contentView.backgroundColor = .clear
        backgroundColor = .clear
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func prepareForReuse() {
        super.prepareForReuse()
        contentView.subviews.forEach { $0.removeFromSuperview() }
    }

    func configure(with view: SplitInputView) {
        contentView.subviews.forEach { $0.removeFromSuperview() }
        contentView.addSubview(view)
        view.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(cellContentInsets)
        }
    }
}
