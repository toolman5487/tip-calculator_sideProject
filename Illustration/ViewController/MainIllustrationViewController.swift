//
//  MainIllustrationViewController.swift
//  tip-calculator
//

import Combine
import UIKit
import SnapKit

@MainActor
final class MainIllustrationViewController: MainBaseViewController {

    private var cancellables = Set<AnyCancellable>()
    private let viewModel = MainIllustrationViewModel()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.load()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigation()
        setupCollectionView()
        bindingViewModel()
        collectionView.dataSource = self
        collectionView.delegate = self
        viewModel.load()
    }

    private func setupNavigation() {
        title = "統計資料"
        let refreshItem = UIBarButtonItem(
            image: UIImage(systemName: "arrow.clockwise"),
            style: .plain,
            target: self,
            action: #selector(refreshButtonTapped)
        )
        navigationItem.rightBarButtonItem = refreshItem
    }

    private func setupCollectionView() {
        collectionView.register(IllustrationFilterHeaderView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: IllustrationFilterHeaderView.reuseId)
        collectionView.register(KPICardCell.self, forCellWithReuseIdentifier: KPICardCell.reuseId)
        collectionView.register(IllustrationChartCell.self, forCellWithReuseIdentifier: IllustrationChartCell.reuseId)
        collectionView.register(IllustrationSectionHeaderView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: IllustrationSectionHeaderView.reuseId)
    }

    private func bindingViewModel() {
        refreshPublisher
            .sink { [weak self] _ in
                self?.viewModel.load()
            }
            .store(in: &cancellables)

        viewModel.$selectedTimeFilter
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.collectionView.reloadData()
            }
            .store(in: &cancellables)

        viewModel.$kpi
            .map { _ in }
            .merge(with: viewModel.$timeChartData.map { _ in })
            .merge(with: viewModel.$amountRangeData.map { _ in })
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.collectionView.reloadData()
            }
            .store(in: &cancellables)
    }

    @objc private func refreshButtonTapped() {
        triggerRefresh()
    }
}

// MARK: - UICollectionViewDataSource

extension MainIllustrationViewController {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        IllustrationSection.allCases.count
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch IllustrationSection(rawValue: section) {
        case .filterHeader: return 0
        case .kpi: return 4
        case .timeChart, .amountRangeChart: return 1
        case .none: return 0
        }
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader else {
            return UICollectionReusableView()
        }
        switch IllustrationSection(rawValue: indexPath.section) {
        case .filterHeader:
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: IllustrationFilterHeaderView.reuseId, for: indexPath) as! IllustrationFilterHeaderView
            let filterVM = IllustrationFilterHeaderViewModel(
                selected: viewModel.selectedTimeFilter,
                onSelect: { [weak self] option in self?.viewModel.changeFilter(option) }
            )
            header.configure(with: filterVM)
            return header
        case .kpi:
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: IllustrationSectionHeaderView.reuseId, for: indexPath) as! IllustrationSectionHeaderView
            header.configure(title: "總覽")
            return header
        case .timeChart:
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: IllustrationSectionHeaderView.reuseId, for: indexPath) as! IllustrationSectionHeaderView
            header.configure(title: "消費趨勢")
            return header
        case .amountRangeChart:
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: IllustrationSectionHeaderView.reuseId, for: indexPath) as! IllustrationSectionHeaderView
            header.configure(title: "消費金額區間")
            return header
        case .none:
            return UICollectionReusableView()
        }
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch IllustrationSection(rawValue: indexPath.section) {
        case .filterHeader:
            return collectionView.dequeueReusableCell(withReuseIdentifier: MainBaseViewController.defaultCellReuseId, for: indexPath)

        case .kpi:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: KPICardCell.reuseId, for: indexPath) as! KPICardCell
            if let kpi = viewModel.kpi {
                switch indexPath.item {
                case 0: cell.configure(title: "總消費筆數", value: "\(kpi.totalRecords)")
                case 1: cell.configure(title: "總消費金額", value: kpi.totalAmount.currencyFormatted)
                case 2: cell.configure(title: "平均每人", value: kpi.averagePerPerson.currencyFormatted)
                case 3: cell.configure(title: "平均小費", value: kpi.averageTip.currencyFormatted)
                default: break
                }
            }
            return cell

        case .timeChart:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: IllustrationChartCell.reuseId, for: indexPath) as! IllustrationChartCell
            let title = viewModel.selectedTimeFilter.title + "消費"
            cell.configureTimeChart(title: title, data: viewModel.timeChartData)
            return cell

        case .amountRangeChart:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: IllustrationChartCell.reuseId, for: indexPath) as! IllustrationChartCell
            cell.configureAmountRange(title: "筆數分布", data: viewModel.amountRangeData)
            return cell

        case .none:
            return collectionView.dequeueReusableCell(withReuseIdentifier: MainBaseViewController.defaultCellReuseId, for: indexPath)
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension MainIllustrationViewController {
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width
        switch IllustrationSection(rawValue: indexPath.section) {
        case .filterHeader:
            return .zero
        case .kpi:
            let sectionInset: CGFloat = 24
            let spacing: CGFloat = 16
            let cellWidth = (width - sectionInset - spacing) / 2
            return CGSize(width: cellWidth, height: 88)
        case .timeChart, .amountRangeChart:
            return CGSize(width: width, height: 260)
        case .none:
            return CGSize(width: width, height: 44)
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        switch IllustrationSection(rawValue: section) {
        case .filterHeader:
            return CGSize(width: collectionView.bounds.width, height: 56)
        default:
            return CGSize(width: collectionView.bounds.width, height: 44)
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        switch IllustrationSection(rawValue: section) {
        case .filterHeader:
            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        default:
            return UIEdgeInsets(top: 8, left: 12, bottom: 16, right: 12)
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        IllustrationSection(rawValue: section) == .kpi ? 16 : 0
    }
}
