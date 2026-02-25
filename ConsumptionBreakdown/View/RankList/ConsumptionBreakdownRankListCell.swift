//
//  ConsumptionBreakdownRankListCell.swift
//  tip-calculator
//
//  Created by Willy Hsu on 2026/2/25.
//

import UIKit
import SnapKit

final class ConsumptionBreakdownRankListCell: UICollectionViewCell {

    static let reuseId = "ConsumptionBreakdownRankListCell"

    private var displays: [ConsumptionBreakdownRankItemDisplay] = []

    var onRowTap: ((Int) -> Void)?

    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        return view
    }()

    private let tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.backgroundColor = .clear
        tv.isScrollEnabled = false
        tv.separatorStyle = .singleLine
        return tv
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .clear
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        contentView.addSubview(containerView)
        containerView.addSubview(tableView)

        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(RankListRowCell.self, forCellReuseIdentifier: RankListRowCell.reuseId)
        tableView.rowHeight = 80
    }

    func configure(with displays: [ConsumptionBreakdownRankItemDisplay]) {
        self.displays = displays
        tableView.reloadData()
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate

extension ConsumptionBreakdownRankListCell: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        displays.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: RankListRowCell.reuseId, for: indexPath) as! RankListRowCell
        cell.configure(with: displays[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        onRowTap?(indexPath.row)
    }
}

// MARK: - RankListRowCell (PerCapitaRecordCell 樣式)

private final class RankListRowCell: UITableViewCell {

    static let reuseId = "RankListRowCell"

    private let titleLabel = LabelFactory.build(text: "", font: ThemeFont.demiBold(Ofsize: 16))
    private let dateLabel = LabelFactory.build(text: "", font: ThemeFont.regular(Ofsize: 12))
    private let amountLabel = LabelFactory.build(text: "", font: ThemeFont.bold(Ofsize: 24))
    private let peopleLabel = LabelFactory.build(text: "", font: ThemeFont.regular(Ofsize: 12))

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        titleLabel.textColor = ThemeColor.text
        dateLabel.textColor = .secondaryLabel
        amountLabel.textColor = ThemeColor.text
        amountLabel.textAlignment = .right
        peopleLabel.textColor = .secondaryLabel
        peopleLabel.textAlignment = .right

        let leftStack = UIStackView(arrangedSubviews: [titleLabel, dateLabel])
        leftStack.axis = .vertical
        leftStack.spacing = 4

        let rightStack = UIStackView(arrangedSubviews: [amountLabel, peopleLabel])
        rightStack.axis = .vertical
        rightStack.alignment = .trailing
        rightStack.spacing = 4

        let horizontalStack = UIStackView(arrangedSubviews: [leftStack, rightStack])
        horizontalStack.axis = .horizontal
        horizontalStack.alignment = .center
        horizontalStack.distribution = .fill
        horizontalStack.spacing = 12

        contentView.addSubview(horizontalStack)
        horizontalStack.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(16)
        }

        selectionStyle = .default
    }

    func configure(with display: ConsumptionBreakdownRankItemDisplay) {
        titleLabel.text = display.title
        dateLabel.text = display.dateText
        amountLabel.text = display.amountText
        peopleLabel.text = display.peopleText
    }
}
