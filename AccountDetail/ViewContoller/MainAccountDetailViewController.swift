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
        title = "用戶總覽"
        navigationItem.rightBarButtonItems = [
            .shareButton { [weak self] in self?.shareButtonTapped() },
            .refreshBarButton { [weak self] in self?.triggerRefresh() }
        ]
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
            AccountDetailSectionTitleHeader.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: AccountDetailSectionTitleHeader.reuseId
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
            AccountDetailAIAnalysisCell.self,
            forCellWithReuseIdentifier: AccountDetailAIAnalysisCell.reuseId
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
        switch AccountDetailSection.effectiveSection(at: indexPath.section) {
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
        case .aiAnalysis:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AccountDetailAIAnalysisCell.reuseId, for: indexPath) as! AccountDetailAIAnalysisCell
            cell.onTap = { [weak self] in
                self?.aiAnalysisCellTapped()
            }
            return cell
        case nil:
            fatalError("Invalid section")
        }
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader else {
            return UICollectionReusableView()
        }
        let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: AccountDetailSectionTitleHeader.reuseId,
            for: indexPath
        ) as! AccountDetailSectionTitleHeader

        if let title = viewModel.headerTitle(for: indexPath.section) {
            header.configure(title: title)
            return header
        } else {
            return UICollectionReusableView()
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension MainAccountDetailViewController {
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width
        switch AccountDetailSection.effectiveSection(at: indexPath.section) {
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
        case .aiAnalysis:
            return CGSize(width: width, height: 72)
        case nil:
            return .zero
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        switch AccountDetailSection.effectiveSection(at: section) {
        case .header:
            return .zero
        case .carousel:
            return .zero
        case .categoryDistribution:
            return UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        case .achievement:
            return UIEdgeInsets(top: 16, left: 16, bottom: 0, right: 16)
        case .aiAnalysis:
            return .zero
        case nil:
            return .zero
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        switch AccountDetailSection.effectiveSection(at: section) {
        case .header:
            return .zero
        case .carousel:
            return .zero
        case .categoryDistribution:
            return CGSize(width: collectionView.bounds.width, height: 44)
        case .achievement:
            return CGSize(width: collectionView.bounds.width, height: 44)
        case .aiAnalysis:
            return .zero
        case nil:
            return .zero
        }
    }
}

// MARK: - Private

private extension MainAccountDetailViewController {
    func reloadOverviewContent() {
        collectionView.reloadSections(IndexSet(0..<viewModel.sectionCount))
    }

    func shareButtonTapped() {
        let text = viewModel.exportAllRecordsText()
        let activityVC = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        if let popover = activityVC.popoverPresentationController,
           let shareItem = navigationItem.rightBarButtonItems?.first {
            popover.barButtonItem = shareItem
        }
        present(activityVC, animated: true)
    }

    func aiAnalysisCellTapped() {
        let recordsText = viewModel.exportAllRecordsText()
        let vc = AccountDetailAnalysisViewController(recordsText: recordsText)
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .pageSheet
        if let sheet = nav.sheetPresentationController {
            sheet.detents = [.large()]
            sheet.prefersGrabberVisible = true
        }
        present(nav, animated: true)
    }
}
