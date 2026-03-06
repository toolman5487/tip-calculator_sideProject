//
//  KPICardCell.swift
//  tip-calculator
//

import UIKit
import SnapKit

final class KPICardCell: UICollectionViewCell {

    static let reuseId = "KPICardCell"

    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.applyCardShadowStyle()
        return view
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = ThemeFont.regular(Ofsize: 16)
        label.textColor = .secondaryLabel
        return label
    }()

    private let valueLabel: UILabel = {
        let label = UILabel()
        label.font = ThemeFont.bold(Ofsize: 24)
        label.textColor = .label
        return label
    }()

    private let trendLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        return label
    }()

    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 6
        stack.alignment = .center
        return stack
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .clear
        contentView.clipsToBounds = false
        contentView.addSubview(containerView)
        containerView.addSubview(stackView)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(valueLabel)
        stackView.addArrangedSubview(trendLabel)
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        stackView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        guard containerView.bounds.width > 0, containerView.bounds.height > 0 else { return }
        containerView.layer.shadowPath = UIBezierPath(roundedRect: containerView.bounds, cornerRadius: 12).cgPath
    }

    func configure(title: String, value: String, trend: KPITrend? = nil, comparisonLabel: String? = nil) {
        titleLabel.text = title
        valueLabel.text = value
        if let trend = trend {
            trendLabel.isHidden = false
            trendLabel.attributedText = makeTrendAttributedString(trend: trend, comparisonText: comparisonLabel)
            valueLabel.textColor = trendColor(trend)
        } else {
            trendLabel.isHidden = true
            valueLabel.textColor = .label
        }
    }

    private func makeTrendAttributedString(trend: KPITrend, comparisonText: String?) -> NSAttributedString {
        let config = UIImage.SymbolConfiguration(pointSize: 10, weight: .bold)
        let iconName: String
        let color: UIColor
        switch trend {
        case .up:
            iconName = "arrowtriangle.up.fill"
            color = ThemeColor.trendUp
        case .down:
            iconName = "arrowtriangle.down.fill"
            color = ThemeColor.trendDown
        case .equal:
            iconName = "equal"
            color = ThemeColor.trendFlat
        }
        guard let iconImage = UIImage(systemName: iconName, withConfiguration: config)?
            .withTintColor(color, renderingMode: .alwaysOriginal) else {
            return NSAttributedString(string: comparisonText ?? "")
        }
        let font = ThemeFont.regular(Ofsize: 12)
        let textColor = UIColor.tertiaryLabel
        let iconSize = CGSize(width: 12, height: 12)
        let attachment = NSTextAttachment()
        attachment.image = iconImage
        attachment.bounds = CGRect(origin: CGPoint(x: 0, y: -2), size: iconSize)
        let iconAttr = NSAttributedString(attachment: attachment)
        let spacer = NSAttributedString(string: " ", attributes: [.font: font])
        let textAttr = NSAttributedString(
            string: comparisonText ?? "",
            attributes: [.font: font, .foregroundColor: textColor]
        )
        let result = NSMutableAttributedString()
        result.append(iconAttr)
        result.append(spacer)
        result.append(textAttr)
        return result
    }

    private func trendColor(_ trend: KPITrend) -> UIColor {
        switch trend {
        case .up: return ThemeColor.trendUp
        case .down: return ThemeColor.trendDown
        case .equal: return ThemeColor.trendFlat
        }
    }
}
