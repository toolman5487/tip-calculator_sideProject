//
//  BarChartRowBuilder.swift
//  tip-calculator
//

import SnapKit
import UIKit

enum BarChartRowBuilder {
    static let defaultBarColors: [UIColor] = [
        UIColor.systemRed,
        UIColor.systemOrange,
        UIColor.systemYellow,
        UIColor.systemGreen,
        UIColor.systemBlue,
        UIColor.systemIndigo,
        UIColor.systemPurple
    ]

    static func barColor(at index: Int, colors: [UIColor] = defaultBarColors) -> UIColor {
        guard !colors.isEmpty else { return .systemBlue }
        let safeIndex = ((index % colors.count) + colors.count) % colors.count
        return colors[safeIndex]
    }

    static func makeRow(
        iconSystemName: String?,
        iconTintColor: UIColor,
        iconSize: CGFloat,
        title: String,
        titleFont: UIFont,
        titleWidth: CGFloat,
        valueText: String,
        valueFont: UIFont,
        barHeight: CGFloat,
        barFillColor: UIColor,
        fillRatio: CGFloat
    ) -> UIView {
        let clampedRatio = max(0, min(1, fillRatio))

        let iconView = UIImageView()
        iconView.tintColor = iconTintColor
        iconView.contentMode = .scaleAspectFit
        if let iconSystemName {
            iconView.image = UIImage(systemName: iconSystemName)
            iconView.isHidden = false
        } else {
            iconView.isHidden = true
        }

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = titleFont
        titleLabel.textColor = .label
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.8
        titleLabel.lineBreakMode = .byTruncatingTail
        titleLabel.snp.makeConstraints { make in
            make.width.equalTo(titleWidth)
        }

        let valueLabel = UILabel()
        valueLabel.text = valueText
        valueLabel.font = valueFont
        valueLabel.textColor = .secondaryLabel
        valueLabel.setContentHuggingPriority(.required, for: .horizontal)

        let barBg = UIView()
        barBg.backgroundColor = .quaternarySystemFill
        barBg.layer.cornerRadius = 4
        barBg.clipsToBounds = true

        let barFill = UIView()
        barFill.backgroundColor = barFillColor
        barFill.layer.cornerRadius = 4
        barBg.addSubview(barFill)
        barFill.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
            make.width.equalTo(barBg.snp.width).multipliedBy(clampedRatio)
        }

        let arranged: [UIView] = iconSystemName == nil ? [titleLabel, barBg, valueLabel] : [iconView, titleLabel, barBg, valueLabel]
        let row = UIStackView(arrangedSubviews: arranged)
        row.axis = .horizontal
        row.spacing = 8
        row.alignment = .center
        row.distribution = .fill

        iconView.snp.makeConstraints { make in
            make.width.height.equalTo(iconSize)
        }
        barBg.snp.makeConstraints { make in
            make.height.equalTo(barHeight)
        }

        return row
    }
}
