//
//  IllustrationFilterHeaderView.swift
//  tip-calculator
//

import UIKit
import SnapKit

final class IllustrationFilterHeaderView: UICollectionReusableView {

    static let reuseId = "IllustrationFilterHeaderView"
    private var viewModel: IllustrationFilterHeaderViewModel?

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
        cv.register(IllustrationFilterOptionCell.self, forCellWithReuseIdentifier: IllustrationFilterOptionCell.reuseId)
        return cv
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        addSubview(horizontalCollectionView)
        horizontalCollectionView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.edges.equalToSuperview()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with viewModel: IllustrationFilterHeaderViewModel) {
        let needsReload = self.viewModel?.selected != viewModel.selected
        self.viewModel = viewModel
        if needsReload {
            horizontalCollectionView.reloadData()
        }
    }
}

// MARK: - UICollectionViewDataSource

extension IllustrationFilterHeaderView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel?.options.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: IllustrationFilterOptionCell.reuseId, for: indexPath) as! IllustrationFilterOptionCell
        guard let vm = viewModel, indexPath.item < vm.options.count else { return cell }
        let option = vm.options[indexPath.item]
        cell.configure(title: option.title, isSelected: option == vm.selected)
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension IllustrationFilterHeaderView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let visibleItems: CGFloat = 2.5

        guard let layout = collectionViewLayout as? UICollectionViewFlowLayout else {
            return CGSize(width: 80, height: 40)
        }

        let insets = layout.sectionInset
        let spacing = layout.minimumLineSpacing
        let availableWidth = collectionView.bounds.width
            - insets.left
            - insets.right
            - spacing * (visibleItems - 1)

        let itemWidth = floor(availableWidth / visibleItems)
        return CGSize(width: itemWidth, height: 40)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let vm = viewModel, indexPath.item < vm.options.count else { return }
        let option = vm.options[indexPath.item]
        vm.onSelect(option)
    }
}

// MARK: - IllustrationFilterOptionCell

final class IllustrationFilterOptionCell: UICollectionViewCell {

    static let reuseId = "IllustrationFilterOptionCell"

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        return label
    }()

    override var isSelected: Bool {
        didSet {
            updateAppearance()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.layer.cornerRadius = 20
        contentView.layer.masksToBounds = true
        contentView.layer.borderWidth = 1

        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16))
        }

        updateAppearance()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(title: String, isSelected: Bool) {
        titleLabel.text = title
        self.isSelected = isSelected
    }

    private func updateAppearance() {
        if isSelected {
            contentView.backgroundColor = UIColor.label
            contentView.layer.borderColor = UIColor.clear.cgColor
            titleLabel.textColor = UIColor.systemBackground
        } else {
            contentView.backgroundColor = UIColor.clear
            contentView.layer.borderColor = UIColor.label.withAlphaComponent(0.2).cgColor
            titleLabel.textColor = UIColor.label
        }
    }
}
