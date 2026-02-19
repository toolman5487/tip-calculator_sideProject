//
//  ChartDetailCategoryFilterHeaderView.swift
//  tip-calculator
//
//  參考 IllustrationFilterHeaderView 樣式
//

import UIKit
import SnapKit

final class ChartDetailCategoryFilterHeaderView: UICollectionReusableView {

    static let reuseId = "ChartDetailCategoryFilterHeaderView"

    var onSelect: ((ChartDetailCategoryOption) -> Void)?

    private var selectedOption: ChartDetailCategoryOption = .all

    private lazy var horizontalCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 12
        layout.minimumLineSpacing = 12
        layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 0)
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.showsHorizontalScrollIndicator = false
        cv.delegate = self
        cv.dataSource = self
        cv.register(ChartDetailCategoryCapsuleCell.self, forCellWithReuseIdentifier: ChartDetailCategoryCapsuleCell.reuseId)
        return cv
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        addSubview(horizontalCollectionView)
        horizontalCollectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(selected: ChartDetailCategoryOption) {
        let previous = selectedOption
        selectedOption = selected
        if previous != selected {
            horizontalCollectionView.reloadData()
        }
    }
}

// MARK: - UICollectionViewDataSource

extension ChartDetailCategoryFilterHeaderView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        ChartDetailCategoryOption.allCases.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ChartDetailCategoryCapsuleCell.reuseId, for: indexPath) as! ChartDetailCategoryCapsuleCell
        let option = ChartDetailCategoryOption.allCases[indexPath.item]
        cell.configure(systemImageName: option.systemImageName, isSelected: option == selectedOption)
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension ChartDetailCategoryFilterHeaderView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let visibleItems: CGFloat = 3.5
        guard let layout = collectionViewLayout as? UICollectionViewFlowLayout else {
            return CGSize(width: 48, height: 40)
        }
        let insets = layout.sectionInset
        let spacing = layout.minimumLineSpacing
        let availableWidth = collectionView.bounds.width - insets.left - insets.right - spacing * (visibleItems - 1)
        let itemWidth = floor(availableWidth / visibleItems)
        return CGSize(width: max(itemWidth, 40), height: 40)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let option = ChartDetailCategoryOption.allCases[indexPath.item]
        guard option != selectedOption else { return }
        selectedOption = option
        horizontalCollectionView.reloadData()
        onSelect?(option)
    }
}
