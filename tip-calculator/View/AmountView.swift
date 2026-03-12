//
//  AmountView.swift
//  tip-calculator
//
//  Created by Willy Hsu on 2025/3/29.
//

import SnapKit
import UIKit

final class AmountView: UIView {

    // MARK: - Properties

    private let title: String
    private let textAlignment: NSTextAlignment
    private let amountLabelIdentifier: String

    // MARK: - UI Components

    private lazy var titleLabel: UILabel = {
        LabelFactory.build(text: title, font: ThemeFont.regular(Ofsize: 18), textColor: ThemeColor.text, textAlignment: textAlignment)
    }()

    private lazy var amountLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = textAlignment
        label.textColor = ThemeColor.primary
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.4
        let text = NSMutableAttributedString(string: "$0", attributes: [.font: ThemeFont.bold(Ofsize: 24)])
        text.addAttributes([.font: ThemeFont.bold(Ofsize: 16)], range: NSRange(location: 0, length: 1))
        label.attributedText = text
        label.accessibilityIdentifier = amountLabelIdentifier
        return label
    }()

    private lazy var vStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            titleLabel,
            amountLabel
        ])
        stack.axis = .vertical
        return stack
    }()

    // MARK: - Lifecycle

    init(title: String, textAlignment: NSTextAlignment, amountLabelIdentifier: String) {
        self.title = title
        self.textAlignment = textAlignment
        self.amountLabelIdentifier = amountLabelIdentifier
        super.init(frame: .zero)
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Configuration

    func configure(amount: Double) {
        let text = NSMutableAttributedString(
            string: amount.currencyFormatted,
            attributes: [.font: ThemeFont.bold(Ofsize: 24)])
        text.addAttributes([.font: ThemeFont.bold(Ofsize: 16)], range: NSMakeRange(0, 1))
        amountLabel.attributedText = text
    }

    // MARK: - Setup

    private func setupLayout() {
        addSubview(vStackView)
        vStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
