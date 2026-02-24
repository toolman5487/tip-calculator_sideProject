//
//  CategoryPickerSheetViewController.swift
//  tip-calculator
//

import UIKit
import SnapKit

@MainActor
final class CategoryPickerSheetViewController: MainBaseViewController {

    var onSelect: ((Category) -> Void)?

    private let viewModel: CategoryPickerSheetViewModel

    static let columns: CGFloat = 4
    static let spacing: CGFloat = 12
    static let cellInset: CGFloat = 16
    static let headerHeight: CGFloat = 36

    init(viewModel: CategoryPickerSheetViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setupUI() {
        super.setupUI()
        view.backgroundColor = .systemBackground
        setupNavigation()
        bindViewModel()
        collectionView.register(CategorySectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: CategorySectionHeaderView.reuseId)
        collectionView.register(CategorySectionCell.self, forCellWithReuseIdentifier: CategorySectionCell.reuseId)
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.sectionInset = UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)
            layout.minimumLineSpacing = Self.spacing
        }
    }

    private func setupNavigation() {
        title = "選擇消費種類"
        navigationItem.largeTitleDisplayMode = .never
    }

    private func bindViewModel() {
        viewModel.onSelect = { [weak self] category in
            self?.onSelect?(category)
            self?.dismiss(animated: true)
        }
    }
}

// MARK: - UICollectionViewDataSource

extension CategoryPickerSheetViewController {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        viewModel.sections.count
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        1
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategorySectionCell.reuseId, for: indexPath)
        guard let sectionCell = cell as? CategorySectionCell,
              let section = viewModel.section(at: indexPath.section) else { return cell }
        sectionCell.configure(
            categories: section.categories,
            selectedCategory: viewModel.currentCategory,
            onSelect: { [weak self] category in self?.viewModel.select(category: category) }
        )
        return sectionCell
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader,
              let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: CategorySectionHeaderView.reuseId, for: indexPath) as? CategorySectionHeaderView,
              let section = viewModel.section(at: indexPath.section) else {
            return UICollectionReusableView()
        }
        header.configure(title: section.title)
        return header
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension CategoryPickerSheetViewController {
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let section = viewModel.section(at: indexPath.section) else { return .zero }
        let height = CategoryPickerSheetViewController.sectionCellHeight(categoryCount: section.categories.count, containerWidth: collectionView.bounds.width)
        return CGSize(width: collectionView.bounds.width, height: max(0, height))
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        CGSize(width: collectionView.bounds.width, height: Self.headerHeight)
    }

    static func cellWidth(containerWidth: CGFloat) -> CGFloat {
        (containerWidth - spacing * (columns - 1)) / columns
    }

    private static func sectionCellHeight(categoryCount: Int, containerWidth: CGFloat) -> CGFloat {
        let count = CGFloat(categoryCount)
        let rows = ceil(count / columns)
        let availableWidth = containerWidth - cellInset * 2
        let width = cellWidth(containerWidth: availableWidth)
        return rows * width + spacing * max(0, rows - 1)
    }
}
