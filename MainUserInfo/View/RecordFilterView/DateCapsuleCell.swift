//
//  DateCapsuleCell.swift
//  tip-calculator
//

import UIKit
import SnapKit

final class DateCapsuleCell: UICollectionViewCell {

    static let reuseId = "DateCapsuleCell"

    private let label: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
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
        contentView.backgroundColor = .systemBackground
        contentView.layer.borderColor = UIColor.label.cgColor
        contentView.layer.borderWidth = 1.5
        contentView.layer.masksToBounds = true
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.layer.cornerRadius = contentView.bounds.height / 2
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
            contentView.backgroundColor = .label
            label.textColor = .systemBackground
            contentView.layer.borderWidth = 0
        } else {
            contentView.backgroundColor = .systemBackground
            label.textColor = .label
            contentView.layer.borderWidth = 1.5
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
