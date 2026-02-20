//
//  ChartDetailPieChartCell.swift
//  tip-calculator
//

import DGCharts
import UIKit
import SnapKit

final class ChartDetailPieChartCell: UICollectionViewCell {

    static let reuseId = "ChartDetailPieChartCell"

    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 12
        return view
    }()

    private let chartView: PieChartView = {
        let chart = PieChartView()
        chart.legend.enabled = false
        chart.drawHoleEnabled = true
        chart.holeRadiusPercent = 0.5
        chart.transparentCircleRadiusPercent = 0.55
        chart.transparentCircleColor = UIColor.systemBackground
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
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        chartView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(16)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(data: [PieChartSliceItem]) {
        let colors: [UIColor] = [
            .systemRed, .systemOrange, .systemYellow, .systemGreen,
            .systemTeal, .systemBlue, .systemPurple
        ]
        let entries = data.enumerated().map { index, item in
            PieChartDataEntry(value: item.value, label: item.label)
        }
        let set = PieChartDataSet(entries: entries)
        set.colors = (0..<entries.count).map { colors[$0 % colors.count] }
        set.drawValuesEnabled = true
        set.valueFont = UIFont.systemFont(ofSize: 10)
        set.valueTextColor = .label
        let chartData = PieChartData(dataSet: set)
        chartView.data = chartData
    }
}
