//
//  LocationRecordsSheetViewController.swift
//  tip-calculator
//
//  Created by Willy Hsu on 2026/3/3.
//

import SnapKit
import UIKit

@MainActor
final class LocationRecordsSheetViewController: UIViewController {

    // MARK: - Static

    // MARK: - Dependencies

    private let viewModel: LocationRecordsSheetViewModel

    // MARK: - UI Components

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

    // MARK: - Init

    init(viewModel: LocationRecordsSheetViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    // MARK: - Setup

    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = viewModel.locationTitle

        setupNavigation()

        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }

    private func setupNavigation() {
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.leftBarButtonItem = .closeButton { [weak self] in self?.closeButtonTapped() }
    }

    // MARK: - Actions

    private func closeButtonTapped() {
        navigationController?.dismiss(animated: true)
    }

    private func dismissDetail() {
        dismiss(animated: true)
    }

    // MARK: - Presentation

    private func presentResultDetail(for item: RecordDisplayItem) {
        let detailVC = ResultDetailViewController(item: item, mode: ResultDetailMode.readOnly)
        detailVC.navigationItem.leftBarButtonItem = .backButton { [weak self] in self?.dismissDetail() }
        let nav = UINavigationController(rootViewController: detailVC)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true)
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

// MARK: - UICollectionViewDelegate

extension LocationRecordsSheetViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        presentResultDetail(for: viewModel.items[indexPath.item])
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension LocationRecordsSheetViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let w = collectionView.bounds.width
        return CGSize(width: w, height: 120)
    }
}
