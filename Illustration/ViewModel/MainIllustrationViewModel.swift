//
//  MainIllustrationViewModel.swift
//  tip-calculator
//

import Foundation
import Combine

enum IllustrationSection: Int, CaseIterable {
    case filterHeader
    case kpi
    case timeChart
    case amountRangeChart
}

struct IllustrationFilterHeaderViewModel {
    let selected: IllustrationTimeFilterOption
    let options: [IllustrationTimeFilterOption]
    let onSelect: (IllustrationTimeFilterOption) -> Void

    init(selected: IllustrationTimeFilterOption, onSelect: @escaping (IllustrationTimeFilterOption) -> Void) {
        self.selected = selected
        self.options = IllustrationTimeFilterOption.allCases
        self.onSelect = onSelect
    }
}

extension IllustrationFilterHeaderViewModel {
    static func == (lhs: IllustrationFilterHeaderViewModel, rhs: IllustrationFilterHeaderViewModel) -> Bool {
        lhs.selected == rhs.selected
    }
}

struct IllustrationKPIDisplay {
    let totalRecordsText: String
    let averagePerPersonText: String
    let averageTipText: String
}

@MainActor
final class MainIllustrationViewModel {

    private let store: ConsumptionRecordStoring

    @Published private(set) var selectedTimeFilter: IllustrationTimeFilterOption = .day
    @Published private(set) var kpi: IllustrationKPISummary?
    @Published private(set) var kpiDisplay: IllustrationKPIDisplay?
    @Published private(set) var timeChartData: [TrendChartItem] = []
    @Published private(set) var amountRangeData: [AmountRangeChartItem] = []

    init(store: ConsumptionRecordStoring = ConsumptionRecordStore()) {
        self.store = store
    }

    func load() {
        let records = store.fetchAll()
        applyAggregation(from: records)
    }
    
    func resetFilterToDefault() {
        guard selectedTimeFilter != .day else { return }
        selectedTimeFilter = .day
    }

    func changeFilter(_ option: IllustrationTimeFilterOption) {
        guard option != selectedTimeFilter else { return }
        selectedTimeFilter = option
        load()
    }

    private func applyAggregation(from records: [ConsumptionRecord]) {
        let filtered = filterRecordsByTimeDimension(records)
        let summary = buildKPI(from: filtered)
        kpi = summary
        kpiDisplay = IllustrationKPIDisplay(
            totalRecordsText: Double(summary.totalRecords).abbreviatedFormatted,
            averagePerPersonText: summary.averagePerRecord.currencyAbbreviatedFormatted,
            averageTipText: summary.averageTip.currencyAbbreviatedFormatted
        )
        timeChartData = buildTimeChartData(from: records)
        amountRangeData = buildAmountRangeData(from: filtered)
    }

    private func buildKPI(from records: [ConsumptionRecord]) -> IllustrationKPISummary {
        let totalRecords = records.count
        let totalAmount = records.reduce(0) { $0 + $1.totalBill }
        let totalTip = records.reduce(0) { $0 + $1.totalTip }
        return IllustrationKPISummary(
            totalRecords: totalRecords,
            totalAmount: totalAmount,
            averagePerRecord: totalRecords > 0 ? totalAmount / Double(totalRecords) : 0,
            averageTip: totalRecords > 0 ? totalTip / Double(totalRecords) : 0
        )
    }

    private func filterRecordsByTimeDimension(_ records: [ConsumptionRecord]) -> [ConsumptionRecord] {
        let calendar = Calendar.current
        let now = Date()
        let timeRange = selectedTimeFilter.consumptionTimeRange
        guard let r = timeRange.range(calendar: calendar, now: now) else { return [] }
        return records.filter {
            guard let d = $0.createdAt else { return false }
            return timeRange.contains(d, range: r)
        }
    }

    private func buildTimeChartData(from records: [ConsumptionRecord]) -> [TrendChartItem] {
        let calendar = Calendar.current
        let now = Date()
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_TW")
        let timeRange = selectedTimeFilter.consumptionTimeRange
        let (periods, dateFormat): (Int, String) = {
            switch selectedTimeFilter {
            case .day: return (7, "M/d")
            case .week: return (12, "M/d")
            case .month: return (12, "M月")
            case .year: return (5, "yyyy年")
            }
        }()
        formatter.dateFormat = dateFormat
        let ranges = timeRange.rangesForChart(periods: periods, calendar: calendar, now: now)
        var sums: [Date: Double] = [:]
        for r in ranges { sums[r.start] = 0 }
        for record in records {
            guard let date = record.createdAt else { continue }
            guard let idx = timeRange.bucketIndex(for: date, periods: periods, calendar: calendar, now: now),
                  idx < ranges.count else { continue }
            let key = ranges[idx].start
            sums[key, default: 0] += record.totalBill
        }
        return ranges.map { r in
            TrendChartItem(label: formatter.string(from: r.start), totalAmount: sums[r.start] ?? 0)
        }
    }

    private func buildAmountRangeData(from records: [ConsumptionRecord]) -> [AmountRangeChartItem] {
        let rangeDefs: [(min: Double, max: Double, label: String)] = [
            (0, 500, "0-500"),
            (500, 1000, "500-1K"),
            (1000, 2000, "1K-2K"),
            (2000, 5000, "2K-5K"),
            (5000, Double.infinity, "5K+")
        ]

        var counts: [String: Int] = Dictionary(uniqueKeysWithValues: rangeDefs.map { ($0.label, 0) })
        for record in records {
            let amount = record.totalBill
            for def in rangeDefs {
                if amount >= def.min && amount < def.max {
                    counts[def.label, default: 0] += 1
                    break
                }
            }
        }

        return rangeDefs.map { def in
            AmountRangeChartItem(rangeLabel: def.label, count: counts[def.label] ?? 0)
        }
    }
}
