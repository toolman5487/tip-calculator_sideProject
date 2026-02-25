//
//  ConsumptionBreakdownViewModel.swift
//  tip-calculator
//
//  Created by Willy Hsu on 2026/2/20.
//

import Foundation
import Combine

struct ConsumptionBreakdownRankItemDisplay {
    let title: String
    let dateText: String
    let amountText: String
    let peopleText: String
}

struct ConsumptionBreakdownCategoryRowDisplay {
    let labelText: String
    let amountText: String
    let percentText: String
    let progressValue: Double
    let colorIndex: Int
    let iconName: String?
}

@MainActor
final class ConsumptionBreakdownViewModel {

    private static let labelOrder: [String] = Category.mainGridCategories.map(\.displayName)
        + Category.sheetCategories.map(\.displayName)
        + ["未知"]

    private let store: ConsumptionRecordStoring
    let detailItem: ConsumptionBreakdownItem

    @Published private(set) var pieChartData: [PieChartSliceItem] = []

    var shouldShowRankList: Bool { !top10RankDisplays.isEmpty }

    var rankListSectionTitle: String { "消費 Top 10" }
    var categoryListSectionTitle: String { "消費分類" }

    var top10Records: [ConsumptionRecord] {
        let filtered = filteredRecords()
        return Array(filtered.sorted { $0.totalBill > $1.totalBill }.prefix(10))
    }

    var top10RankDisplays: [ConsumptionBreakdownRankItemDisplay] {
        top10Records.compactMap { record -> ConsumptionBreakdownRankItemDisplay? in
            guard let date = record.createdAt else { return nil }
            let categoryName = record.categoryIdentifier.flatMap { Category(identifier: $0)?.displayName } ?? "未知"
            return ConsumptionBreakdownRankItemDisplay(
                title: categoryName,
                dateText: AppDateFormatters.list.string(from: date),
                amountText: record.totalBill.currencyFormatted,
                peopleText: "\(record.split) 人"
            )
        }
    }

    var categoryRowDisplays: [ConsumptionBreakdownCategoryRowDisplay] {
        let data = pieChartData
        let total = data.reduce(0) { $0 + $1.value }
        guard total > 0 else { return [] }
        return data.enumerated().map { index, slice in
            let percent = slice.value / total
            let iconName = Category.allCases.first { $0.displayName == slice.label }?.systemImageName
            let item = ConsumptionBreakdownCategoryRowItem(
                label: slice.label,
                value: slice.value,
                percent: percent,
                iconName: iconName
            )
            let percentText = String(format: "%.2f%%", item.percent * 100)
            return ConsumptionBreakdownCategoryRowDisplay(
                labelText: item.label,
                amountText: item.value.currencyFormatted,
                percentText: percentText,
                progressValue: min(1, max(0, item.percent)),
                colorIndex: index,
                iconName: item.iconName
            )
        }
    }

    func recordDisplayItem(forRankIndex index: Int) -> RecordDisplayItem? {
        let records = top10Records
        guard index >= 0, index < records.count else { return nil }
        return RecordDisplayItem.from(records[index], dateFormatter: AppDateFormatters.detail)
    }

    init(detailItem: ConsumptionBreakdownItem, store: ConsumptionRecordStoring = ConsumptionRecordStore()) {
        self.store = store
        self.detailItem = detailItem
        buildPieChartData()
    }

    func reload() {
        buildPieChartData()
    }

    private var timeFilter: IllustrationTimeFilterOption {
        switch detailItem {
        case .timeChart(_, let f), .amountRangeChart(_, let f): return f
        }
    }

    private func filteredRecords() -> [ConsumptionRecord] {
        let all = store.fetchAll()
        let calendar = Calendar.current
        let now = Date()
        let timeRange = timeFilter.consumptionTimeRange
        guard let r = timeRange.range(calendar: calendar, now: now) else { return [] }
        return all.filter {
            guard let d = $0.createdAt else { return false }
            return timeRange.contains(d, range: r)
        }
    }

    private func buildPieChartData() {
        let filtered = filteredRecords()
        var sums: [String: Double] = [:]
        for record in filtered {
            let key = record.categoryIdentifier.flatMap { Category(identifier: $0)?.displayName } ?? "未知"
            sums[key, default: 0] += record.totalBill
        }
        pieChartData = Self.labelOrder
            .compactMap { label -> PieChartSliceItem? in
                let v = sums[label] ?? 0
                return v > 0 ? PieChartSliceItem(label: label, value: v) : nil
            }
    }
}
