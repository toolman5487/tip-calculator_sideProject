//
//  AccountDetailAnalysisViewController.swift
//  tip-calculator
//
//  Created by Willy Hsu on 2026/3/19.
//

import SnapKit
import UIKit

// MARK: -

final class AccountDetailAnalysisViewController: MainBaseViewController {

    private let viewModel: AccountDetailAnalysisViewModel
    private var selectedFilterIndex = 0
    private let filterOptions = ["選項 A", "選項 B", "選項 C", "選項 D", "選項 E", "選項 F", "選項 G", "選項 H"]

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
    }
}

// MARK: - UICollectionViewDataSource

extension AccountDetailAnalysisViewController {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        0
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
            options: filterOptions,
            onSelect: { [weak self] index in
                guard let self else { return }
                guard index != self.selectedFilterIndex else { return }
                self.selectedFilterIndex = index
                self.collectionView.reloadSections(IndexSet(integer: 0))
            }
        )
        header.configure(with: vm)
        return header
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension AccountDetailAnalysisViewController {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        CGSize(width: collectionView.bounds.width, height: 52)
    }
}
