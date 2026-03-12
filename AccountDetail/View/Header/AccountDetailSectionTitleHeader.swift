//
//  AccountDetailSectionTitleHeader.swift
//  tip-calculator
//

import SnapKit
import UIKit

final class AccountDetailSectionTitleHeader: BaseBlurSectionHeaderView {

    static let reuseId = "AccountDetailSectionTitleHeader"

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = ThemeFont.demiBold(Ofsize: 16)
        label.textColor = .secondaryLabel
        return label
    }()

    override func setupContent() {
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
        }
    }

    func configure(title: String) {
        titleLabel.text = title
    }
}
