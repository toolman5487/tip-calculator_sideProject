//
//  CategoryOptionCell.swift
//  tip-calculator
//

import UIKit
import SnapKit

final class CategoryOptionCell: UICollectionViewCell {

    static let reuseId = "CategoryOptionCell"

    private static let iconConfig = UIImage.SymbolConfiguration(pointSize: 24, weight: .medium)

    private let iconImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.tintColor = .white
        return iv
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = ThemeColor.primary
        contentView.layer.cornerRadius = 12
        contentView.layer.masksToBounds = true
        contentView.addSubview(iconImageView)
        iconImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(32)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(category: Category, isSelected: Bool = false) {
        let imageName = category.systemImageName ?? "xmark.circle"
        iconImageView.image = UIImage(systemName: imageName, withConfiguration: Self.iconConfig)
        contentView.backgroundColor = isSelected ? ThemeColor.secondary : ThemeColor.primary
    }
}
