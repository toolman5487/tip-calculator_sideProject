//
//  AccountDetailAnalysisViewController.swift
//  tip-calculator
//
//  Created by Willy Hsu on 2026/3/19.
//

import Combine
import SnapKit
import UIKit

// MARK: -

@MainActor
final class AccountDetailAnalysisViewController: MainBaseViewController {

    private let viewModel: AccountDetailAnalysisViewModel
    private var selectedFilterIndex = 0
    private var cancellables = Set<AnyCancellable>()

    init(recordsText: String) {
        self.viewModel = AccountDetailAnalysisViewModel(recordsText: recordsText)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        bind()
        viewModel.analyze(filterIndex: selectedFilterIndex)
    }

    override func setupNavigationBar() {
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
        let titles = AccountDetailAnalysisModel.filterOptionTitles
        let filterTitle = selectedFilterIndex >= 0 && selectedFilterIndex < titles.count ? titles[selectedFilterIndex] : nil
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
        let vm = AccountDetailAnalysisFilterHeaderViewModel(
            selectedIndex: selectedFilterIndex,
            options: AccountDetailAnalysisModel.filterOptionTitles,
            onSelect: { [weak self] index in
                guard let self else { return }
                guard index != self.selectedFilterIndex else { return }
                self.selectedFilterIndex = index
                self.viewModel.analyze(filterIndex: index)
            }
        )
        header.configure(with: vm)
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
