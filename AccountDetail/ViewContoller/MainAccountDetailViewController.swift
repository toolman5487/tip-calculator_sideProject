//
//  MainAccountDetailViewController.swift
//  tip-calculator
//
//  Created by Willy Hsu on 2026/3/11.
//

import Combine
import SnapKit
import UIKit

@MainActor
final class MainAccountDetailViewController: MainBaseViewController, TabBarRefreshable {

    // MARK: - View Model & State

    private let viewModel = MainAccountDetailViewModel()
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupAccountDetailContent()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.load()
    }

    // MARK: - Setup

    private func setupAccountDetailContent() {
        setupNavigation()
        setupCollectionView()
        bind()

        collectionView.dataSource = self
        collectionView.delegate = self
    }

    private func setupNavigation() {
        title = "帳戶總覽"
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
    }

    // MARK: - TabBarRefreshable

    func refreshContent() {
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
                self?.collectionView.reloadData()
            }
            .store(in: &cancellables)
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
        case nil:
            fatalError("Invalid section")
        }
    }

}

// MARK: - UICollectionViewDelegate

extension MainAccountDetailViewController {
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
        case nil:
            return .zero
        }
    }
}
