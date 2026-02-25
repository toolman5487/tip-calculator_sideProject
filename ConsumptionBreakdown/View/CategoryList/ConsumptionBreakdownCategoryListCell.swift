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
        tableView.rowHeight = 56
    }

    func configure(with displays: [ConsumptionBreakdownCategoryRowDisplay]) {
        self.displays = displays.sorted { $0.progressValue > $1.progressValue }
        tableView.reloadData()
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate

extension ConsumptionBreakdownCategoryListCell: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        displays.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
            ?? UITableViewCell(style: .value1, reuseIdentifier: "Cell")
        let display = displays[indexPath.row]
        cell.imageView?.image = display.iconName.flatMap { UIImage(systemName: $0) }
        cell.imageView?.tintColor = .secondaryLabel
        let full = "\(display.labelText): \(display.percentText)"
        let attr = NSMutableAttributedString(string: full)
        attr.addAttribute(.foregroundColor, value: UIColor.label, range: NSRange(location: 0, length: attr.length))
        let percentRange = (full as NSString).range(of: display.percentText)
        if percentRange.location != NSNotFound {
            attr.addAttribute(.foregroundColor, value: ThemeColor.secondary, range: percentRange)
        }
        cell.textLabel?.attributedText = attr
        cell.detailTextLabel?.text = display.amountText
        cell.selectionStyle = .none
        return cell
    }
}

