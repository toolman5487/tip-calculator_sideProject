//
//  CategorySectionCell.swift
//  tip-calculator
//

import SnapKit
import UIKit

final class CategorySectionCell: UICollectionViewCell {

    // MARK: - Static

    static let reuseId = "CategorySectionCell"

    // MARK: - State

    private var onSelect: ((Category) -> Void)?
    private var categories: [Category] = []
    private var selectedCategory: Category?

    // MARK: - UI Components

    private lazy var innerCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = CategoryPickerSheetViewController.spacing
        layout.minimumLineSpacing = CategoryPickerSheetViewController.spacing

        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.isScrollEnabled = false
        cv.delegate = self
        cv.dataSource = self
        cv.register(CategoryOptionCell.self, forCellWithReuseIdentifier: CategoryOptionCell.reuseId)
        return cv
    }()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setupUI() {
        contentView.addSubview(innerCollectionView)
        innerCollectionView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.equalToSuperview().offset(CategoryPickerSheetViewController.cellInset)
            make.trailing.equalToSuperview().offset(-CategoryPickerSheetViewController.cellInset)
        }
    }

    // MARK: - Public API

    func configure(categories: [Category], selectedCategory: Category, onSelect: @escaping (Category) -> Void) {
        self.categories = categories
        self.selectedCategory = selectedCategory
        self.onSelect = onSelect
        innerCollectionView.reloadData()
    }
}

// MARK: - UICollectionViewDataSource

extension CategorySectionCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        categories.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryOptionCell.reuseId, for: indexPath)
        guard let optionCell = cell as? CategoryOptionCell,
              indexPath.item < categories.count else { return cell }
        let category = categories[indexPath.item]
        optionCell.configure(category: category, isSelected: category == selectedCategory)
        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension CategorySectionCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard indexPath.item < categories.count else { return }
        onSelect?(categories[indexPath.item])
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension CategorySectionCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let availableWidth = max(1, collectionView.bounds.width)
        let width = CategoryPickerSheetViewController.cellWidth(containerWidth: availableWidth)
        return CGSize(width: width, height: width)
    }
}
