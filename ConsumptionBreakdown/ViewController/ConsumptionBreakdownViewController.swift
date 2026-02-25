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
    case pieChart
    case categoryList

    var insets: UIEdgeInsets {
        switch self {
        case .pieChart:
            return .zero
        case .categoryList:
            return .zero
        }
    }
}

private enum ConsumptionBreakdownCellKind {
    case categoryList
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
            layout.sectionHeadersPinToVisibleBounds = true
        }
        collectionView.register(ConsumptionBreakdownPieChart.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: ConsumptionBreakdownPieChart.reuseId)
        collectionView.register(ConsumptionBreakdownSectionTitleHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: ConsumptionBreakdownSectionTitleHeader.reuseId)
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

    private func cellKinds(for section: ConsumptionBreakdownSection) -> [ConsumptionBreakdownCellKind] {
        switch section {
        case .pieChart:
            return []
        case .categoryList:
            return [.categoryList]
        }
    }
}

// MARK: - UICollectionViewDataSource

extension ConsumptionBreakdownViewController {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        ConsumptionBreakdownSection.allCases.count
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let sec = ConsumptionBreakdownSection(rawValue: section) else { return 0 }
        return cellKinds(for: sec).count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let sec = ConsumptionBreakdownSection(rawValue: indexPath.section) else {
            return collectionView.dequeueReusableCell(withReuseIdentifier: MainBaseViewController.defaultCellReuseId, for: indexPath)
        }
        let kind = cellKinds(for: sec)[indexPath.item]
        switch kind {
        case .categoryList:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ConsumptionBreakdownCategoryListCell.reuseId, for: indexPath) as! ConsumptionBreakdownCategoryListCell
            cell.configure(with: viewModel.categoryRowDisplays)
            return cell
        }
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader,
              let sec = ConsumptionBreakdownSection(rawValue: indexPath.section) else {
            return UICollectionReusableView()
        }
        switch sec {
        case .pieChart:
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: ConsumptionBreakdownPieChart.reuseId, for: indexPath) as! ConsumptionBreakdownPieChart
            header.configure(data: viewModel.pieChartData)
            return header
        case .categoryList:
            return collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: ConsumptionBreakdownSectionTitleHeader.reuseId, for: indexPath)
        }
    }

}

// MARK: - UICollectionViewDelegateFlowLayout

extension ConsumptionBreakdownViewController {
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let sec = ConsumptionBreakdownSection(rawValue: indexPath.section) else { return .zero }
        let kind = cellKinds(for: sec)[indexPath.item]
        let insets = sec.insets
        let width = max(0, collectionView.bounds.width - insets.left - insets.right)

        switch kind {
        case .categoryList:
            let rowHeight: CGFloat = 56
            let height = rowHeight * CGFloat(max(1, viewModel.categoryRowDisplays.count))
            return CGSize(width: width, height: height)
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        8
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        guard let sec = ConsumptionBreakdownSection(rawValue: section) else { return .zero }
        switch sec {
        case .pieChart:
            return CGSize(width: collectionView.bounds.width, height: 280)
        case .categoryList:
            return CGSize(width: collectionView.bounds.width, height: 44)
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        guard let sec = ConsumptionBreakdownSection(rawValue: section) else { return .zero }
        return sec.insets
    }
}
