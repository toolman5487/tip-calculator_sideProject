//
//  AchievementTierCell.swift
//  tip-calculator
//
//  Created by Willy Hsu on 2026/3/12.
//

import DGCharts
import SnapKit
import UIKit

final class AchievementTierCell: UICollectionViewCell {
    
    static let reuseId = "AchievementTierCell"
    
    private var lastShadowBounds: CGRect = .zero
    
    private let containerView: UIView = {
        let v = UIView()
        v.backgroundColor = .secondarySystemGroupedBackground
        v.layer.cornerRadius = 12
        v.applyCardShadowStyle()
        return v
    }()
    
    private let titleLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 24, weight: .bold)
        l.textAlignment = .center
        l.textColor = .label
        return l
    }()
    
    private let progressRatioLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 16, weight: .regular)
        l.textAlignment = .center
        l.textColor = .secondaryLabel
        return l
    }()
    
    private let chartView: PieChartView = {
        let chart = PieChartView()
        chart.legend.enabled = false
        chart.drawHoleEnabled = true
        chart.holeRadiusPercent = 0.65
        chart.transparentCircleRadiusPercent = 0.7
        chart.transparentCircleColor = .secondarySystemGroupedBackground
        chart.holeColor = .secondarySystemGroupedBackground
        chart.highlightPerTapEnabled = false
        chart.rotationEnabled = false
        chart.rotationAngle = -90
        chart.isUserInteractionEnabled = false
        chart.drawEntryLabelsEnabled = false
        chart.usePercentValuesEnabled = false
        chart.drawCenterTextEnabled = false
        return chart
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .clear
        contentView.clipsToBounds = false
        contentView.addSubview(containerView)
        containerView.addSubview(chartView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(progressRatioLabel)
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        chartView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(16)
            make.bottom.equalTo(progressRatioLabel.snp.top).offset(-8)
            make.centerX.equalToSuperview()
            make.width.lessThanOrEqualToSuperview().inset(16)
            make.width.equalTo(chartView.snp.height)
        }
        titleLabel.snp.makeConstraints { make in
            make.center.equalTo(chartView)
        }
        progressRatioLabel.snp.makeConstraints { make in
            make.bottom.equalToSuperview().inset(8)
            make.centerX.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(16)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let b = containerView.bounds
        guard b.width > 0, b.height > 0 else { return }
        guard b != lastShadowBounds else { return }
        lastShadowBounds = b
        containerView.layer.shadowPath = UIBezierPath(roundedRect: b, cornerRadius: 12).cgPath
    }
    
    func configure(section: AccountDetailAchievementSection) {
        titleLabel.text = section.title
        progressRatioLabel.text = section.progressRangeText
        let progressClamped = min(1, max(0, section.gaugeProgress))
        let progressColor = section.personalTotal >= section.maxTarget ? ThemeColor.trendDown : .systemBlue
        let (entries, colors): ([PieChartDataEntry], [UIColor]) = switch progressClamped {
        case ...0:
            ([PieChartDataEntry(value: 1, label: nil)], [.quaternarySystemFill])
        case 1...:
            ([PieChartDataEntry(value: 1, label: nil)], [progressColor])
        default:
            (
                [
                    PieChartDataEntry(value: progressClamped, label: nil),
                    PieChartDataEntry(value: 1 - progressClamped, label: nil)
                ],
                [progressColor, .quaternarySystemFill]
            )
        }
        let set = PieChartDataSet(entries: entries)
        set.colors = colors
        set.drawValuesEnabled = false
        set.sliceSpace = 0
        set.selectionShift = 0
        chartView.data = PieChartData(dataSet: set)
        chartView.notifyDataSetChanged()
        chartView.setNeedsDisplay()
    }
}
