//
//  IllustrationFilterHeaderView.swift
//  tip-calculator
//

import UIKit
import SnapKit

struct IllustrationFilterHeaderViewModel: Equatable {
    let selected: IllustrationTimeFilterOption
    let options: [IllustrationTimeFilterOption]
    let selectedColor: UIColor?
    let onSelect: (IllustrationTimeFilterOption) -> Void

    init(selected: IllustrationTimeFilterOption, selectedColor: UIColor? = nil, onSelect: @escaping (IllustrationTimeFilterOption) -> Void) {
        self.selected = selected
        self.options = IllustrationTimeFilterOption.allCases
        self.selectedColor = selectedColor
        self.onSelect = onSelect
    }

    static func == (lhs: IllustrationFilterHeaderViewModel, rhs: IllustrationFilterHeaderViewModel) -> Bool {
        guard lhs.selected == rhs.selected else { return false }
        switch (lhs.selectedColor, rhs.selectedColor) {
        case (nil, nil): return true
        case let (l?, r?): return l.isEqual(r)
        default: return false
        }
    }
}

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
            make.edges.equalToSuperview()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with viewModel: IllustrationFilterHeaderViewModel) {
        guard self.viewModel != viewModel else { return }
        self.viewModel = viewModel
        horizontalCollectionView.reloadData()
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
        cell.configure(title: option.title, isSelected: option == vm.selected, selectedColor: vm.selectedColor)
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
        
        guard option != vm.selected else { return }
        
        let updatedViewModel = IllustrationFilterHeaderViewModel(selected: option, selectedColor: vm.selectedColor, onSelect: vm.onSelect)
        self.viewModel = updatedViewModel
        horizontalCollectionView.reloadData()
        
        vm.onSelect(option)
    }
}

// MARK: - IllustrationFilterOptionCell

final class IllustrationFilterOptionCell: UICollectionViewCell {

    static let reuseId = "IllustrationFilterOptionCell"

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textAlignment = .center
        label.textColor = .label
        return label
    }()

    override var isSelected: Bool {
        didSet {
            setSelected(isSelected)
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        contentView.layer.masksToBounds = false
        contentView.layer.shadowColor = UIColor.black.cgColor
        contentView.layer.shadowOffset = CGSize(width: 0, height: 2)
        contentView.layer.shadowOpacity = 0.08
        contentView.layer.shadowRadius = 4

        setSelected(false)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(title: String, isSelected: Bool, selectedColor: UIColor? = nil) {
        titleLabel.text = title
        self.selectedColor = selectedColor ?? ThemeColor.secondary
        setSelected(isSelected)
    }

    private var selectedColor: UIColor = ThemeColor.secondary

    func setSelected(_ selected: Bool) {
        if selected {
            contentView.backgroundColor = selectedColor
            titleLabel.textColor = .systemBackground
        } else {
            contentView.backgroundColor = .systemBackground
            titleLabel.textColor = .label
        }

        let scale: CGFloat = selected ? 1.2 : 1.0

        UIView.animate(withDuration: 0.2,
                       delay: 0,
                       usingSpringWithDamping: 0.4,
                       initialSpringVelocity: 0.5,
                       options: [.allowUserInteraction, .beginFromCurrentState],
                       animations: {
            self.contentView.transform = CGAffineTransform(scaleX: scale, y: scale)
        }, completion: nil)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let radius = contentView.bounds.height / 2
        contentView.layer.cornerRadius = radius
        contentView.layer.shadowPath = UIBezierPath(roundedRect: contentView.bounds, cornerRadius: radius).cgPath
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        setSelected(false)
    }
}
