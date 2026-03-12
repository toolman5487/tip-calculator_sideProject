//
//  AccountDetailCategoryDistributionCell.swift
//  tip-calculator
//

import SnapKit
import UIKit

final class AccountDetailCategoryDistributionCell: UICollectionViewCell {

    static let reuseId = "AccountDetailCategoryDistributionCell"

    private static let barColors: [UIColor] = [
        ThemeColor.trendUp,
        ThemeColor.trendDown,
        ThemeColor.trendFlat,
        UIColor(hexString: "D97706"),
        UIColor(hexString: "6366F1")
    ]

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

    private let rowsStackView: UIStackView = {
        let v = UIStackView()
        v.axis = .vertical
        v.spacing = 12
        v.alignment = .fill
        v.distribution = .fillEqually
        return v
    }()

    private let emptyStateView: EmptyStateView = {
        let v = EmptyStateView()
        v.label.text = "尚無消費分布"
        return v
    }()

    private var lastDisplayedItems: [AccountDetailCategoryDistributionItem] = []

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .clear
        contentView.addSubview(containerView)
        containerView.addSubview(rowsStackView)
        containerView.addSubview(emptyStateView)
        containerView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.left.right.equalToSuperview().inset(16)
        }
        rowsStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(16)
        }
        emptyStateView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        emptyStateView.stop()
    }

    func configure(items: [AccountDetailCategoryDistributionItem]) {
        let displayItems = Array(items.prefix(5))
        let hasData = !displayItems.isEmpty
        rowsStackView.isHidden = !hasData
        emptyStateView.isHidden = hasData
        guard hasData else {
            emptyStateView.play()
            lastDisplayedItems = []
            return
        }
        emptyStateView.stop()
        guard displayItems != lastDisplayedItems else { return }
        lastDisplayedItems = displayItems
        rowsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for (index, item) in displayItems.enumerated() {
            let row = makeRow(
                item: item,
                color: Self.barColors[index % Self.barColors.count]
            )
            rowsStackView.addArrangedSubview(row)
        }
    }

    private func makeRow(item: AccountDetailCategoryDistributionItem, color: UIColor) -> UIView {
        let iconView = UIImageView()
        iconView.tintColor = ThemeColor.selected
        iconView.contentMode = .scaleAspectFit
        if let name = item.systemImageName {
            iconView.image = UIImage(systemName: name)
            iconView.isHidden = false
        } else {
            iconView.isHidden = true
        }

        let nameLabel = UILabel()
        nameLabel.text = item.displayName
        nameLabel.font = ThemeFont.regular(Ofsize: 14)
        nameLabel.textColor = .label
        nameLabel.adjustsFontSizeToFitWidth = true
        nameLabel.minimumScaleFactor = 0.8
        nameLabel.lineBreakMode = .byTruncatingTail
        nameLabel.snp.makeConstraints { make in
            make.width.equalTo(80)
        }

        let valueLabel = UILabel()
        valueLabel.text = "\(Int(round(item.percentage)))%"
        valueLabel.font = ThemeFont.regular(Ofsize: 12)
        valueLabel.textColor = .secondaryLabel
        valueLabel.setContentHuggingPriority(.required, for: .horizontal)

        let barBg = UIView()
        barBg.backgroundColor = .quaternarySystemFill
        barBg.layer.cornerRadius = 4
        barBg.clipsToBounds = true

        let barFill = UIView()
        barFill.backgroundColor = color
        barFill.layer.cornerRadius = 4
        barBg.addSubview(barFill)
        barFill.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
            make.width.equalTo(barBg.snp.width).multipliedBy(min(1, item.percentage / 100))
        }

        let barStack = UIStackView(arrangedSubviews: [iconView, nameLabel, barBg, valueLabel])
        barStack.axis = .horizontal
        barStack.spacing = 8
        barStack.alignment = .center
        barStack.distribution = .fill
        iconView.snp.makeConstraints { make in
            make.width.height.equalTo(20)
        }
        barBg.snp.makeConstraints { make in
            make.height.equalTo(16)
        }
        return barStack
    }

    static func preferredHeight(itemCount: Int) -> CGFloat {
        guard itemCount > 0 else { return 16 * 2 + 220 }
        return 16 * 2 + CGFloat(itemCount) * 28 + CGFloat(max(0, itemCount - 1)) * 12
    }
}
