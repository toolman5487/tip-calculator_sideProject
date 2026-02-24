//
//  ConsumptionBreakdownViewModel.swift
//  tip-calculator
//
//  Created by Willy Hsu on 2026/2/20.
//

import Foundation
import Combine

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

    let detailItem: ConsumptionBreakdownItem

    @Published private(set) var selectedCategory: ConsumptionBreakdownCategoryOption = .all
    @Published private(set) var pieChartData: [PieChartSliceItem] = []

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
            return ConsumptionBreakdownCategoryRowDisplay(
                labelText: item.label,
                amountText: item.value.currencyFormatted,
                percentText: String(format: "%.0f%%", item.percent * 100),
                progressValue: min(1, max(0, item.percent)),
                colorIndex: index,
                iconName: item.iconName
            )
        }
    }

    init(detailItem: ConsumptionBreakdownItem) {
        self.detailItem = detailItem
        buildPieChartData()
    }

    func selectCategory(_ category: ConsumptionBreakdownCategoryOption) {
        guard selectedCategory != category else { return }
        selectedCategory = category
        buildPieChartData()
    }

    private var records: [ConsumptionRecord] {
        switch detailItem {
        case .timeChart(_, _, let r), .amountRangeChart(_, let r): return r
        }
    }

    private func filteredRecords() -> [ConsumptionRecord] {
        let base = records
        guard let id = selectedCategory.identifier else { return base }
        return base.filter { $0.categoryIdentifier == id }
    }

    private func buildPieChartData() {
        let filtered = filteredRecords()
        var sums: [String: Double] = [:]
        for record in filtered {
            let amount = record.totalBill
            let key = record.categoryIdentifier.flatMap { Category(identifier: $0)?.displayName } ?? "無"
            sums[key, default: 0] += amount
        }
        let labelOrder = Category.mainGridCategories.map(\.displayName)
            + Category.sheetCategories.map(\.displayName)
            + ["無"]
        pieChartData = labelOrder
            .compactMap { label -> PieChartSliceItem? in
                let v = sums[label] ?? 0
                return v > 0 ? PieChartSliceItem(label: label, value: v) : nil
            }
    }
}
