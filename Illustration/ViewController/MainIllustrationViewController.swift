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
    private var cachedNavBarAppearance: UINavigationBarAppearance?

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.resetFilterToDefault()
        viewModel.load()
        applyNavigationBarTrendColor()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigation()
        setupCollectionView()
        bindingViewModel()
        collectionView.dataSource = self
        collectionView.delegate = self
    }

    private func setupNavigation() {
        title = "統計資料"
        navigationItem.rightBarButtonItem = .refreshBarButton { [weak self] in
            self?.triggerRefresh()
        }
    }

    private func applyNavigationBarTrendColor() {
        let color = trendColor(for: viewModel.personalConsumptionTrend)
        let appearance = cachedNavBarAppearance ?? {
            let a = UINavigationBarAppearance()
            a.configureWithDefaultBackground()
            a.largeTitleTextAttributes = [.foregroundColor: UIColor.systemBackground]
            a.titleTextAttributes = [.foregroundColor: UIColor.systemBackground]
            cachedNavBarAppearance = a
            return a
        }()
        if appearance.backgroundColor != color {
            appearance.backgroundColor = color
        }
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        navigationController?.navigationBar.tintColor = .systemBackground
    }

    private func trendColor(for trend: KPITrend?) -> UIColor {
        switch trend {
        case .up: return ThemeColor.trendUp
        case .down: return ThemeColor.trendDown
        case .equal, .none: return ThemeColor.trendFlat
        }
    }

    private func setupCollectionView() {
        collectionView.register(IllustrationFilterHeaderView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: IllustrationFilterHeaderView.reuseId)
        collectionView.register(IllustrationSectionHeaderView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: IllustrationSectionHeaderView.reuseId)
        collectionView.register(IllustrationResultCell.self, forCellWithReuseIdentifier: IllustrationResultCell.reuseId)
        collectionView.register(KPICarouselCell.self, forCellWithReuseIdentifier: KPICarouselCell.reuseId)
        collectionView.register(IllustrationLocationStatsCell.self, forCellWithReuseIdentifier: IllustrationLocationStatsCell.reuseId)
        collectionView.register(IllustrationTimeChartCell.self, forCellWithReuseIdentifier: IllustrationTimeChartCell.reuseId)
    }

    private func bindingViewModel() {
        refreshPublisher
            .sink { [weak self] _ in
                self?.viewModel.load()
            }
            .store(in: &cancellables)

        viewModel.$dataVersion
            .dropFirst()
            .sink { [weak self] _ in
                self?.applyNavigationBarTrendColor()
                self?.collectionView.reloadData()
            }
            .store(in: &cancellables)
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
        case .result: return 1
        case .kpi: return 1
        case .timeChart: return 1
        case .locationStats: return 1
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
                selectedColor: trendColor(for: viewModel.personalConsumptionTrend),
                onSelect: { [weak self] option in self?.viewModel.changeFilter(option) }
            )
            header.configure(with: filterVM)
            return header
        case .result:
            return UICollectionReusableView()
        case .kpi:
            return UICollectionReusableView()
        case .timeChart, .locationStats:
            guard let section = IllustrationSection(rawValue: indexPath.section),
                  let title = viewModel.sectionHeaderTitle(for: section) else {
                return UICollectionReusableView()
            }
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: IllustrationSectionHeaderView.reuseId, for: indexPath) as! IllustrationSectionHeaderView
            header.configure(title: title)
            return header
        case .none:
            return UICollectionReusableView()
        }
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch IllustrationSection(rawValue: indexPath.section) {
        case .filterHeader:
            return collectionView.dequeueReusableCell(withReuseIdentifier: MainBaseViewController.defaultCellReuseId, for: indexPath)
        case .result:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: IllustrationResultCell.reuseId, for: indexPath) as! IllustrationResultCell
            cell.configure(items: viewModel.kpiCardItems)
            return cell
        case .kpi:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: KPICarouselCell.reuseId, for: indexPath) as! KPICarouselCell
            let comparisonLabel = viewModel.selectedTimeFilter.consumptionTimeRange.comparisonPeriodLabel
            cell.configure(items: viewModel.kpiCardItems, comparisonLabel: comparisonLabel)
            return cell

        case .timeChart:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: IllustrationTimeChartCell.reuseId, for: indexPath) as! IllustrationTimeChartCell
            cell.configure(data: viewModel.timeChartData, barColor: trendColor(for: viewModel.personalConsumptionTrend))
            return cell
        case .locationStats:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: IllustrationLocationStatsCell.reuseId, for: indexPath) as! IllustrationLocationStatsCell
            cell.configure(data: viewModel.locationStats)
            return cell
        case .none:
            return collectionView.dequeueReusableCell(withReuseIdentifier: MainBaseViewController.defaultCellReuseId, for: indexPath)
        }
    }
}

// MARK: - UICollectionViewDelegate

extension MainIllustrationViewController {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let section = IllustrationSection(rawValue: indexPath.section) else { return }
        switch section {
        case .timeChart:
            let title = viewModel.sectionHeaderTitle(for: .timeChart) ?? "消費趨勢"
            let vc = ConsumptionBreakdownViewController(detailItem: .timeChart(title: title, timeFilter: viewModel.selectedTimeFilter))
            navigationController?.pushViewController(vc, animated: true)
        case .locationStats:
            let title = viewModel.sectionHeaderTitle(for: .locationStats) ?? "消費地區"
            let vc = LocationDetailViewController(title: title, timeFilter: viewModel.selectedTimeFilter)
            navigationController?.pushViewController(vc, animated: true)
        case .filterHeader, .result, .kpi:
            break
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
        case .result:
            let horizontalInset: CGFloat = 16 * 2
            let cellWidth = max(0, width - horizontalInset)
            let cellHeight = cellWidth * 0.6
            return CGSize(width: cellWidth, height: cellHeight)
        case .kpi:
            let inset: CGFloat = 12 * 2
            let spacing: CGFloat = 8 * 2
            let cellSide = width > 0 ? max(0, (width - inset - spacing) / 3) : 100
            return CGSize(width: width, height: cellSide)
        case .timeChart:
            return CGSize(width: width, height: 260)
        case .locationStats:
            let displayCount = IllustrationLocationStatsCell.displayItems(from: viewModel.locationStats).count
            return CGSize(width: width, height: IllustrationLocationStatsCell.preferredHeight(itemCount: displayCount))
        case .none:
            return CGSize(width: width, height: 44)
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        switch IllustrationSection(rawValue: section) {
        case .filterHeader:
            return CGSize(width: collectionView.bounds.width, height: 56)
        case .result:
            return CGSize(width: collectionView.bounds.width, height: 0)
        case .kpi:
            return CGSize(width: collectionView.bounds.width, height: 0)
        default:
            return CGSize(width: collectionView.bounds.width, height: 44)
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        switch IllustrationSection(rawValue: section) {
        case .filterHeader:
            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        case .result:
            return UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        case .kpi:
            return UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        default:
            return UIEdgeInsets(top: 8, left: 16, bottom: 16, right: 16)
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        0
    }
}
