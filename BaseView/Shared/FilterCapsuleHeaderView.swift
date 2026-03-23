//
//  FilterCapsuleHeaderView.swift
//  tip-calculator
//

import SnapKit
import UIKit

// MARK: - FilterCapsuleHeaderViewModel

struct FilterCapsuleHeaderViewModel {
    let selectedIndex: Int
    let options: [String]
    let onSelect: (Int) -> Void
}

// MARK: - FilterCapsuleHeaderView

class FilterCapsuleHeaderView: UICollectionReusableView {

    static let reuseId = "FilterCapsuleHeaderView"
    private var viewModel: FilterCapsuleHeaderViewModel?

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
        cv.register(FilterCapsuleCell.self, forCellWithReuseIdentifier: FilterCapsuleCell.reuseId)
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

    func configure(with viewModel: FilterCapsuleHeaderViewModel) {
        let needsReload = self.viewModel?.selectedIndex != viewModel.selectedIndex
        self.viewModel = viewModel
        if needsReload {
            horizontalCollectionView.reloadData()
        }
    }
}

// MARK: - UICollectionViewDataSource

extension FilterCapsuleHeaderView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel?.options.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FilterCapsuleCell.reuseId, for: indexPath) as! FilterCapsuleCell
        guard let vm = viewModel, indexPath.item < vm.options.count else { return cell }
        let title = vm.options[indexPath.item]
        cell.configure(title: title, isSelected: indexPath.item == vm.selectedIndex)
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension FilterCapsuleHeaderView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let vm = viewModel, indexPath.item < vm.options.count else { return CGSize(width: 80, height: 44) }
        let font = ThemeFont.demiBold(Ofsize: 16)
        let textWidth = (vm.options[indexPath.item] as NSString).size(withAttributes: [.font: font]).width
        let width = textWidth + 32
        return CGSize(width: width, height: 44)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let vm = viewModel, indexPath.item < vm.options.count else { return }
        vm.onSelect(indexPath.item)
    }
}
