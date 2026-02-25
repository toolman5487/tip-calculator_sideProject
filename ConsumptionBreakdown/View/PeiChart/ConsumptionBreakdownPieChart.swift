//
//  ConsumptionBreakdownPieChartCell.swift
//  tip-calculator
//

import DGCharts
import UIKit
import SnapKit

final class ConsumptionBreakdownPieChart: UICollectionReusableView {

    static let reuseId = "ConsumptionBreakdownPieChartCell"

    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        return view
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
        backgroundColor = .clear
        addSubview(containerView)
        containerView.addSubview(chartView)
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        chartView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.left.right.equalToSuperview().inset(16)
            make.top.bottom.equalToSuperview().inset(8)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(data: [PieChartSliceItem]) {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.maximumFractionDigits = 0
        formatter.multiplier = 1.0
        let colors: [UIColor] = [
            .systemRed, .systemOrange, .systemYellow, .systemGreen,
            .systemTeal, .systemBlue, .systemPurple
        ]
        let entries = data.map { PieChartDataEntry(value: $0.value, label: $0.label) }
        let set = PieChartDataSet(entries: entries)
        set.colors = (0..<entries.count).map { colors[$0 % colors.count] }
        set.drawValuesEnabled = true
        set.valueFont = UIFont.systemFont(ofSize: 10)
        set.valueTextColor = .label
        let chartData = PieChartData(dataSet: set)
        chartView.data = chartData
        chartData.setValueFormatter(DefaultValueFormatter(formatter: formatter))
        chartView.animate(yAxisDuration: 0.5, easingOption: .easeOutExpo)
    }
}
