//
//  AccountDetailAnalysisViewController.swift
//  tip-calculator
//
//  Created by Willy Hsu on 2026/3/19.
//

import Combine
import SnapKit
import UIKit

@MainActor
final class AccountDetailAnalysisViewController: MainBaseViewController {

    // MARK: - Properties

    private let viewModel: AccountDetailAnalysisViewModel
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Lifecycle

    init(recordsText: String) {
        self.viewModel = AccountDetailAnalysisViewModel(recordsText: recordsText)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupAnalysisContent()
    }

    // MARK: - Setup

    private func setupAnalysisContent() {
        setupCollectionView()
        bind()

        collectionView.dataSource = self
        collectionView.delegate = self

        viewModel.startInitialAnalysis()
    }

    override func setupNavigationBar() {
        super.setupNavigationBar()
        title = "AI 智能消費分析"
        navigationItem.largeTitleDisplayMode = .never
    }

    override func setupUI() {
        super.setupUI()
        view.backgroundColor = .systemBackground
    }

    private func setupCollectionView() {
        collectionView.register(
            AccountDetailAnalysisFilterHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: AccountDetailAnalysisFilterHeaderView.reuseId
        )
        collectionView.register(AIAnalysisCell.self, forCellWithReuseIdentifier: AIAnalysisCell.reuseId)
    }

    // MARK: - Binding

    private func bind() {
        viewModel.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                UIView.performWithoutAnimation {
                    self?.collectionView.reloadSections(IndexSet(integer: 0))
                }
            }
            .store(in: &cancellables)
    }
}

// MARK: - UICollectionViewDataSource

extension AccountDetailAnalysisViewController {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        1
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AIAnalysisCell.reuseId, for: indexPath) as! AIAnalysisCell
        let titles = viewModel.filterOptionTitles
        let idx = viewModel.selectedFilterIndex
        let filterTitle = idx >= 0 && idx < titles.count ? titles[idx] : nil
        cell.configure(state: viewModel.state, filterTitle: filterTitle)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader else {
            return UICollectionReusableView()
        }
        let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: AccountDetailAnalysisFilterHeaderView.reuseId,
            for: indexPath
        ) as! AccountDetailAnalysisFilterHeaderView
        header.configure(with: filterHeaderViewModel)
        return header
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension AccountDetailAnalysisViewController {
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width
        let height = max(200, collectionView.bounds.height - 52 - 16)
        return CGSize(width: width, height: height)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 0, left: 0, bottom: 16, right: 0)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        CGSize(width: collectionView.bounds.width, height: 52)
    }
}

// MARK: - Private

private extension AccountDetailAnalysisViewController {
    var filterHeaderViewModel: AccountDetailAnalysisFilterHeaderViewModel {
        AccountDetailAnalysisFilterHeaderViewModel(
            selectedIndex: viewModel.selectedFilterIndex,
            options: viewModel.filterOptionTitles,
            onSelect: { [weak self] index in
                self?.viewModel.selectFilter(index)
            }
        )
    }
}
