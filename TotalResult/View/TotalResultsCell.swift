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
        label.text = "每人應付金額"
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
        titleLabel.text = "含小費總金額"
        valueLabel.text = result.totalBill.currencyFormatted
        valueLabel.font = ThemeFont.bold(Ofsize: 20)
        valueLabel.textColor = ThemeColor.text
    }
}

final class TotalTipCell: BaseResultInfoCell {
    static let reuseId = "TotalTipCell"

    func configure(with result: Result) {
        titleLabel.text = "小費總額"
        valueLabel.text = result.totalTip.currencyFormatted
        valueLabel.font = ThemeFont.bold(Ofsize: 20)
        valueLabel.textColor = ThemeColor.text
    }
}

final class BillCell: BaseResultInfoCell {
    static let reuseId = "BillCell"

    func configure(with result: Result) {
        titleLabel.text = "帳單金額"
        valueLabel.text = result.bill.currencyFormatted
        valueLabel.font = ThemeFont.bold(Ofsize: 20)
        valueLabel.textColor = ThemeColor.text
    }
}

final class TipCell: BaseResultInfoCell {
    static let reuseId = "TipCell"

    func configure(with result: Result) {
        titleLabel.text = "小費設定"
        let text = result.tip.stringValue.isEmpty ? "無" : result.tip.stringValue
        valueLabel.text = text
        valueLabel.font = ThemeFont.bold(Ofsize: 20)
        valueLabel.textColor = ThemeColor.secondary
    }
}

final class SplitCell: BaseResultInfoCell {
    static let reuseId = "SplitCell"

    func configure(with result: Result) {
        titleLabel.text = "分攤人數"
        valueLabel.text = "\(result.split) 人"
        valueLabel.font = ThemeFont.bold(Ofsize: 20)
        valueLabel.textColor = ThemeColor.text
    }
}

final class CategoryCell: BaseImageResultInfoCell {
    static let reuseId = "CategoryCell"

    func configure(with result: Result) {
        titleLabel.text = "消費種類"

        if let name = result.categorySystemImageName {
            let config = UIImage.SymbolConfiguration(pointSize: 28, weight: .medium)
            valueImageView.image = UIImage(systemName: name, withConfiguration: config)
            valueImageView.isHidden = false
        } else {
            valueImageView.image = nil
            valueImageView.isHidden = true
        }
    }
}

final class LocationCell: BaseResultInfoCell {
    static let reuseId = "LocationCell"

    private let activityIndicator: UIActivityIndicatorView = {
        let v = UIActivityIndicatorView(style: .medium)
        v.hidesWhenStopped = true
        return v
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(activityIndicator)
        activityIndicator.snp.makeConstraints { make in
            make.centerY.equalTo(valueLabel)
            make.trailing.equalTo(valueLabel.snp.leading).offset(-8)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(locationText: String, isLoading: Bool = false) {
        titleLabel.text = "消費地點"
        valueLabel.font = ThemeFont.bold(Ofsize: 20)
        valueLabel.textColor = ThemeColor.text
        if isLoading {
            valueLabel.text = "取得定位中"
            activityIndicator.startAnimating()
        } else {
            valueLabel.text = locationText
            activityIndicator.stopAnimating()
        }
    }
}

// MARK: - Save Button Cell

final class SaveRecordCell: UICollectionViewCell {
    static let reuseId = "SaveRecordCell"

    private let button: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("儲存這筆消費紀錄", for: .normal)
        button.titleLabel?.font = ThemeFont.bold(Ofsize: 20)
        button.backgroundColor = ThemeColor.primary
        button.tintColor = .white
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        return button
    }()

    var onTap: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .clear

        contentView.addSubview(button)
        button.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        button.addTarget(self, action: #selector(handleTap), for: .touchUpInside)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc
    private func handleTap() {
        onTap?()
    }
}

