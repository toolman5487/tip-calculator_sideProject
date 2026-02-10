//
//  ResultsFilterViewController.swift
//  tip-calculator
//
//  Created by Willy Hsu on 2026/2/5.
//

import UIKit
import SnapKit
import Combine
import CombineCocoa

@MainActor
final class ResultsFilterViewController: UIViewController {

    // MARK: - Properties

    private let viewModel: ResultsFilterViewModel
    private var cancellables = Set<AnyCancellable>()
    private var dataSource: UICollectionViewDiffableDataSource<Section, RecordDisplayItem>!

    private enum Section: Hashable {
        case main
    }

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 16
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = UIEdgeInsets(top: 16, left: 0, bottom: 0, right: 0)
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = ThemeColor.bg
        cv.alwaysBounceVertical = true
        cv.refreshControl = refreshControl
        return cv
    }()

    private let refreshControl: UIRefreshControl = {
        let control = UIRefreshControl()
        control.tintColor = .white
        control.backgroundColor = .clear
        return control
    }()

    // MARK: - Init

    init(viewModel: ResultsFilterViewModel? = nil) {
        self.viewModel = viewModel ?? ResultsFilterViewModel(store: ConsumptionRecordStore())
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        self.viewModel = ResultsFilterViewModel(store: ConsumptionRecordStore())
        super.init(coder: coder)
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupCollectionView()
        bindViewModel()
        viewModel.loadRecords()
    }

    // MARK: - Public

    func filter(keyword: String) {
        viewModel.filter(keyword: keyword)
    }

    // MARK: - Setup

    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.register(ResultsFilterCell.self, forCellWithReuseIdentifier: ResultsFilterCell.reuseId)
        refreshControl.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)

        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.trailing.bottom.equalToSuperview()
        }

        dataSource = UICollectionViewDiffableDataSource<Section, RecordDisplayItem>(
            collectionView: collectionView
        ) { collectionView, indexPath, item in
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: ResultsFilterCell.reuseId,
                for: indexPath
            ) as! ResultsFilterCell
            cell.configure(with: item)
            return cell
        }
    }

    // MARK: - Bindings

    private func bindViewModel() {
        viewModel.$recordDisplayItems
            .receive(on: DispatchQueue.main)
            .sink { [weak self] items in
                guard let self else { return }
                var snapshot = NSDiffableDataSourceSnapshot<Section, RecordDisplayItem>()
                snapshot.appendSections([.main])
                snapshot.appendItems(items, toSection: .main)
                dataSource.apply(snapshot, animatingDifferences: false)
                refreshControl.endRefreshing()
            }
            .store(in: &cancellables)
    }

    @objc
    private func didPullToRefresh() {
        viewModel.refresh()
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDelegateFlowLayout

extension ResultsFilterViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        viewModel.loadMoreIfNeeded(currentIndex: indexPath.item)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let item = viewModel.recordDisplayItems[indexPath.item]
        let detailVC = ResultDetailViewController(item: item)
        let nav = UINavigationController(rootViewController: detailVC)
        nav.modalPresentationStyle = .pageSheet
        nav.modalTransitionStyle = .coverVertical
        if let sheet = nav.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.selectedDetentIdentifier = .medium
            sheet.prefersGrabberVisible = true
        }
        present(nav, animated: true)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let w = collectionView.bounds.width
        return CGSize(width: w, height: 120)
    }
}
