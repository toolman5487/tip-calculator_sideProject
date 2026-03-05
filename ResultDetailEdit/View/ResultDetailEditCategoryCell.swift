//
//  ResultDetailEditCategoryCell.swift
//  tip-calculator
//

import SnapKit
import UIKit

final class ResultDetailEditCategoryCell: ResultDetailEditBaseCell {

    static let reuseId = "ResultDetailEditCategoryCell"

    private let valueLabel: UILabel = {
        let label = UILabel()
        label.font = ThemeFont.bold(Ofsize: 16)
        label.textColor = ThemeColor.text
        label.textAlignment = .right
        label.numberOfLines = 1
        return label
    }()

    private let accessoryImageView: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "chevron.right"))
        iv.tintColor = .tertiaryLabel
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    var onTap: (() -> Void)?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        titleLabel.text = "消費種類"
        iconImageView.image = UIImage(systemName: "tag.fill")
        contentView.addSubview(valueLabel)
        contentView.addSubview(accessoryImageView)
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        contentView.addGestureRecognizer(tap)

        accessoryImageView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(12)
        }
        valueLabel.snp.makeConstraints { make in
            make.leading.greaterThanOrEqualTo(titleLabel.snp.trailing).offset(8)
            make.trailing.equalTo(accessoryImageView.snp.leading).offset(-8)
            make.centerY.equalToSuperview()
        }
    }

    func configure(categoryDisplayName: String, systemImageName: String?) {
        valueLabel.text = categoryDisplayName
        iconImageView.image = UIImage(systemName: systemImageName ?? "tag.fill")
    }

    @objc private func handleTap() {
        onTap?()
    }
}
