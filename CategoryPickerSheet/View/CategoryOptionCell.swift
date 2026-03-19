//
//  CategoryOptionCell.swift
//  tip-calculator
//

import UIKit
import SnapKit

final class CategoryOptionCell: UICollectionViewCell {

    static let reuseId = "CategoryOptionCell"

    private static let iconConfig = UIImage.SymbolConfiguration(pointSize: 32, weight: .bold)

    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.applyCardShadowStyle()
        return view
    }()

    private let iconImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.tintColor = ThemeColor.primary
        return iv
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .semibold)
        label.textColor = ThemeColor.primary
        label.textAlignment = .center
        label.numberOfLines = 1
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        label.setContentHuggingPriority(.required, for: .vertical)
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .clear
        contentView.addSubview(containerView)
        containerView.addSubview(iconImageView)
        containerView.addSubview(titleLabel)

        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(4)
        }
        iconImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.centerX.equalToSuperview()
            make.size.equalTo(32)
        }
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(iconImageView.snp.bottom)
            make.leading.trailing.equalToSuperview().inset(4)
            make.bottom.equalToSuperview().inset(4)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(category: Category, isSelected: Bool = false) {
        let imageName = category.systemImageName ?? "xmark.circle"
        iconImageView.image = UIImage(systemName: imageName, withConfiguration: Self.iconConfig)
        titleLabel.text = category.displayName
        iconImageView.tintColor = isSelected ? ThemeColor.selected : ThemeColor.primary
        titleLabel.textColor = isSelected ? ThemeColor.selected : ThemeColor.primary
    }
}
