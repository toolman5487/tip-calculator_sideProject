//
//  AccountDetailStatCardCell.swift
//  tip-calculator
//

import SnapKit
import UIKit

final class AccountDetailStatCardCell: UICollectionViewCell {

    static let reuseId = "AccountDetailStatCardCell"

    private var lastShadowBounds: CGRect = .zero

    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.applyCardShadowStyle()
        return view
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = ThemeFont.regular(Ofsize: 16)
        label.textColor = .secondaryLabel
        label.numberOfLines = 2
        label.textAlignment = .center
        label.adjustsFontForContentSizeCategory = true
        return label
    }()

    private let valueLabel: UILabel = {
        let label = UILabel()
        label.font = ThemeFont.bold(Ofsize: 20)
        label.textColor = .label
        label.textAlignment = .center
        label.adjustsFontForContentSizeCategory = true
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.4
        label.numberOfLines = 1
        return label
    }()

    private let valueImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.tintColor = ThemeColor.selected
        return iv
    }()

    private let valueStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 8
        return stack
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .clear
        contentView.clipsToBounds = false
        contentView.addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(valueStackView)
        valueStackView.addArrangedSubview(valueImageView)
        valueStackView.addArrangedSubview(valueLabel)

        containerView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.right.left.equalToSuperview()
        }
        valueStackView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-8)
        }
        titleLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(8)
            make.top.equalTo(valueStackView.snp.bottom).offset(12)
        }
        valueImageView.snp.makeConstraints { make in
            make.width.height.equalTo(32)
        }
        valueLabel.snp.makeConstraints { make in
            make.leading.trailing.lessThanOrEqualTo(containerView).inset(8)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let b = containerView.bounds
        guard b.width > 0, b.height > 0 else { return }
        guard b != lastShadowBounds else { return }
        lastShadowBounds = b
        containerView.layer.shadowPath = UIBezierPath(roundedRect: b, cornerRadius: 12).cgPath
    }

    func configure(title: String, value: String, systemImageName: String? = nil) {
        titleLabel.text = title
        valueLabel.text = value
        if let name = systemImageName {
            valueImageView.isHidden = false
            valueImageView.image = UIImage(systemName: name)
            valueLabel.isHidden = true
        } else {
            valueImageView.isHidden = true
            valueImageView.image = nil
            valueLabel.isHidden = false
        }
    }
}
