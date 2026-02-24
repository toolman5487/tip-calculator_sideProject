//
//  ChartDetailViewModel.swift
//  tip-calculator
//
//  Created by Willy Hsu on 2026/2/20.
//

import Foundation
import Combine

@MainActor
final class ChartDetailViewModel {

    let detailItem: ChartDetailItem

    @Published private(set) var selectedCategory: ChartDetailCategoryOption = .all
    @Published private(set) var pieChartData: [PieChartSliceItem] = []

    init(detailItem: ChartDetailItem) {
        self.detailItem = detailItem
        buildPieChartData()
    }

    func selectCategory(_ category: ChartDetailCategoryOption) {
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
