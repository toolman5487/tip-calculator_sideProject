//
//  BillInputCell.swift
//  tip-calculator
//

import UIKit
import SnapKit

private let billCellInsetH: CGFloat = 16
private let billCellInsetV: CGFloat = 8
private var billCellContentInsets: UIEdgeInsets {
    UIEdgeInsets(top: billCellInsetV, left: billCellInsetH, bottom: billCellInsetV, right: billCellInsetH)
}

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
            make.edges.equalToSuperview().inset(billCellContentInsets)
        }
        billInputView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(16)
            make.top.bottom.equalToSuperview()
        }
    }

    func configure() {}
}
