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

    private let resultDetailItem: RecordDisplayItem

    private enum Section: Int, CaseIterable {
        case time
        case total
        case bill
        case tip
        case split
        case tipSetting
        case address
    }

    private let tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .plain)
        table.separatorStyle = .singleLine
        table.rowHeight = UITableView.automaticDimension
        table.estimatedRowHeight = 44
        table.showsVerticalScrollIndicator = false
        return table
    }()

    init(item: RecordDisplayItem) {
        self.resultDetailItem = item
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        title = "消費明細"

        setupTableViewLayout()
        setupHeaderView()
    }

    private func setupTableViewLayout() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ResultDeetailTableViewCell.self, forCellReuseIdentifier: ResultDeetailTableViewCell.reuseId)
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }

    private func setupHeaderView() {
        let headerHeight: CGFloat = 160
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: headerHeight))
        headerView.backgroundColor = .clear

        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "每人應付金額"
        titleLabel.font = ThemeFont.demiBold(Ofsize: 16)
        titleLabel.textColor = .secondaryLabel
        titleLabel.textAlignment = .center

        let amountLabel = UILabel()
        amountLabel.translatesAutoresizingMaskIntoConstraints = false
        amountLabel.text = resultDetailItem.amountPerPersonText
        amountLabel.font = UIFont.systemFont(ofSize: 60, weight: .bold, width: .condensed)
        amountLabel.textColor = ThemeColor.primary
        amountLabel.textAlignment = .center

        headerView.addSubview(titleLabel)
        headerView.addSubview(amountLabel)

        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor, constant: 36),

            amountLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            amountLabel.bottomAnchor.constraint(equalTo: titleLabel.topAnchor)
        ])

        tableView.tableHeaderView = headerView
    }
}

extension ResultDetailViewController: UITableViewDelegate, UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Section.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let section = Section(rawValue: indexPath.row) else {
            return UITableViewCell()
        }

        let cell = tableView.dequeueReusableCell(
            withIdentifier: ResultDeetailTableViewCell.reuseId,
            for: indexPath
        ) as! ResultDeetailTableViewCell
        
        switch section {
        case .time:
            cell.configure(
                title: "時間",
                value: resultDetailItem.dateText,
                systemImageName: "clock"
            )
        case .total:
            cell.configure(
                title: "總金額",
                value: resultDetailItem.totalBillText,
                systemImageName: "dollarsign.circle.fill"
            )
        case .bill:
            cell.configure(
                title: "帳單金額",
                value: resultDetailItem.billText,
                systemImageName: "doc.text.fill"
            )
        case .tip:
            cell.configure(
                title: "小費",
                value: resultDetailItem.totalTipText,
                systemImageName: "percent"
            )
        case .split:
            cell.configure(
                title: "分攤人數",
                value: resultDetailItem.splitText,
                systemImageName: "person.3.fill"
            )
        case .tipSetting:
            cell.configure(
                title: "小費設定",
                value: resultDetailItem.tipDisplayText,
                systemImageName: "slider.horizontal.3"
            )
        case .address:
            let text = resultDetailItem.addressText.isEmpty ? "未紀錄" : resultDetailItem.addressText
            cell.configure(
                title: "消費地點",
                value: text,
                systemImageName: "mappin.and.ellipse"
            )
        }
        
        return cell
    }
}
