//
//  AccountDetailCategoryDistributionCell.swift
//  tip-calculator
//

import SnapKit
import UIKit

final class AccountDetailCategoryDistributionCell: UICollectionViewCell {

    static let reuseId = "AccountDetailCategoryDistributionCell"

    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 12
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
                color: BarChartRowBuilder.barColor(at: index)
            )
            rowsStackView.addArrangedSubview(row)
        }
    }

    private func makeRow(item: AccountDetailCategoryDistributionItem, color: UIColor) -> UIView {
        BarChartRowBuilder.makeRow(
            iconSystemName: item.systemImageName,
            iconTintColor: ThemeColor.selected,
            iconSize: 20,
            title: item.displayName,
            titleFont: ThemeFont.regular(Ofsize: 14),
            titleWidth: 80,
            valueText: "\(Int(round(item.percentage)))%",
            valueFont: ThemeFont.regular(Ofsize: 12),
            barHeight: 16,
            barFillColor: color,
            fillRatio: item.percentage / 100
        )
    }

    static func preferredHeight(itemCount: Int) -> CGFloat {
        guard itemCount > 0 else { return 16 * 2 + 220 }
        return 16 * 2 + CGFloat(itemCount) * 28 + CGFloat(max(0, itemCount - 1)) * 12
    }
}
