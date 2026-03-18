//
//  IllustrationLocationStatsCell.swift
//  tip-calculator
//
//  Created by Willy Hsu on 2026/3/2.
//

import UIKit
import SnapKit

final class IllustrationLocationStatsCell: UICollectionViewCell {

    static let reuseId = "IllustrationLocationStatsCell"
    private var lastSignature: String?
    private static let emptyHeight: CGFloat = 260
    private static let threshold = 0.01

    static func displayItems(from data: [LocationStatItem]) -> [LocationStatItem] {
        let totalCount = max(1, data.reduce(0) { $0 + $1.count })
        let main = data.filter { Double($0.count) / Double(totalCount) >= threshold }
        let othersCount = data.filter { Double($0.count) / Double(totalCount) < threshold }.reduce(0) { $0 + $1.count }
        return othersCount > 0 ? main + [LocationStatItem(name: "其他", count: othersCount)] : main
    }

    static func preferredHeight(itemCount: Int) -> CGFloat {
        if itemCount == 0 { return emptyHeight }
        let rowHeight: CGFloat = 20
        let spacing: CGFloat = 10
        let inset: CGFloat = 32
        return inset + CGFloat(itemCount) * rowHeight + CGFloat(max(0, itemCount - 1)) * spacing
    }

    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
        return view
    }()

    private let emptyStateView: EmptyStateView = {
        let v = EmptyStateView()
        v.label.text = "尚無地區資料"
        return v
    }()

    private let rowsStackView: UIStackView = {
        let v = UIStackView()
        v.axis = .vertical
        v.spacing = 10
        v.alignment = .fill
        v.distribution = .fill
        return v
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .clear
        contentView.addSubview(containerView)
        containerView.addSubview(rowsStackView)
        containerView.addSubview(emptyStateView)
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        rowsStackView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().inset(16).priority(.init(999))
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
        lastSignature = nil
    }

    func configure(data: [LocationStatItem]) {
        let hasData = !data.isEmpty
        rowsStackView.isHidden = !hasData
        emptyStateView.isHidden = hasData

        guard hasData else {
            emptyStateView.play()
            return
        }

        emptyStateView.stop()

        let displayItems = Self.displayItems(from: data)
        let totalCount = max(1, data.reduce(0) { $0 + $1.count })
        let signature = displayItems.map { "\($0.name)=\($0.count)" }.joined(separator: "|") + "|\(totalCount)"
        guard signature != lastSignature else { return }
        lastSignature = signature

        rowsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        for (index, item) in displayItems.enumerated() {
            let row = makeRow(
                name: item.name,
                count: item.count,
                totalCount: totalCount,
                color: BarChartRowBuilder.barColor(at: index)
            )
            rowsStackView.addArrangedSubview(row)
        }
    }

    private func makeRow(name: String, count: Int, totalCount: Int, color: UIColor) -> UIView {
        BarChartRowBuilder.makeRow(
            iconSystemName: nil,
            iconTintColor: .clear,
            iconSize: 0,
            title: name,
            titleFont: .systemFont(ofSize: 12),
            titleWidth: 90,
            valueText: "\(count) 筆",
            valueFont: .systemFont(ofSize: 12),
            barHeight: 20,
            barFillColor: color,
            fillRatio: totalCount > 0 ? CGFloat(count) / CGFloat(totalCount) : 0
        )
    }
}
