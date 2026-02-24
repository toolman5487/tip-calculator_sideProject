//
//  CategorySectionCell.swift
//  tip-calculator
//

import UIKit
import SnapKit

final class CategorySectionCell: UICollectionViewCell {

    static let reuseId = "CategorySectionCell"

    private var onSelect: ((Category) -> Void)?
    private var categories: [Category] = []
    private var selectedCategory: Category?

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

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(innerCollectionView)
        innerCollectionView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.equalToSuperview().offset(CategoryPickerSheetViewController.cellInset)
            make.trailing.equalToSuperview().offset(-CategoryPickerSheetViewController.cellInset)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(categories: [Category], selectedCategory: Category, onSelect: @escaping (Category) -> Void) {
        self.categories = categories
        self.selectedCategory = selectedCategory
        self.onSelect = onSelect
        innerCollectionView.reloadData()
    }
}

extension CategorySectionCell: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
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

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let availableWidth = collectionView.bounds.width
        let width = CategoryPickerSheetViewController.cellWidth(containerWidth: availableWidth)
        return CGSize(width: width, height: width)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard indexPath.item < categories.count else { return }
        onSelect?(categories[indexPath.item])
    }
}
