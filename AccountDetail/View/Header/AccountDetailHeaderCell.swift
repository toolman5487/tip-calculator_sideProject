//
//  AccountDetailHeaderView.swift
//  tip-calculator
//

import SnapKit
import UIKit

final class AccountDetailHeaderCell: UICollectionViewCell {

    static let reuseId = "AccountDetailHeaderCell"

    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        return view
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = ThemeFont.demiBold(Ofsize: 16)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.adjustsFontForContentSizeCategory = true
        return label
    }()

    private let valueLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 60, weight: .bold, width: .condensed)
        label.textColor = ThemeColor.primary
        label.textAlignment = .center
        label.adjustsFontForContentSizeCategory = true
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .clear
        contentView.addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(valueLabel)
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(40)
        }
        valueLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(titleLabel.snp.top)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(personalConsumptionTotalText: String) {
        titleLabel.text = "個人總消費"
        valueLabel.text = personalConsumptionTotalText
        isAccessibilityElement = true
        accessibilityLabel = "個人總消費：\(personalConsumptionTotalText)"
    }
}
