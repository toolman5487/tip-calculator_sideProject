//
//  ConsumptionBreakdownSectionTitleHeader.swift
//  tip-calculator
//
//  Created by Willy Hsu on 2026/2/24.
//

import UIKit
import SnapKit

final class ConsumptionBreakdownSectionTitleHeader: BaseBlurSectionHeaderView {

    static let reuseId = "ConsumptionBreakdownSectionTitleHeader"

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "消費分類"
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .secondaryLabel
        return label
    }()

    func configure(title: String) {
        titleLabel.text = title
    }

    override func setupContent() {
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
        }
    }
}
