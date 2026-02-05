//
//  TotalResultsCell.swift
//  tip-calculator
//
//  Created by Willy Hsu on 2026/2/5.
//

import Foundation
import UIKit
import SnapKit

// MARK: - Highlight Cell

final class AmountPerPersonCell: UICollectionViewCell {
    static let reuseId = "AmountPerPersonCell"

    private let containerView = UIView()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Amount per person"
        label.font = ThemeFont.demiBold(Ofsize: 16)
        label.textColor = ThemeColor.text
        label.textAlignment = .center
        return label
    }()

    private let valueLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 60, weight: .bold, width: .condensed)
        label.textColor = ThemeColor.primary
        label.textAlignment = .center
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        contentView.addSubview(containerView)
        containerView.addSubview(valueLabel)
        containerView.addSubview(titleLabel)

        containerView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
        }

        valueLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview()
        }

        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(valueLabel.snp.bottom)
            make.bottom.equalToSuperview()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with result: Result) {
        valueLabel.text = result.amountPerPerson.currencyFormatted
    }
}

// MARK: - Info cells using base
final class TotalBillCell: BaseResultInfoCell {
    static let reuseId = "TotalBillCell"

    func configure(with result: Result) {
        titleLabel.text = "Total bill (with tip)"
        valueLabel.text = result.totalBill.currencyFormatted
        valueLabel.font = ThemeFont.bold(Ofsize: 20)
        valueLabel.textColor = ThemeColor.text
    }
}

final class TotalTipCell: BaseResultInfoCell {
    static let reuseId = "TotalTipCell"

    func configure(with result: Result) {
        titleLabel.text = "Total tip"
        valueLabel.text = result.totalTip.currencyFormatted
        valueLabel.font = ThemeFont.bold(Ofsize: 20)
        valueLabel.textColor = ThemeColor.text
    }
}

final class BillCell: BaseResultInfoCell {
    static let reuseId = "BillCell"

    func configure(with result: Result) {
        titleLabel.text = "Bill"
        valueLabel.text = result.bill.currencyFormatted
        valueLabel.font = ThemeFont.bold(Ofsize: 20)
        valueLabel.textColor = ThemeColor.text
    }
}

final class TipCell: BaseResultInfoCell {
    static let reuseId = "TipCell"

    func configure(with result: Result) {
        titleLabel.text = "Tip"
        let text = result.tip.stringValue.isEmpty ? "None" : result.tip.stringValue
        valueLabel.text = text
        valueLabel.font = ThemeFont.bold(Ofsize: 20)
        valueLabel.textColor = ThemeColor.secondary
    }
}

final class SplitCell: BaseResultInfoCell {
    static let reuseId = "SplitCell"

    func configure(with result: Result) {
        titleLabel.text = "Split"
        valueLabel.text = "\(result.split) people"
        valueLabel.font = ThemeFont.bold(Ofsize: 20)
        valueLabel.textColor = ThemeColor.text
    }
}
