//
//  ChartDetailCategoryCapsuleCell.swift
//  tip-calculator
//
//  參考 IllustrationFilterOptionCell 樣式
//

import UIKit
import SnapKit

final class ChartDetailCategoryCapsuleCell: UICollectionViewCell {

    static let reuseId = "ChartDetailCategoryCapsuleCell"

    private let iconImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.tintColor = .label
        return iv
    }()

    override var isSelected: Bool {
        didSet {
            setSelected(isSelected)
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(iconImageView)
        iconImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(CGSize(width: 24, height: 24))
        }
        contentView.layer.masksToBounds = false
        contentView.layer.shadowColor = UIColor.black.cgColor
        contentView.layer.shadowOffset = CGSize(width: 0, height: 2)
        contentView.layer.shadowOpacity = 0.08
        contentView.layer.shadowRadius = 4
        setSelected(false)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(systemImageName: String, isSelected: Bool) {
        iconImageView.image = UIImage(systemName: systemImageName)
        setSelected(isSelected)
    }

    private func setSelected(_ selected: Bool) {
        if selected {
            contentView.backgroundColor = .label
            iconImageView.tintColor = .systemBackground
        } else {
            contentView.backgroundColor = .systemBackground
            iconImageView.tintColor = .label
        }
        let scale: CGFloat = selected ? 1.2 : 1.0
        UIView.animate(withDuration: 0.2,
                      delay: 0,
                      usingSpringWithDamping: 0.4,
                      initialSpringVelocity: 0.5,
                      options: [.allowUserInteraction, .beginFromCurrentState],
                      animations: {
            self.contentView.transform = CGAffineTransform(scaleX: scale, y: scale)
        }, completion: nil)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let radius = contentView.bounds.height / 2
        contentView.layer.cornerRadius = radius
        contentView.layer.shadowPath = UIBezierPath(roundedRect: contentView.bounds, cornerRadius: radius).cgPath
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        setSelected(false)
    }
}
