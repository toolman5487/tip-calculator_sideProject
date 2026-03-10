//
//  MainUserInfoViewController.swift
//  tip-calculator
//
//  Created by Willy Hsu on 2026/2/5.
//

import Combine
import SnapKit
import UIKit

@MainActor
final class MainUserInfoViewController: MainBaseViewController, TabBarRefreshable {

    // MARK: - View Model & State

    private let viewModel = MainUserInfoViewModel()
    private var cancellables = Set<AnyCancellable>()
    private let searchSubject = PassthroughSubject<String, Never>()

    // MARK: - UI Components

    private let emptyStateView: EmptyStateView = {
        let v = EmptyStateView()
        v.label.text = "尚無消費紀錄"
        v.isHidden = true
        return v
    }()

    private lazy var searchController: UISearchController = {
        let resultsVC = ResultsFilterViewController()
        let controller = UISearchController(searchResultsController: resultsVC)
        controller.obscuresBackgroundDuringPresentation = false
        controller.searchBar.placeholder = "搜尋消費紀錄"
        controller.searchBar.searchTextField.backgroundColor = .systemBackground
        controller.searchBar.searchTextField.tintColor = .label
        controller.searchBar.delegate = self
        return controller
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupMainUserInfoContent()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.refresh()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        emptyStateView.stop()
    }

    // MARK: - Setup

    private func setupMainUserInfoContent() {
        setupEmptyStateView()
        setupNavigation()
        setupCollectionView()
        bind()

        collectionView.dataSource = self
        collectionView.delegate = self

        viewModel.load()
    }

    private func setupEmptyStateView() {
        view.addSubview(emptyStateView)
        let filterHeaderHeight: CGFloat = 56
        emptyStateView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(filterHeaderHeight)
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(16)
            make.centerX.equalToSuperview()
        }
    }

    private func setupCollectionView() {
        collectionView.register(
            RecordFilterHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: RecordFilterHeaderView.reuseId
        )
        collectionView.register(
            RecordSectionHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: RecordSectionHeaderView.reuseId
        )
        collectionView.register(
            PerCapitaRecordCell.self,
            forCellWithReuseIdentifier: PerCapitaRecordCell.reuseId
        )
    }

    private func setupNavigation() {
        title = "消費紀錄"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true

        let config = UIImage.SymbolConfiguration(weight: .bold)
        let trashItem = UIBarButtonItem(
            image: UIImage(systemName: "trash", withConfiguration: config),
            style: .plain,
            target: self,
            action: #selector(deleteButtonTapped)
        )
        let refreshItem = UIBarButtonItem.refreshBarButton { [weak self] in
            self?.triggerRefresh()
        }
        navigationItem.rightBarButtonItems = [refreshItem, trashItem]
    }

    // MARK: - TabBarRefreshable

    func refreshContent() {
        viewModel.refresh()
    }

    // MARK: - Binding

    private func bind() {
        refreshPublisher
            .sink { [weak self] _ in
                self?.viewModel.refresh()
            }
            .store(in: &cancellables)

        searchSubject
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] keyword in
                guard let resultsVC = self?.searchController.searchResultsController as? ResultsFilterViewController else { return }
                resultsVC.filter(keyword: keyword)
            }
            .store(in: &cancellables)

        viewModel.$displaySections
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self else { return }
                self.collectionView.reloadData()
                self.updateEmptyState(isEmpty: self.viewModel.recordCount == 0)
            }
            .store(in: &cancellables)
    }

    // MARK: - Helpers

    private func updateEmptyState(isEmpty: Bool) {
        emptyStateView.isHidden = !isEmpty
        if isEmpty {
            view.bringSubviewToFront(emptyStateView)
            emptyStateView.play()
        } else {
            emptyStateView.stop()
        }
    }

    // MARK: - Actions

    @objc private func deleteButtonTapped() {
        let content = viewModel.deleteAllAlertContent
        let alert = UIAlertController(
            title: content.title,
            message: content.message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: content.cancelTitle, style: .cancel))
        alert.addAction(UIAlertAction(title: content.confirmTitle, style: .destructive) { [weak self] _ in
            self?.viewModel.deleteAllRecords()
        })
        present(alert, animated: true)
    }

    // MARK: - Navigation

    private func pushResultDetail(for item: RecordDisplayItem) {
        let detailVC = ResultDetailViewController(item: item)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

// MARK: - UISearchBarDelegate

extension MainUserInfoViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchSubject.send(searchText)
    }
}

// MARK: - UICollectionViewDataSource

extension MainUserInfoViewController {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        viewModel.displaySections.count
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let sectionVM = viewModel.displaySections[section]
        switch sectionVM.kind {
        case .filterHeader: return 0
        case .recordGroup(_, let items): return items.count
        }
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader else {
            return UICollectionReusableView()
        }
        let sectionVM = viewModel.displaySections[indexPath.section]
        switch sectionVM.kind {
        case .filterHeader(let filterVM):
            let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: RecordFilterHeaderView.reuseId,
                for: indexPath
            ) as! RecordFilterHeaderView
            header.configure(with: filterVM)
            return header
        case .recordGroup(let title, _):
            let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: RecordSectionHeaderView.reuseId,
                for: indexPath
            ) as! RecordSectionHeaderView
            header.configure(title: title)
            return header
        }
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PerCapitaRecordCell.reuseId, for: indexPath) as! PerCapitaRecordCell
        let sectionVM = viewModel.displaySections[indexPath.section]
        if case .recordGroup(_, let items) = sectionVM.kind {
            cell.configure(with: items[indexPath.item].cell)
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let sectionVM = viewModel.displaySections[indexPath.section]
        guard case .recordGroup(_, let items) = sectionVM.kind,
              indexPath.item < items.count else { return }
        pushResultDetail(for: items[indexPath.item].detail)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension MainUserInfoViewController {
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width
        return CGSize(width: width, height: 120)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let sectionVM = viewModel.displaySections[section]
        let height: CGFloat
        switch sectionVM.kind {
        case .filterHeader: height = 56
        case .recordGroup(let title, _): height = title.isEmpty ? 0 : 40
        }
        return CGSize(width: collectionView.bounds.width, height: height)
    }
}
