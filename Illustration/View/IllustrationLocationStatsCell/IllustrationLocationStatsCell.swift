//
//  IllustrationLocationStatsCell.swift
//  tip-calculator
//
//  Created by Willy Hsu on 2026/3/2.
//

import Foundation
import UIKit
import SnapKit

final class IllustrationLocationStatsCell: UICollectionViewCell {

    static let reuseId = "IllustrationLocationStatsCell"
    static let maxRows = 5
    static let rowHeight: CGFloat = 44

    private var items: [LocationStatItem] = []

    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
        return view
    }()

    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.text = "尚無地區資料"
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: 14, weight: .regular)
        return label
    }()

    private let tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .plain)
        table.backgroundColor = .clear
        table.isScrollEnabled = false
        table.separatorStyle = .singleLine
        return table
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .clear
        contentView.addSubview(containerView)
        containerView.addSubview(tableView)
        containerView.addSubview(emptyLabel)
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        emptyLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = Self.rowHeight
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(data: [LocationStatItem]) {
        items = Array(data.prefix(Self.maxRows))
        let hasData = !items.isEmpty
        tableView.isHidden = !hasData
        emptyLabel.isHidden = hasData
        tableView.reloadData()
    }
}

extension IllustrationLocationStatsCell: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LocationCell")
            ?? UITableViewCell(style: .value1, reuseIdentifier: "LocationCell")
        let item = items[indexPath.row]
        cell.textLabel?.text = item.name
        cell.detailTextLabel?.text = "\(item.count) 筆"
        cell.selectionStyle = .none
        return cell
    }
}
