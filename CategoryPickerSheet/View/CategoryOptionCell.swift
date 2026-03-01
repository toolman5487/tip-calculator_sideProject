//
//  CategoryOptionCell.swift
//  tip-calculator
//

import UIKit
import SnapKit

final class CategoryOptionCell: UICollectionViewCell {

    static let reuseId = "CategoryOptionCell"

    private static let iconConfig = UIImage.SymbolConfiguration(pointSize: 32, weight: .bold)

    private let iconImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.tintColor = .systemBackground
        return iv
    }()

    private let iconContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = ThemeColor.primary
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        return view
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .semibold)
        label.textColor = .label
        label.textAlignment = .center
        label.numberOfLines = 2
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .clear
        contentView.addSubview(iconContainerView)
        iconContainerView.addSubview(iconImageView)
        contentView.addSubview(titleLabel)
        iconContainerView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
            make.width.height.equalTo(56)
        }
        iconImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(32)
        }
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(iconContainerView.snp.bottom).offset(4)
            make.leading.trailing.equalTo(iconContainerView)
            make.bottom.equalToSuperview()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(category: Category, isSelected: Bool = false) {
        let imageName = category.systemImageName ?? "xmark.circle"
        iconImageView.image = UIImage(systemName: imageName, withConfiguration: Self.iconConfig)
        titleLabel.text = category.displayName
        iconContainerView.backgroundColor = isSelected ? ThemeColor.secondary : ThemeColor.primary
    }
}
