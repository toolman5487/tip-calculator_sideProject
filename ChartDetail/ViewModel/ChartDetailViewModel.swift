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
        switch selectedCategory {
        case .all: return base
        case .food: return base.filter { $0.categoryIdentifier == "food" }
        case .clothing: return base.filter { $0.categoryIdentifier == "clothing" }
        case .housing: return base.filter { $0.categoryIdentifier == "housing" }
        case .transport: return base.filter { $0.categoryIdentifier == "transport" }
        case .education: return base.filter { $0.categoryIdentifier == "education" }
        case .entertainment: return base.filter { $0.categoryIdentifier == "entertainment" }
        }
    }

    private func buildPieChartData() {
        let filtered = filteredRecords()
        var sums: [String: Double] = [
            "食": 0, "衣": 0, "住": 0, "行": 0, "育": 0, "樂": 0, "無": 0
        ]
        for record in filtered {
            let amount = record.totalBill
            let key: String
            switch record.categoryIdentifier {
            case "food": key = "食"
            case "clothing": key = "衣"
            case "housing": key = "住"
            case "transport": key = "行"
            case "education": key = "育"
            case "entertainment": key = "樂"
            default: key = "無"
            }
            sums[key, default: 0] += amount
        }
        pieChartData = ["食", "衣", "住", "行", "育", "樂", "無"]
            .compactMap { label -> PieChartSliceItem? in
                let v = sums[label] ?? 0
                return v > 0 ? PieChartSliceItem(label: label, value: v) : nil
            }
    }
}
