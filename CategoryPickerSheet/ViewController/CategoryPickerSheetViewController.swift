//
//  CategoryPickerSheetViewController.swift
//  tip-calculator
//

import UIKit
import SnapKit
import Combine

@MainActor
final class CategoryPickerSheetViewController: BaseViewController {

    var onSelect: ((Category) -> Void)?

    private let viewModel: CategoryPickerSheetViewModel
    private var cancellables = Set<AnyCancellable>()

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 12
        layout.minimumLineSpacing = 12
        layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 24, right: 16)

        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.showsVerticalScrollIndicator = false
        cv.delegate = self
        cv.dataSource = self
        cv.register(CategoryOptionCell.self, forCellWithReuseIdentifier: CategoryOptionCell.reuseId)
        return cv
    }()

    init(viewModel: CategoryPickerSheetViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setupUI() {
        super.setupUI()
        view.backgroundColor = ThemeColor.bg
        setupNavigation()
        bindViewModel()
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }

    private func setupNavigation() {
        title = "選擇消費種類"
        navigationItem.largeTitleDisplayMode = .never
    }

    private func bindViewModel() {
        viewModel.selectPublisher
            .sink { [weak self] category in
                self?.onSelect?(category)
                self?.dismiss(animated: true)
            }
            .store(in: &cancellables)
    }
}

extension CategoryPickerSheetViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.categories.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryOptionCell.reuseId, for: indexPath)
        guard let optionCell = cell as? CategoryOptionCell,
              let category = viewModel.category(at: indexPath.item) else { return cell }
        let isSelected = viewModel.isSelected(at: indexPath.item)
        optionCell.configure(category: category, isSelected: isSelected)
        return optionCell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let columns: CGFloat = 4
        let spacing: CGFloat = 12
        let inset: CGFloat = 16
        let availableWidth = max(200, collectionView.bounds.width - inset * 2 - spacing * (columns - 1))
        let width = availableWidth / columns
        return CGSize(width: width, height: width)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.select(at: indexPath.item)
    }
}

private final class CategoryOptionCell: UICollectionViewCell {

    static let reuseId = "CategoryOptionCell"

    private let iconImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.tintColor = .white
        return iv
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = ThemeColor.primary
        contentView.layer.cornerRadius = 12
        contentView.layer.masksToBounds = true
        contentView.addSubview(iconImageView)
        iconImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(32)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(category: Category, isSelected: Bool = false) {
        let imageName = category.systemImageName ?? "xmark.circle"
        let config = UIImage.SymbolConfiguration(pointSize: 24, weight: .medium)
        iconImageView.image = UIImage(systemName: imageName, withConfiguration: config)
        contentView.backgroundColor = isSelected ? ThemeColor.secondary : ThemeColor.primary
    }
}
