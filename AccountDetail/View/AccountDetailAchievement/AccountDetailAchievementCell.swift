//
//  AccountDetailAchievementCell.swift
//  tip-calculator
//

import SnapKit
import UIKit

final class AccountDetailAchievementCell: UICollectionViewCell {

    static let reuseId = "AccountDetailAchievementCell"

    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 12
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowOpacity = 0.1
        view.layer.shadowRadius = 8
        return view
    }()

    private let contentStackView: UIStackView = {
        let v = UIStackView()
        v.axis = .vertical
        v.spacing = 12
        v.alignment = .fill
        v.distribution = .fillEqually
        return v
    }()

    private var lastDisplayedItems: [AccountDetailAchievementItem] = []

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .clear
        contentView.addSubview(containerView)
        containerView.addSubview(contentStackView)

        containerView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.left.right.equalToSuperview().inset(16)
        }
        contentStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(16)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(items: [AccountDetailAchievementItem]) {
        guard items != lastDisplayedItems else { return }
        lastDisplayedItems = items
        contentStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for item in items {
            let row = makeRow(item: item)
            contentStackView.addArrangedSubview(row)
        }
    }


    private func makeRow(item: AccountDetailAchievementItem) -> UIView {
        let nameLabel = UILabel()
        nameLabel.text = item.displayName
        nameLabel.font = ThemeFont.regular(Ofsize: 14)
        nameLabel.textColor = item.isCompleted ? ThemeColor.trendDown : .label
        nameLabel.snp.makeConstraints { make in
            make.width.equalTo(56)
        }

        let valueLabel = UILabel()
        if item.isCompleted {
            valueLabel.text = "達成"
            valueLabel.textColor = ThemeColor.trendDown
        } else {
            let pct = Int(round(item.progress * 100))
            valueLabel.text = "\(pct)%"
            valueLabel.textColor = .secondaryLabel
        }
        valueLabel.font = ThemeFont.regular(Ofsize: 12)
        valueLabel.setContentHuggingPriority(.required, for: .horizontal)

        let barBg = UIView()
        barBg.backgroundColor = .quaternarySystemFill
        barBg.layer.cornerRadius = 4
        barBg.clipsToBounds = true

        let barFill = UIView()
        barFill.backgroundColor = item.isCompleted ? ThemeColor.trendDown : ThemeColor.trendFlat
        barFill.layer.cornerRadius = 4
        barBg.addSubview(barFill)
        barFill.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
            make.width.equalTo(barBg.snp.width).multipliedBy(min(1, item.progress))
        }

        let barStack = UIStackView(arrangedSubviews: [nameLabel, barBg, valueLabel])
        barStack.axis = .horizontal
        barStack.spacing = 8
        barStack.alignment = .center
        barStack.distribution = .fill
        barBg.snp.makeConstraints { make in
            make.height.equalTo(16)
        }
        return barStack
    }

    static func preferredHeight(itemCount: Int) -> CGFloat {
        guard itemCount > 0 else {
            return 16 * 2 + 120
        }
        return 16 * 2
            + CGFloat(itemCount) * 28
            + CGFloat(max(0, itemCount - 1)) * 12
    }
}
