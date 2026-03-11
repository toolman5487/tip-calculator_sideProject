//
//  AccountDetailCarouselCell.swift
//  tip-calculator
//

import SnapKit
import UIKit

final class AccountDetailCarouselCell: UICollectionViewCell {

    static let reuseId = "AccountDetailCarouselCell"

    private var items: [AccountDetailStatCardItem] = []

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 12
        layout.minimumInteritemSpacing = 12
        layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)

        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.showsHorizontalScrollIndicator = false
        cv.showsVerticalScrollIndicator = false
        cv.isScrollEnabled = false
        cv.delegate = self
        cv.dataSource = self
        cv.register(AccountDetailStatCardCell.self, forCellWithReuseIdentifier: AccountDetailStatCardCell.reuseId)
        return cv
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .clear
        contentView.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(items: [AccountDetailStatCardItem]) {
        let changed = self.items.count != items.count
            || !zip(self.items, items).allSatisfy { l, r in
                l.title == r.title && l.value == r.value && l.systemImageName == r.systemImageName
            }
        self.items = items
        if changed {
            collectionView.reloadData()
        }
    }
}

// MARK: - UICollectionViewDataSource

extension AccountDetailCarouselCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        items.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AccountDetailStatCardCell.reuseId, for: indexPath) as! AccountDetailStatCardCell
        guard indexPath.item < items.count else { return cell }
        let item = items[indexPath.item]
        cell.configure(title: item.title, value: item.value, systemImageName: item.systemImageName)
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension AccountDetailCarouselCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var cvWidth = collectionView.bounds.width
        if cvWidth <= 0, let superview = collectionView.superview {
            cvWidth = superview.bounds.width
        }
        if cvWidth <= 0 {
            cvWidth = UIScreen.main.bounds.width
        }
        let cellWidth = floor((cvWidth - 16 - 16 - 12) / 2)
        let cellHeight = cellWidth * 3 / 4
        return CGSize(width: max(0, cellWidth), height: max(0, cellHeight))
    }
}

// MARK: - UICollectionViewDelegate

extension AccountDetailCarouselCell: UICollectionViewDelegate {}
