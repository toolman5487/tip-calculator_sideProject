//
//  ResultDetailEditCategoryCell.swift
//  tip-calculator
//

import UIKit
import SnapKit

final class ResultDetailEditCategoryCell: UITableViewCell {

    static let reuseId = "ResultDetailEditCategoryCell"

    private let iconContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemBackground
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        return view
    }()

    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .label
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = ThemeFont.demiBold(Ofsize: 16)
        label.textColor = .secondaryLabel
        label.text = "消費種類"
        return label
    }()

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
        selectionStyle = .none
        iconImageView.image = UIImage(systemName: "tag.fill")
        contentView.addSubview(iconContainerView)
        iconContainerView.addSubview(iconImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(valueLabel)
        contentView.addSubview(accessoryImageView)
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        contentView.addGestureRecognizer(tap)

        iconContainerView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(32)
        }
        iconImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(16)
        }
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(iconContainerView.snp.trailing).offset(12)
            make.centerY.equalToSuperview()
        }
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
