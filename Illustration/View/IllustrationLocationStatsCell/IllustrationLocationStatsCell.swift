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
        let colors: [UIColor] = [
            .systemBlue, .systemGreen, .systemPurple, .systemOrange, .systemTeal
        ]

        rowsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        for (index, item) in displayItems.enumerated() {
            let row = makeRow(
                name: item.name,
                count: item.count,
                totalCount: totalCount,
                color: colors[index % colors.count]
            )
            rowsStackView.addArrangedSubview(row)
        }
    }

    private func makeRow(name: String, count: Int, totalCount: Int, color: UIColor) -> UIView {
        let nameLabel = UILabel()
        nameLabel.text = name
        nameLabel.font = .systemFont(ofSize: 12)
        nameLabel.textColor = .label
        nameLabel.adjustsFontSizeToFitWidth = true
        nameLabel.minimumScaleFactor = 0.8
        nameLabel.lineBreakMode = .byTruncatingTail
        nameLabel.snp.makeConstraints { make in
            make.width.equalTo(90)
        }

        let valueLabel = UILabel()
        valueLabel.text = "\(count) 筆"
        valueLabel.font = .systemFont(ofSize: 12)
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
            make.width.equalTo(barBg.snp.width).multipliedBy(CGFloat(count) / CGFloat(totalCount))
        }

        let row = UIStackView(arrangedSubviews: [nameLabel, barBg, valueLabel])
        row.axis = .horizontal
        row.spacing = 8
        row.alignment = .center
        row.distribution = .fill

        barBg.snp.makeConstraints { make in
            make.height.equalTo(20)
        }

        return row
    }
}
