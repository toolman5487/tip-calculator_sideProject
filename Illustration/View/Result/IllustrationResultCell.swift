//
//  IllustrationResultCell.swift
//  tip-calculator
//
//  Created by Willy Hsu on 2026/3/6.
//

import Foundation
import UIKit
import SnapKit

final class IllustrationResultCell: UICollectionViewCell {

    static let reuseId = "IllustrationResultCell"

    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = false
        view.layer.shadowColor = UIColor.label.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowOpacity = 0.08
        view.layer.shadowRadius = 6
        return view
    }()

    private let headerLabel: UILabel = {
        LabelFactory.build(text: "個人消費總和", font: ThemeFont.demiBold(Ofsize: 20))
    }()

    private let mainValueLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        let text = NSMutableAttributedString(string: "$0", attributes: [.font: ThemeFont.bold(Ofsize: 48), .foregroundColor: UIColor.label])
        text.addAttributes([.font: ThemeFont.bold(Ofsize: 24)], range: NSRange(location: 0, length: 1))
        label.attributedText = text
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        return label
    }()

    private let horizontalLine: UIView = {
        let view = UIView()
        view.backgroundColor = ThemeColor.seperator
        return view
    }()

    private let averagePerRecordView = KPIItemView(title: "平均每筆消費", textAlignment: .left)
    private let recordCountView = KPIItemView(title: "消費筆數", textAlignment: .right)

    private lazy var hStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            averagePerRecordView,
            UIView(),
            recordCountView
        ])
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        return stack
    }()

    private lazy var vStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            headerLabel,
            mainValueLabel,
            horizontalLine,
            buildSpaceView(height: 0),
            hStackView
        ])
        stack.axis = .vertical
        stack.spacing = 8
        stack.distribution = .fillProportionally
        return stack
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .clear
        contentView.clipsToBounds = false
        contentView.addSubview(containerView)
        containerView.addSubview(vStackView)
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        vStackView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(24)
            make.bottom.equalToSuperview().offset(-24)
            make.leading.equalToSuperview().offset(24)
            make.trailing.equalToSuperview().offset(-24)
        }
        horizontalLine.snp.makeConstraints { make in
            make.height.equalTo(2)
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

    func configure(items: [KPICardItem]) {
        guard items.count >= 3 else { return }
        let mainValue = items[2].value
        let attributedText = NSMutableAttributedString(
            string: mainValue,
            attributes: [.font: ThemeFont.bold(Ofsize: 48), .foregroundColor: UIColor.label]
        )
        if mainValue.count > 1 {
            attributedText.addAttributes([.font: ThemeFont.bold(Ofsize: 24)], range: NSRange(location: 0, length: 1))
        }
        mainValueLabel.attributedText = attributedText
        averagePerRecordView.configure(value: items[1].value)
        recordCountView.configure(value: items[0].value)
    }

    private func buildSpaceView(height: CGFloat) -> UIView {
        let view = UIView()
        view.heightAnchor.constraint(equalToConstant: height).isActive = true
        return view
    }
}

// MARK: - KPIItemView

private final class KPIItemView: UIView {

    private let title: String
    private let textAlignment: NSTextAlignment

    private lazy var titleLabel: UILabel = {
        LabelFactory.build(text: title, font: ThemeFont.regular(Ofsize: 16), textColor: ThemeColor.text, textAlignment: textAlignment)
    }()

    private let valueLabel: UILabel = {
        let label = UILabel()
        label.textColor = ThemeColor.primary
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        return label
    }()

    private lazy var stackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [titleLabel, valueLabel])
        stack.axis = .vertical
        stack.distribution = .fillProportionally
        return stack
    }()

    init(title: String, textAlignment: NSTextAlignment = .center) {
        self.title = title
        self.textAlignment = textAlignment
        super.init(frame: .zero)
        valueLabel.textAlignment = textAlignment
        addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(value: String) {
        let attributedText = NSMutableAttributedString(
            string: value,
            attributes: [.font: ThemeFont.bold(Ofsize: 24)]
        )
        if value.count > 1, value.first == "$" {
            attributedText.addAttributes([.font: ThemeFont.bold(Ofsize: 16)], range: NSRange(location: 0, length: 1))
        }
        valueLabel.attributedText = attributedText
    }
}
