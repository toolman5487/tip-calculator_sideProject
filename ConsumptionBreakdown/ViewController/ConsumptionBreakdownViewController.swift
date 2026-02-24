//
//  ConsumptionBreakdownViewController.swift
//  tip-calculator
//
//  Created by Willy Hsu on 2026/2/13.
//

import Combine
import UIKit

enum ConsumptionBreakdownItem {
    case timeChart(title: String, timeFilter: IllustrationTimeFilterOption, records: [ConsumptionRecord])
    case amountRangeChart(title: String, records: [ConsumptionRecord])
}

private enum ConsumptionBreakdownSection: Int, CaseIterable {
    case main
}

@MainActor
final class ConsumptionBreakdownViewController: MainBaseViewController {

    private let viewModel: ConsumptionBreakdownViewModel
    private var cancellables = Set<AnyCancellable>()

    init(detailItem: ConsumptionBreakdownItem) {
        self.viewModel = ConsumptionBreakdownViewModel(detailItem: detailItem)
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
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.sectionHeadersPinToVisibleBounds = false
        }
        collectionView.register(ConsumptionBreakdownPieChart.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: ConsumptionBreakdownPieChart.reuseId)
        collectionView.register(ConsumptionBreakdownCategoryListCell.self, forCellWithReuseIdentifier: ConsumptionBreakdownCategoryListCell.reuseId)
    }

    private func binding() {
        viewModel.$pieChartData
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.collectionView.reloadData()
            }
            .store(in: &cancellables)
    }
}

// MARK: - UICollectionViewDataSource

extension ConsumptionBreakdownViewController {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        ConsumptionBreakdownSection.allCases.count
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        1
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ConsumptionBreakdownCategoryListCell.reuseId, for: indexPath) as! ConsumptionBreakdownCategoryListCell
        cell.configure(with: viewModel.categoryRowDisplays)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader else {
            return UICollectionReusableView()
        }
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: ConsumptionBreakdownPieChart.reuseId, for: indexPath) as! ConsumptionBreakdownPieChart
        header.configure(data: viewModel.pieChartData)
        return header
    }

}

// MARK: - UICollectionViewDelegateFlowLayout

extension ConsumptionBreakdownViewController {
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width
        let rowHeight: CGFloat = 56
        let height = rowHeight * CGFloat(max(1, viewModel.categoryRowDisplays.count))
        return CGSize(width: width, height: height)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        8
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        CGSize(width: collectionView.bounds.width, height: 280)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        switch ConsumptionBreakdownSection(rawValue: section) {
        case .main:
            return UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        case .none:
            return .zero
        }
    }
}
