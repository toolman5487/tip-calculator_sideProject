//
//  IndicatorCapsuleCell.swift
//  tip-calculator
//
//  Created by Willy Hsu on 2026/3/17.
//

import UIKit
import SnapKit

final class IndicatorCapsuleCell: UICollectionViewCell {

    static let reuseId = "IndicatorCapsuleCell"

    private let label: UILabel = {
        let label = UILabel()
        label.font = ThemeFont.demiBold(Ofsize: 16)
        label.textAlignment = .center
        label.textColor = .label
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(label)
        label.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        contentView.applyShadowStyle()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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

    func configure(title: String, isSelected: Bool) {
        label.text = title
        setSelected(isSelected)
    }

    func setSelected(_ selected: Bool) {
        if selected {
            contentView.backgroundColor = ThemeColor.selected
            label.textColor = .systemBackground
        } else {
            contentView.backgroundColor = .systemBackground
            label.textColor = .label
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
}
