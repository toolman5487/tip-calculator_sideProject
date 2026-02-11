//
//  MainUserInfoViewController.swift
//  tip-calculator
//
//  Created by Willy Hsu on 2026/2/5.
//

import UIKit
import SnapKit
import Combine

@MainActor
final class MainUserInfoViewController: MainBaseViewController {

    // MARK: - Properties

    private var cancellables = Set<AnyCancellable>()
    private let searchSubject = PassthroughSubject<String, Never>()
    private let viewModel = MainUserInfoViewModel()

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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.refresh()  
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigation()
        setupCollectionView()
        bindingViewModel()
        collectionView.dataSource = self
        collectionView.delegate = self
        bindToViewModel()
        viewModel.load()
    }

    // MARK: - Setup

    private func setupCollectionView() {
        collectionView.register(RecordFilterHeaderView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: RecordFilterHeaderView.reuseId)
        collectionView.register(WeekdaySectionHeaderView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: WeekdaySectionHeaderView.reuseId)
        collectionView.register(PerCapitaRecordCell.self,
                                forCellWithReuseIdentifier: PerCapitaRecordCell.reuseId)
    }

    private func bindingViewModel() {
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
    }

    private func bindToViewModel() {
        viewModel.$recordCount
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.collectionView.reloadData()
            }
            .store(in: &cancellables)

        viewModel.$selectedDateFilter
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink { [weak self] _ in
                self?.collectionView.reloadData()
            }
            .store(in: &cancellables)
    }

    private func setupNavigation() {
        title = "消費紀錄"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
        let refreshItem = UIBarButtonItem(
            image: UIImage(systemName: "arrow.clockwise"),
            style: .plain,
            target: self,
            action: #selector(refreshButtonTapped)
        )
        navigationItem.rightBarButtonItem = refreshItem
    }

    // MARK: - Actions

    @objc private func refreshButtonTapped() {
        triggerRefresh()
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
        viewModel.numberOfSections()
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.numberOfItems(in: section)
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            if viewModel.isFilterHeaderSection(indexPath.section) {
                let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: RecordFilterHeaderView.reuseId, for: indexPath) as! RecordFilterHeaderView
                let filterVM = RecordFilterHeaderViewModel(
                    selected: viewModel.selectedDateFilter,
                    onSelect: { [weak self] option in self?.viewModel.changeFilter(option) }
                )
                header.configure(with: filterVM)
                return header
            }
            if let title = viewModel.sectionTitle(for: indexPath.section) {
                let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: WeekdaySectionHeaderView.reuseId, for: indexPath) as! WeekdaySectionHeaderView
                header.configure(title: title)
                return header
            }
        }
        return UICollectionReusableView()
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PerCapitaRecordCell.reuseId, for: indexPath) as! PerCapitaRecordCell
        let vm = viewModel.viewModel(section: indexPath.section, item: indexPath.item)
        cell.configure(with: vm)
        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width
        return CGSize(width: width, height: 120)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let height: CGFloat = viewModel.isFilterHeaderSection(section) ? 56 : 48
        return CGSize(width: collectionView.bounds.width, height: height)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = viewModel.recordDisplayItem(section: indexPath.section, item: indexPath.item) else { return }
        let detailVC = ResultDetailViewController(item: item)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}
