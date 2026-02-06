//
//  ResultsFilterCell.swift
//  tip-calculator
//
//  Created by Willy Hsu on 2026/2/6.
//

import UIKit
import SnapKit

final class ResultsFilterCell: UITableViewCell {

    static let reuseId = "ResultsFilterCell"

    private let cardView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = ThemeFont.bold(Ofsize: 16)
        label.textColor = ThemeColor.text
        label.numberOfLines = 0
        return label
    }()

    private let totalLabel: UILabel = {
        let label = UILabel()
        label.font = ThemeFont.demiBold(Ofsize: 16)
        label.textColor = .secondaryLabel
        label.numberOfLines = 1
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = ThemeFont.demiBold(Ofsize: 16)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }

    private func setupViews() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        contentView.addSubview(cardView)
        cardView.addSubview(titleLabel)
        cardView.addSubview(totalLabel)
        cardView.addSubview(subtitleLabel)

        cardView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(8)
            make.leading.trailing.equalToSuperview().inset(12)
        }

        totalLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
            make.leading.equalToSuperview().inset(12)
            make.bottom.equalToSuperview().inset(16)
        }

        subtitleLabel.snp.makeConstraints { make in
            make.centerY.equalTo(totalLabel)
            make.left.equalTo(totalLabel.snp.right).offset(4)
            make.right.equalToSuperview().inset(12)
        }
    }

    func configure(with item: RecordDisplayItem) {
        if item.addressText.isEmpty {
            titleLabel.attributedText = NSAttributedString(
                string: item.dateText,
                attributes: [
                    .font: ThemeFont.bold(Ofsize: 16),
                    .foregroundColor: ThemeColor.text
                ]
            )
        } else {
            let fullText = "\(item.dateText) · \(item.addressText)"
            let attr = NSMutableAttributedString(
                string: fullText,
                attributes: [
                    .font: ThemeFont.bold(Ofsize: 16),
                    .foregroundColor: ThemeColor.text
                ]
            )
            if let range = fullText.range(of: item.addressText) {
                let nsRange = NSRange(range, in: fullText)
                attr.addAttributes(
                    [
                        .font: ThemeFont.demiBold(Ofsize: 13),
                        .foregroundColor: UIColor.secondaryLabel
                    ],
                    range: nsRange
                )
            }
            titleLabel.attributedText = attr
        }

        totalLabel.text = "總計 \(item.totalBillText)"
        subtitleLabel.text = "每人 \(item.amountPerPersonText)"
        subtitleLabel.textColor = .secondaryLabel

        let total = item.totalBillValue
        switch total {
        case 0:
            totalLabel.textColor = .secondaryLabel
        case 1...999:
            totalLabel.textColor = .systemGreen
        case 1000...9999:
            totalLabel.textColor = .systemBlue
        default:
            totalLabel.textColor = .systemRed
        }
    }
}

