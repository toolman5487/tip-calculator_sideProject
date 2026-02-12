//
//  IllustrationChartCell.swift
//  tip-calculator
//

import DGCharts
import UIKit
import SnapKit

final class IllustrationChartCell: UICollectionViewCell {

    static let reuseId = "IllustrationChartCell"

    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 12
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowOpacity = 0.08
        view.layer.shadowRadius = 6
        return view
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = ThemeFont.demiBold(Ofsize: 16)
        label.textColor = ThemeColor.text
        return label
    }()

    private let chartView: BarChartView = {
        let chart = BarChartView()
        chart.legend.enabled = false
        chart.rightAxis.enabled = false
        chart.xAxis.labelPosition = .bottom
        chart.xAxis.drawGridLinesEnabled = false
        chart.leftAxis.axisMinimum = 0
        return chart
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .clear
        contentView.addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(chartView)

        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(16)
        }
        titleLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().inset(16)
        }
        chartView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.leading.trailing.bottom.equalToSuperview().inset(16)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configureAmountRange(title: String, data: [AmountRangeChartItem]) {
        titleLabel.text = title
        
        let entries = data.enumerated().map { BarChartDataEntry(x: Double($0.offset), y: Double($0.element.count)) }
        let set = BarChartDataSet(entries: entries)
        set.colors = [ThemeColor.secondary]
        set.drawValuesEnabled = true
        set.valueFont = UIFont.systemFont(ofSize: 10)
        
        let chartData = BarChartData(dataSet: set)
        chartView.data = chartData
        chartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: data.map { $0.rangeLabel })
        chartView.xAxis.granularity = 1
        chartView.xAxis.labelFont = UIFont.systemFont(ofSize: 10)
        chartView.animate(yAxisDuration: 0.4)
    }

    func configureTimeChart(title: String, data: [TrendChartItem]) {
        titleLabel.text = title
        
        let entries = data.enumerated().map { BarChartDataEntry(x: Double($0.offset), y: $0.element.totalAmount) }
        let set = BarChartDataSet(entries: entries)
        set.colors = [ThemeColor.primary]
        set.drawValuesEnabled = false
        
        let chartData = BarChartData(dataSet: set)
        chartView.data = chartData
        chartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: data.map { $0.label })
        chartView.xAxis.granularity = 1
        chartView.xAxis.labelFont = UIFont.systemFont(ofSize: 10)
        chartView.animate(yAxisDuration: 0.4)
    }
}
