//
//  ResultDetailViewController.swift
//  tip-calculator
//
//  Created by Willy Hsu on 2026/2/6.
//

import UIKit
import SnapKit

@MainActor
final class ResultDetailViewController: UIViewController {

    private let item: RecordDisplayItem

    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12
        return stack
    }()

    init(item: RecordDisplayItem) {
        self.item = item
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ThemeColor.bg
        title = "消費明細"
        setupViews()
    }

    private func setupViews() {
        view.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(20)
        }

        addRow(title: "時間", value: item.dateText)
        addRow(title: "總金額", value: item.totalBillText)
        addRow(title: "帳單金額", value: item.billText)
        addRow(title: "小費", value: item.totalTipText)
        addRow(title: "每人應付", value: item.amountPerPersonText)
        addRow(title: "分攤人數", value: item.splitText)
        addRow(title: "小費設定", value: item.tipDisplayText)
        if !item.addressText.isEmpty {
            addRow(title: "消費地點", value: item.addressText)
        }
        stackView.addArrangedSubview(UIView())
    }

    private func addRow(title: String, value: String) {
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = ThemeFont.demiBold(Ofsize: 14)
        titleLabel.textColor = .secondaryLabel

        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.font = ThemeFont.bold(Ofsize: 18)
        valueLabel.textColor = ThemeColor.text
        valueLabel.numberOfLines = 0

        let vStack = UIStackView(arrangedSubviews: [titleLabel, valueLabel])
        vStack.axis = .vertical
        vStack.spacing = 4

        stackView.addArrangedSubview(vStack)
    }
}

