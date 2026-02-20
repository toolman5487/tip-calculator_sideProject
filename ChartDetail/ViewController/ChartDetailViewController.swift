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
        (collectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.sectionHeadersPinToVisibleBounds = true
        collectionView.register(
            ChartDetailCategoryFilterHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: ChartDetailCategoryFilterHeaderView.reuseId
        )
        collectionView.register(ChartDetailPieChartCell.self, forCellWithReuseIdentifier: ChartDetailPieChartCell.reuseId)
    }

    private func binding() {
        viewModel.$pieChartData
            .map { _ in () }
            .merge(with: viewModel.$selectedCategory.map { _ in () })
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
        1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        1
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ChartDetailPieChartCell.reuseId, for: indexPath) as! ChartDetailPieChartCell
        cell.configure(data: viewModel.pieChartData)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader else {
            return UICollectionReusableView()
        }
        let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: ChartDetailCategoryFilterHeaderView.reuseId,
            for: indexPath
        ) as! ChartDetailCategoryFilterHeaderView
        header.configure(selected: viewModel.selectedCategory)
        header.onSelect = { [weak self] option in
            self?.viewModel.selectCategory(option)
        }
        return header
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension ChartDetailViewController {
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: collectionView.bounds.width, height: 280)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        CGSize(width: collectionView.bounds.width, height: 72)  
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
    }
}
