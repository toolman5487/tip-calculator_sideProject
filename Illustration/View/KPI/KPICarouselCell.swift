//
//  KPICarouselCell.swift
//  tip-calculator
//

import UIKit
import SnapKit

struct KPICardItem {
    let title: String
    let value: String
}

final class KPICarouselCell: UICollectionViewCell {

    static let reuseId = "KPICarouselCell"

    private let horizontalInset: CGFloat = 8
    private let spacing: CGFloat = 8

    private var items: [KPICardItem] = []

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = spacing
        layout.minimumLineSpacing = 8
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.clipsToBounds = false
        cv.showsHorizontalScrollIndicator = false
        cv.isScrollEnabled = false
        cv.delegate = self
        cv.dataSource = self
        cv.register(KPICardCell.self, forCellWithReuseIdentifier: KPICardCell.reuseId)
        return cv
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .clear
        contentView.clipsToBounds = false
        contentView.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(items: [KPICardItem]) {
        self.items = items
        collectionView.reloadData()
    }
}

// MARK: - UICollectionViewDataSource

extension KPICarouselCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        items.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: KPICardCell.reuseId, for: indexPath) as! KPICardCell
        guard indexPath.item < items.count else { return cell }
        let item = items[indexPath.item]
        cell.configure(title: item.title, value: item.value)
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension KPICarouselCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var w = collectionView.bounds.width
        if w <= 0, let superview = collectionView.superview {
            w = superview.bounds.width
        }
        if w <= 0 {
            w = UIScreen.main.bounds.width
        }
        let totalInset = horizontalInset * 2
        let totalSpacing = spacing * 2
        let cellSide = max(0, (w - totalInset - totalSpacing) / 3)
        return CGSize(width: cellSide, height: cellSide)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 0, left: horizontalInset, bottom: 0, right: horizontalInset)
    }
}
