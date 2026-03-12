//
//  AccountDetailAchievementCell.swift
//  tip-calculator
//

import SnapKit
import UIKit

final class AccountDetailAchievementCell: UICollectionViewCell {

    static let reuseId = "AccountDetailAchievementCell"

    private var sections: [AccountDetailAchievementSection] = []

    private static let insetH: CGFloat = 16
    private static let spacing: CGFloat = 12

    private lazy var flowLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = Self.spacing
        return layout
    }()

    private lazy var collectionView: UICollectionView = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        cv.backgroundColor = .clear
        cv.showsHorizontalScrollIndicator = false
        cv.isScrollEnabled = true
        cv.decelerationRate = .fast
        cv.dataSource = self
        cv.delegate = self
        cv.register(AchievementTierCell.self, forCellWithReuseIdentifier: AchievementTierCell.reuseId)
        return cv
    }()

    private let pageControl: UIPageControl = {
        let pc = UIPageControl()
        pc.currentPageIndicatorTintColor = .systemBlue
        pc.pageIndicatorTintColor = .quaternaryLabel
        pc.hidesForSinglePage = true
        pc.isUserInteractionEnabled = true
        return pc
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .clear
        contentView.addSubview(collectionView)
        contentView.addSubview(pageControl)
        collectionView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }
        pageControl.snp.makeConstraints { make in
            make.top.equalTo(collectionView.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().inset(8)
        }
        pageControl.addTarget(self, action: #selector(pageControlValueChanged), for: .valueChanged)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(sections: [AccountDetailAchievementSection]) {
        self.sections = sections
        pageControl.numberOfPages = sections.count
        pageControl.currentPage = 0
        collectionView.reloadData()
    }

    @objc private func pageControlValueChanged() {
        let page = pageControl.currentPage
        let (cellWidth, _) = Self.cellSize(containerWidth: collectionView.bounds.width)
        let offsetX = CGFloat(page) * (cellWidth + Self.spacing)
        collectionView.setContentOffset(CGPoint(x: max(0, offsetX), y: 0), animated: true)
    }

    private static func cellSize(containerWidth: CGFloat) -> (width: CGFloat, height: CGFloat) {
        let available = containerWidth - insetH * 2 - spacing
        let cellWidth = available / 1
        return (cellWidth, cellWidth)
    }

    static func preferredHeight(sections: [AccountDetailAchievementSection], width: CGFloat) -> CGFloat {
        guard !sections.isEmpty else { return 0 }
        let (_, cellHeight) = cellSize(containerWidth: width)
        return 16 + cellHeight + 8 + 20 + 8
    }
}

extension AccountDetailAchievementCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        sections.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AchievementTierCell.reuseId, for: indexPath) as! AchievementTierCell
        let section = sections[indexPath.item]
        cell.configure(section: section)
        return cell
    }
}

extension AccountDetailAchievementCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let (w, h) = Self.cellSize(containerWidth: collectionView.bounds.width)
        return CGSize(width: w, height: h)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 8, left: Self.insetH, bottom: 8, right: Self.insetH)
    }
}

extension AccountDetailAchievementCell: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updatePageControl()
    }

    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let (cellWidth, _) = Self.cellSize(containerWidth: collectionView.bounds.width)
        let pageWidth = cellWidth + Self.spacing
        guard pageWidth > 0 else { return }
        var page = Int(round(targetContentOffset.pointee.x / pageWidth))
        if velocity.x > 0.3 { page += 1 }
        if velocity.x < -0.3 { page -= 1 }
        page = min(max(0, page), max(0, sections.count - 1))
        targetContentOffset.pointee.x = CGFloat(page) * pageWidth
    }

    private func updatePageControl() {
        let (cellWidth, _) = Self.cellSize(containerWidth: collectionView.bounds.width)
        let pageWidth = cellWidth + Self.spacing
        guard pageWidth > 0 else { return }
        let page = Int(round(collectionView.contentOffset.x / pageWidth))
        let clamped = min(max(0, page), max(0, sections.count - 1))
        if pageControl.currentPage != clamped {
            pageControl.currentPage = clamped
        }
    }
}
