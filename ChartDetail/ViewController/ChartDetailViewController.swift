//
//  ChartDetailViewController.swift
//  tip-calculator
//
//  Created by Willy Hsu on 2026/2/13.
//

import Combine
import UIKit

enum ChartDetailItem {
    case timeChart(title: String, timeFilter: IllustrationTimeFilterOption, records: [ConsumptionRecord])
    case amountRangeChart(title: String, records: [ConsumptionRecord])
}

private enum ChartDetailSection: Int, CaseIterable {
    case main
}

private enum ChartDetailCellItem: Int, CaseIterable {
    case pieChart
}

@MainActor
final class ChartDetailViewController: MainBaseViewController {

    private let viewModel: ChartDetailViewModel
    private var cancellables = Set<AnyCancellable>()

    init(detailItem: ChartDetailItem) {
        self.viewModel = ChartDetailViewModel(detailItem: detailItem)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        binding()
    }

    override func setupNavigationBar() {
        super.setupNavigationBar()
        navigationItem.largeTitleDisplayMode = .never
        switch viewModel.detailItem {
        case .timeChart(let title, _, _), .amountRangeChart(let title, _):
            self.title = title
        }
    }

    override func setupUI() {
        super.setupUI()
        view.backgroundColor = .systemGroupedBackground
        collectionView.backgroundColor = .clear
    }

    private func setupCollectionView() {
        collectionView.register(ChartDetailPieChartCell.self, forCellWithReuseIdentifier: ChartDetailPieChartCell.reuseId)
    }

    private func binding() {
        viewModel.$pieChartData
            .map { _ in () }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.collectionView.reloadData()
            }
            .store(in: &cancellables)
    }
}

// MARK: - UICollectionViewDataSource

extension ChartDetailViewController {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        ChartDetailSection.allCases.count
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch ChartDetailSection(rawValue: section) {
        case .main:
            return ChartDetailCellItem.allCases.count
        case .none:
            return 0
        }
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch ChartDetailCellItem(rawValue: indexPath.item) {
        case .pieChart:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ChartDetailPieChartCell.reuseId, for: indexPath) as! ChartDetailPieChartCell
            cell.configure(data: viewModel.pieChartData)
            return cell
        case .none:
            return collectionView.dequeueReusableCell(withReuseIdentifier: Self.defaultCellReuseId, for: indexPath)
        }
    }

}

// MARK: - UICollectionViewDelegateFlowLayout

extension ChartDetailViewController {
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width
        switch ChartDetailCellItem(rawValue: indexPath.item) {
        case .pieChart:
            return CGSize(width: width, height: 280)
        case .none:
            return CGSize(width: width, height: 44)
        }
    }


    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        switch ChartDetailSection(rawValue: section) {
        case .main:
            return .zero
        case .none:
            return UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        }
    }
}
