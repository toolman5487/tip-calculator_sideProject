//
//  ResultsFilterViewController.swift
//  tip-calculator
//
//  Created by Willy Hsu on 2026/2/5.
//

import UIKit
import SnapKit
import Combine
import CombineCocoa

@MainActor
final class ResultsFilterViewController: UIViewController {

    private let tableView = UITableView(frame: .zero, style: .plain)
    private let viewModel: ResultsFilterViewModel
    private var cancellables = Set<AnyCancellable>()

    private static let cellId = "Cell"

    init(viewModel: ResultsFilterViewModel = ResultsFilterViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        self.viewModel = ResultsFilterViewModel()
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupTableView()
        bindViewModel()
        viewModel.loadRecords()
    }

    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()

        view.addSubview(tableView)

        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func bindViewModel() {
        viewModel.$recordDisplayItems
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)
    }
}

extension ResultsFilterViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.recordDisplayItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Self.cellId)
            ?? UITableViewCell(style: .subtitle, reuseIdentifier: Self.cellId)
        let item = viewModel.recordDisplayItems[indexPath.row]
        cell.textLabel?.text = "\(item.dateText) · 總計 \(item.totalBillText)"
        cell.textLabel?.textColor = .label
        cell.textLabel?.numberOfLines = 0
        cell.detailTextLabel?.text = [
            "帳單 \(item.billText)",
            "小費 \(item.totalTipText)",
            "每人 \(item.amountPerPersonText)",
            "分攤 \(item.splitText)",
            "小費設定 \(item.tipDisplayText)"
        ].joined(separator: " · ")
        cell.detailTextLabel?.textColor = .secondaryLabel
        cell.detailTextLabel?.numberOfLines = 0
        cell.backgroundColor = .clear
        return cell
    }
}
