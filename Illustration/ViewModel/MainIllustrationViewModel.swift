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
    let averagePerRecordText: String
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
            averagePerRecordText: summary.averagePerRecord.currencyAbbreviatedFormatted,
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
        switch selectedTimeFilter {
        case .day:
            return records.filter {
                guard let date = $0.createdAt else { return false }
                return calendar.isDateInToday(date)
            }
        case .week:
            guard let start = calendar.date(byAdding: .day, value: -7, to: now) else { return [] }
            return records.filter {
                guard let d = $0.createdAt else { return false }
                return d >= start && d <= now
            }
        case .month:
            guard let start = calendar.date(byAdding: .month, value: -1, to: now) else { return [] }
            return records.filter {
                guard let d = $0.createdAt else { return false }
                return d >= start && d <= now
            }
        case .year:
            guard let start = calendar.date(byAdding: .year, value: -1, to: now) else { return [] }
            return records.filter {
                guard let d = $0.createdAt else { return false }
                return d >= start && d <= now
            }
        }
    }

    private func buildTimeChartData(from records: [ConsumptionRecord]) -> [TrendChartItem] {
        let calendar = Calendar.current
        let now = Date()
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_TW")

        switch selectedTimeFilter {
        case .day:
            formatter.dateFormat = "M/d"
            var daySums: [Date: Double] = [:]
            for i in 0..<7 {
                guard let date = calendar.date(byAdding: .day, value: -i, to: now) else { continue }
                let start = calendar.startOfDay(for: date)
                daySums[start] = 0
            }
            for record in records {
                guard let date = record.createdAt else { continue }
                let start = calendar.startOfDay(for: date)
                if daySums[start] != nil {
                    daySums[start, default: 0] += record.totalBill
                }
            }
            return (0..<7).reversed().compactMap { i -> TrendChartItem? in
                guard let date = calendar.date(byAdding: .day, value: -i, to: now) else { return nil }
                let start = calendar.startOfDay(for: date)
                return TrendChartItem(label: formatter.string(from: start), totalAmount: daySums[start] ?? 0)
            }

        case .week:
            formatter.dateFormat = "M/d"
            var ranges: [(start: Date, end: Date)] = []
            for i in 0..<12 {
                guard let end = calendar.date(byAdding: .day, value: -i * 7, to: now),
                      let start = calendar.date(byAdding: .day, value: -7, to: end) else { continue }
                ranges.append((start, end))
            }
            ranges.reverse()
            var sums: [Date: Double] = [:]
            for r in ranges { sums[r.start] = 0 }
            for record in records {
                guard let date = record.createdAt else { continue }
                if let r = ranges.first(where: { date >= $0.start && date < $0.end }) {
                    sums[r.start, default: 0] += record.totalBill
                }
            }
            return ranges.map { r in
                TrendChartItem(label: formatter.string(from: r.start), totalAmount: sums[r.start] ?? 0)
            }

        case .month:
            formatter.dateFormat = "M月"
            var ranges: [(start: Date, end: Date)] = []
            for i in 0..<12 {
                guard let end = calendar.date(byAdding: .month, value: -i, to: now),
                      let start = calendar.date(byAdding: .month, value: -1, to: end) else { continue }
                ranges.append((start, end))
            }
            ranges.reverse()
            var sums: [Date: Double] = [:]
            for r in ranges { sums[r.start] = 0 }
            for record in records {
                guard let date = record.createdAt else { continue }
                if let r = ranges.first(where: { date >= $0.start && date < $0.end }) {
                    sums[r.start, default: 0] += record.totalBill
                }
            }
            return ranges.map { r in
                TrendChartItem(label: formatter.string(from: r.start), totalAmount: sums[r.start] ?? 0)
            }

        case .year:
            var ranges: [(start: Date, end: Date)] = []
            for i in 0..<5 {
                guard let end = calendar.date(byAdding: .year, value: -i, to: now),
                      let start = calendar.date(byAdding: .year, value: -1, to: end) else { continue }
                ranges.append((start, end))
            }
            ranges.reverse()
            var sums: [Date: Double] = [:]
            for r in ranges { sums[r.start] = 0 }
            for record in records {
                guard let date = record.createdAt else { continue }
                if let r = ranges.first(where: { date >= $0.start && date < $0.end }) {
                    sums[r.start, default: 0] += record.totalBill
                }
            }
            formatter.dateFormat = "yyyy年"
            return ranges.map { r in
                TrendChartItem(label: formatter.string(from: r.start), totalAmount: sums[r.start] ?? 0)
            }
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
