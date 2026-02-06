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

    
    private let viewModel: ResultsFilterViewModel
    private var cancellables = Set<AnyCancellable>()
    private var dataSource: UITableViewDiffableDataSource<Section, RecordDisplayItem>!
    
    private enum Section {
        case main
    }

    private let tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .plain)
        table.tableFooterView = UIView()
        table.backgroundColor = ThemeColor.bg
        table.separatorStyle = .none
        table.rowHeight = UITableView.automaticDimension
        table.estimatedRowHeight = 80
        table.alwaysBounceVertical = true
        return table
    }()

    private let refreshControl: UIRefreshControl = {
        let control = UIRefreshControl()
        control.tintColor = .white
        control.backgroundColor = .clear
        return control
    }()

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

    func filter(keyword: String) {
        viewModel.filter(keyword: keyword)
    }

    private func setupTableView() {
        tableView.delegate = self
        tableView.register(ResultsFilterCell.self, forCellReuseIdentifier: ResultsFilterCell.reuseId)
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)

        view.addSubview(tableView)

        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        dataSource = UITableViewDiffableDataSource<Section, RecordDisplayItem>(
            tableView: tableView
        ) { tableView, indexPath, item in
            let cell = tableView.dequeueReusableCell(
                withIdentifier: ResultsFilterCell.reuseId,
                for: indexPath
            ) as! ResultsFilterCell
            cell.configure(with: item)
            return cell
        }
    }

    private func bindViewModel() {
        viewModel.$recordDisplayItems
            .receive(on: DispatchQueue.main)
            .sink { [weak self] items in
                guard let self else { return }
                var snapshot = NSDiffableDataSourceSnapshot<Section, RecordDisplayItem>()
                snapshot.appendSections([.main])
                snapshot.appendItems(items, toSection: .main)
                dataSource.apply(snapshot, animatingDifferences: false)
                refreshControl.endRefreshing()
            }
            .store(in: &cancellables)
    }

    @objc
    private func didPullToRefresh() {
        refreshControl.beginRefreshing()
        viewModel.loadRecords()
    }
}

extension ResultsFilterViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        viewModel.loadMoreIfNeeded(currentIndex: indexPath.row)
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = viewModel.recordDisplayItems[indexPath.row]
        let detailVC = ResultDetailViewController(item: item)
        let nav = UINavigationController(rootViewController: detailVC)
        nav.modalPresentationStyle = .pageSheet
        nav.modalTransitionStyle = .coverVertical
        if let sheet = nav.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.selectedDetentIdentifier = .medium
            sheet.prefersGrabberVisible = true
        }
        present(nav, animated: true)
    }
}
