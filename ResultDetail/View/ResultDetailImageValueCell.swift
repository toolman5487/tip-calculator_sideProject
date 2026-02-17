//
//  ResultDetailImageValueCell.swift
//  tip-calculator
//

import UIKit
import SnapKit

final class ResultDetailImageValueCell: UITableViewCell {

    static let reuseId = "ResultDetailImageValueCell"

    private let iconContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemBackground
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        return view
    }()

    private let iconImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.tintColor = .label
        return iv
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = ThemeFont.demiBold(Ofsize: 12)
        label.textColor = .secondaryLabel
        return label
    }()

    private let valueImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.tintColor = ThemeColor.text
        return iv
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
        selectionStyle = .none
        contentView.addSubview(iconContainerView)
        iconContainerView.addSubview(iconImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(valueImageView)

        iconContainerView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalTo(titleLabel)
            make.width.height.equalTo(32)
        }

        iconImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(16)
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.equalTo(iconContainerView.snp.trailing).offset(12)
            make.trailing.lessThanOrEqualToSuperview().offset(-16)
        }

        valueImageView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
            make.leading.equalTo(titleLabel)
            make.width.height.equalTo(28)
            make.bottom.lessThanOrEqualToSuperview().offset(-8)
        }
    }

    func configure(title: String, systemImageName: String, valueImageName: String?, valueImageTintColor: UIColor? = nil) {
        titleLabel.text = title
        iconImageView.image = UIImage(systemName: systemImageName)
        if let name = valueImageName {
            valueImageView.isHidden = false
            valueImageView.image = UIImage(systemName: name)
            valueImageView.tintColor = valueImageTintColor ?? ThemeColor.text
        } else {
            valueImageView.isHidden = true
            valueImageView.image = nil
        }
    }
}
