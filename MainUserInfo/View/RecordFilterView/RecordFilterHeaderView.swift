//
//  RecordFilterHeaderView.swift
//  tip-calculator
//

import UIKit
import SnapKit

final class RecordFilterHeaderView: UICollectionReusableView {

    static let reuseId = "RecordFilterHeaderView"

    var onSelect: ((RecordFilterOption) -> Void)?

    private var selectedOption: RecordFilterOption = .newest {
        didSet {
            horizontalCollectionView.reloadData()
        }
    }

    private lazy var horizontalCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 12
        layout.minimumLineSpacing = 12
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.showsHorizontalScrollIndicator = false
        cv.delegate = self
        cv.dataSource = self
        cv.register(DateCapsuleCell.self, forCellWithReuseIdentifier: DateCapsuleCell.reuseId)
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

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure(selected: RecordFilterOption, onSelect: @escaping (RecordFilterOption) -> Void) {
        selectedOption = selected
        self.onSelect = onSelect
        horizontalCollectionView.reloadData()
    }
}

// MARK: - UICollectionViewDataSource

extension RecordFilterHeaderView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        RecordFilterOption.allCases.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DateCapsuleCell.reuseId, for: indexPath) as! DateCapsuleCell
        let option = RecordFilterOption(rawValue: indexPath.item) ?? .month
        cell.configure(title: option.title, isSelected: option == selectedOption)
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension RecordFilterHeaderView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let option = RecordFilterOption(rawValue: indexPath.item) ?? .newest
        let font = UIFont.systemFont(ofSize: 16, weight: .medium)
        let textWidth = (option.title as NSString).size(withAttributes: [.font: font]).width
        let horizontalPadding: CGFloat = 32
        let width = textWidth + horizontalPadding
        return CGSize(width: width, height: 40)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let option = RecordFilterOption(rawValue: indexPath.item) else { return }
        selectedOption = option
        onSelect?(option)
    }
}
