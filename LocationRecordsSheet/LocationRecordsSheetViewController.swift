//
//  LocationRecordsSheetViewController.swift
//  tip-calculator
//
//  Created by Willy Hsu on 2026/3/3.
//

import UIKit
import SnapKit

@MainActor
final class LocationRecordsSheetViewController: UIViewController {

    private static let backButtonImage = UIImage(systemName: "chevron.left", withConfiguration: UIImage.SymbolConfiguration(weight: .bold))

    private let viewModel: LocationRecordsSheetViewModel

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 16
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = ThemeColor.bg
        cv.alwaysBounceVertical = true
        cv.delegate = self
        cv.dataSource = self
        cv.register(ResultsFilterCell.self, forCellWithReuseIdentifier: ResultsFilterCell.reuseId)
        return cv
    }()

    init(viewModel: LocationRecordsSheetViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = viewModel.locationTitle
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "xmark", withConfiguration: UIImage.SymbolConfiguration(weight: .bold)),
            style: .plain,
            target: self,
            action: #selector(closeButtonTapped)
        )

        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
}

// MARK: - UICollectionViewDataSource

extension LocationRecordsSheetViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.items.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ResultsFilterCell.reuseId,
            for: indexPath
        ) as! ResultsFilterCell
        cell.configure(with: viewModel.items[indexPath.item])
        return cell
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDelegateFlowLayout

extension LocationRecordsSheetViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let detailVC = ResultDetailViewController(item: viewModel.items[indexPath.item])
        let nav = UINavigationController(rootViewController: detailVC)
        nav.modalPresentationStyle = .fullScreen
        detailVC.navigationItem.leftBarButtonItem = UIBarButtonItem(image: Self.backButtonImage, style: .plain, target: self, action: #selector(dismissDetail))
        present(nav, animated: true)
    }

    @objc private func closeButtonTapped() {
        navigationController?.dismiss(animated: true)
    }

    @objc private func dismissDetail() {
        dismiss(animated: true)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let w = collectionView.bounds.width
        return CGSize(width: w, height: 120)
    }
}
