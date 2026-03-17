//
//  AppIndicatorItemCell.swift
//  tip-calculator
//
//  Created by Willy Hsu on 2026/3/17.
//

import UIKit
import SnapKit

final class AppIndicatorItemCell: UICollectionViewCell {

    static let reuseId = "AppIndicatorItemCell"

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = ThemeFont.demiBold(Ofsize: 16)
        label.textColor = ThemeColor.primary
        label.numberOfLines = 0
        return label
    }()

    private let bodyLabel: UILabel = {
        let label = UILabel()
        label.font = ThemeFont.regular(Ofsize: 16)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        contentView.backgroundColor = .systemBackground
        contentView.layer.cornerRadius = 12
        contentView.layer.cornerCurve = .continuous
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(title: String, body: String) {
        titleLabel.text = title
        bodyLabel.text = body
    }

    private func setupUI() {
        let stack = UIStackView(arrangedSubviews: [titleLabel, bodyLabel])
        stack.axis = .vertical
        stack.spacing = 0
        stack.distribution = .fillProportionally
        stack.alignment = .leading
        contentView.addSubview(stack)

        stack.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(8)
            make.leading.trailing.equalToSuperview().inset(16)
        }
    }
}
