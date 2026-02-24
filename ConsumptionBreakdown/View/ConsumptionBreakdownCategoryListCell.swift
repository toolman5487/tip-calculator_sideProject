//
//  ConsumptionBreakdownCategoryListCell.swift
//  tip-calculator
//
//  Created by Willy Hsu on 2026/2/24.
//

import UIKit
import SnapKit

final class ConsumptionBreakdownCategoryListCell: UICollectionViewCell {

    static let reuseId = "ConsumptionBreakdownCategoryListCell"

    private var displays: [ConsumptionBreakdownCategoryRowDisplay] = []

    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.layer.cornerRadius = 8
        return view
    }()

    private let tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.backgroundColor = .clear
        tv.isScrollEnabled = false
        tv.separatorStyle = .singleLine
        tv.layer.cornerRadius = 32
        tv.clipsToBounds = true
        return tv
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .systemBackground
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
        tableView.rowHeight = 56
    }

    func configure(with displays: [ConsumptionBreakdownCategoryRowDisplay]) {
        self.displays = displays
        tableView.reloadData()
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate

extension ConsumptionBreakdownCategoryListCell: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        displays.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reuseId = "ConsumptionBreakdownCategoryListRow"
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseId)
            ?? UITableViewCell(style: .subtitle, reuseIdentifier: reuseId)

        let display = displays[indexPath.row]
        cell.textLabel?.text = display.labelText
        cell.detailTextLabel?.text = "\(display.percentText) · \(display.amountText)"
        cell.selectionStyle = .none

        return cell
    }
}

