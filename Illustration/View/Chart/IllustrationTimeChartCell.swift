//
//  IllustrationTimeChartCell.swift
//  tip-calculator
//

import DGCharts
import UIKit
import SnapKit

final class IllustrationTimeChartCell: UICollectionViewCell {

    static let reuseId = "IllustrationTimeChartCell"

    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()

    private let emptyStateView: EmptyStateView = {
        let v = EmptyStateView()
        v.label.text = "尚無消費趨勢"
        return v
    }()

    private let chartView: BarChartView = {
        let chart = BarChartView()
        chart.legend.enabled = false
        chart.rightAxis.enabled = false
        chart.xAxis.labelPosition = .bottom
        chart.xAxis.drawGridLinesEnabled = false
        chart.leftAxis.axisMinimum = 0
        chart.pinchZoomEnabled = false
        chart.scaleXEnabled = false
        chart.scaleYEnabled = false
        chart.dragEnabled = false
        chart.doubleTapToZoomEnabled = false
        chart.highlightPerTapEnabled = false
        return chart
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .clear
        contentView.addSubview(containerView)
        containerView.addSubview(chartView)
        containerView.addSubview(emptyStateView)
        chartView.isUserInteractionEnabled = false
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        chartView.snp.makeConstraints { make in
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

    func configure(data: [TrendChartItem], barColor: UIColor? = nil) {
        let hasData = !data.isEmpty && data.contains { $0.totalAmount > 0 }
        chartView.isHidden = !hasData
        emptyStateView.isHidden = hasData

        if hasData {
            emptyStateView.stop()
            let entries = data.enumerated().map { BarChartDataEntry(x: Double($0.offset), y: $0.element.totalAmount) }
            let set = BarChartDataSet(entries: entries)
            set.colors = [barColor ?? ThemeColor.selected]
            set.drawValuesEnabled = false
            let chartData = BarChartData(dataSet: set)
            chartView.data = chartData
            chartView.animate(yAxisDuration: 0.5, easingOption: .easeOutQuart)
            chartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: data.map { $0.label })
            chartView.xAxis.granularity = 1
            chartView.xAxis.labelFont = UIFont.systemFont(ofSize: 8)
        } else {
            emptyStateView.play()
        }
    }
}
