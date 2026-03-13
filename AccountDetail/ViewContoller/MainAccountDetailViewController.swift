//
//  MainAccountDetailViewController.swift
//  tip-calculator
//
//  Created by Willy Hsu on 2026/3/11.
//

import UIKit
import Combine
import SnapKit

@MainActor
final class MainAccountDetailViewController: MainBaseViewController, TabBarRefreshable {

    // MARK: - Properties

    private let viewModel = MainAccountDetailViewModel()
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigation()
        setupCollectionView()
        bind()

        collectionView.dataSource = self
        collectionView.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.load()
    }

    // MARK: - Binding

    private func bind() {
        refreshPublisher
            .sink { [weak self] _ in
                self?.refreshContent()
            }
            .store(in: &cancellables)

        viewModel.$dataVersion
            .dropFirst()
            .sink { [weak self] _ in
                self?.reloadOverviewContent()
            }
            .store(in: &cancellables)
    }

    // MARK: - Setup

    private func setupNavigation() {
        title = "資料總覽"
        navigationItem.rightBarButtonItem = .refreshBarButton { [weak self] in
            self?.triggerRefresh()
        }
    }

    private func setupCollectionView() {
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.minimumLineSpacing = 0
            layout.minimumInteritemSpacing = 0
        }
        collectionView.register(
            AccountDetailHeaderCell.self,
            forCellWithReuseIdentifier: AccountDetailHeaderCell.reuseId
        )
        collectionView.register(
            AccountDetailCarouselCell.self,
            forCellWithReuseIdentifier: AccountDetailCarouselCell.reuseId
        )
        collectionView.register(
            AccountDetailCategoryDistributionCell.self,
            forCellWithReuseIdentifier: AccountDetailCategoryDistributionCell.reuseId
        )
        collectionView.register(
            AccountDetailAchievementCell.self,
            forCellWithReuseIdentifier: AccountDetailAchievementCell.reuseId
        )
        collectionView.register(
            AccountDetailSectionTitleHeader.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: AccountDetailSectionTitleHeader.reuseId
        )
    }

    // MARK: - TabBarRefreshable

    func refreshContent() {
        viewModel.load()
    }
}

// MARK: - UICollectionViewDataSource

extension MainAccountDetailViewController {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        viewModel.sectionCount
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        1
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch AccountDetailSection(rawValue: indexPath.section) {
        case .header:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AccountDetailHeaderCell.reuseId, for: indexPath) as! AccountDetailHeaderCell
            let text = viewModel.overviewItem?.personalConsumptionTotalText ?? "—"
            cell.configure(personalConsumptionTotalText: text)
            return cell
        case .carousel:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AccountDetailCarouselCell.reuseId, for: indexPath) as! AccountDetailCarouselCell
            let items = viewModel.overviewItem?.statCardItems ?? []
            cell.configure(items: items)
            return cell
        case .categoryDistribution:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AccountDetailCategoryDistributionCell.reuseId, for: indexPath) as! AccountDetailCategoryDistributionCell
            let items = viewModel.overviewItem?.categoryDistributionItems ?? []
            cell.configure(items: items)
            return cell
        case .achievement:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AccountDetailAchievementCell.reuseId, for: indexPath) as! AccountDetailAchievementCell
            let sections = viewModel.overviewItem?.achievementSections ?? []
            cell.configure(sections: sections)
            return cell
        case nil:
            fatalError("Invalid section")
        }
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader else {
            return UICollectionReusableView()
        }
        switch AccountDetailSection(rawValue: indexPath.section) {
        case .categoryDistribution:
            let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: AccountDetailSectionTitleHeader.reuseId,
                for: indexPath
            ) as! AccountDetailSectionTitleHeader
            header.configure(title: Self.categoryDistributionSectionTitle)
            return header
        case .achievement:
            let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: AccountDetailSectionTitleHeader.reuseId,
                for: indexPath
            ) as! AccountDetailSectionTitleHeader
            header.configure(title: Self.achievementSectionTitle)
            return header
        default:
            return UICollectionReusableView()
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension MainAccountDetailViewController {
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width
        switch AccountDetailSection(rawValue: indexPath.section) {
        case .header:
            return CGSize(width: width, height: 160)
        case .carousel:
            let itemCount = viewModel.overviewItem?.statCardItems.count ?? 6
            let rows = (itemCount + 1) / 2
            let cellWidth = floor((width - 16 - 16 - 12) / 2)
            let cellHeight = cellWidth * 3 / 4
            let totalHeight = CGFloat(rows) * cellHeight + CGFloat(max(0, rows - 1)) * 12 + 16 + 16
            return CGSize(width: width, height: totalHeight)
        case .categoryDistribution:
            let itemCount = viewModel.overviewItem?.categoryDistributionItems.count ?? 0
            let height = AccountDetailCategoryDistributionCell.preferredHeight(itemCount: itemCount)
            return CGSize(width: width, height: height)
        case .achievement:
            let sections = viewModel.overviewItem?.achievementSections ?? []
            return CGSize(width: width, height: AccountDetailAchievementCell.preferredHeight(sections: sections, width: width))
        case nil:
            return .zero
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        switch AccountDetailSection(rawValue: section) {
        case .header:
            return .zero
        case .carousel:
            return .zero
        case .categoryDistribution:
            return UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        case .achievement:
            return UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        case nil:
            return .zero
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        switch AccountDetailSection(rawValue: section) {
        case .header:
            return .zero
        case .carousel:
            return .zero
        case .categoryDistribution:
            return CGSize(width: collectionView.bounds.width, height: 44)
        case .achievement:
            return CGSize(width: collectionView.bounds.width, height: 44)
        case nil:
            return .zero
        }
    }
}

// MARK: - Private

private extension MainAccountDetailViewController {
    static let categoryDistributionSectionTitle = "消費分布"
    static let achievementSectionTitle = "消費成就"

    func reloadOverviewContent() {
        collectionView.reloadSections(IndexSet(0..<viewModel.sectionCount))
    }
}
