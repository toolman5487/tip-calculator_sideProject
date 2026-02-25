//
//  IllustrationSectionHeaderView.swift
//  tip-calculator
//

import UIKit
import SnapKit

final class IllustrationSectionHeaderView: BaseBlurSectionHeaderView {

    static let reuseId = "IllustrationSectionHeaderView"

    override var blurStyle: UIBlurEffect.Style { .systemUltraThinMaterialLight }

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
