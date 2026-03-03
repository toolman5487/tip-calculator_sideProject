//
//  IllustrationLocationStatsCell.swift
//  tip-calculator
//
//  Created by Willy Hsu on 2026/3/2.
//

import DGCharts
import UIKit
import SnapKit

final class IllustrationLocationStatsCell: UICollectionViewCell {

    static let reuseId = "IllustrationLocationStatsCell"
    static let chartHeight: CGFloat = 220

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

    private let chartView: PieChartView = {
        let chart = PieChartView()
        chart.legend.enabled = false
        chart.drawHoleEnabled = true
        chart.holeRadiusPercent = 0.5
        chart.transparentCircleRadiusPercent = 0.55
        chart.transparentCircleColor = UIColor.systemBackground
        chart.usePercentValuesEnabled = true
        chart.highlightPerTapEnabled = false
        chart.rotationEnabled = false
        chart.isUserInteractionEnabled = false
        return chart
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .clear
        contentView.addSubview(containerView)
        containerView.addSubview(chartView)
        containerView.addSubview(emptyStateView)
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        chartView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.left.right.equalToSuperview().inset(16)
            make.top.bottom.equalToSuperview().inset(8)
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
        chartView.isHidden = !hasData
        emptyStateView.isHidden = hasData

        guard hasData else {
            emptyStateView.play()
            return
        }

        emptyStateView.stop()

        let colors: [UIColor] = [
            .systemRed, .systemOrange, .systemYellow, .systemGreen,
            .systemTeal, .systemBlue, .systemPurple, .systemPink
        ]
        let entries = data.map { PieChartDataEntry(value: Double($0.count), label: $0.name) }
        let set = PieChartDataSet(entries: entries)
        set.colors = (0..<entries.count).map { colors[$0 % colors.count] }
        set.drawValuesEnabled = true
        set.valueFont = .systemFont(ofSize: 10)
        set.valueTextColor = .label

        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.maximumFractionDigits = 0
        formatter.multiplier = 1.0

        let chartData = PieChartData(dataSet: set)
        chartView.data = chartData
        chartData.setValueFormatter(DefaultValueFormatter(formatter: formatter))
        chartView.animate(yAxisDuration: 0.5, easingOption: .easeOutExpo)
    }
}
