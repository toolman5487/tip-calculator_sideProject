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

@MainActor
final class MainIllustrationViewModel {

    private let store: ConsumptionRecordStoring

    @Published private(set) var selectedTimeFilter: IllustrationTimeFilterOption = .day
    @Published private(set) var kpi: IllustrationKPISummary?
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
        kpi = buildKPI(from: filtered)
        timeChartData = buildTimeChartData(from: records)
        amountRangeData = buildAmountRangeData(from: filtered)
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
            return records.filter {
                guard let date = $0.createdAt else { return false }
                return calendar.isDate(date, equalTo: now, toGranularity: .weekOfYear)
            }
        case .month:
            return records.filter {
                guard let date = $0.createdAt else { return false }
                return calendar.isDate(date, equalTo: now, toGranularity: .month)
            }
        case .year:
            return records.filter {
                guard let date = $0.createdAt else { return false }
                return calendar.isDate(date, equalTo: now, toGranularity: .year)
            }
        }
    }

    private func buildKPI(from records: [ConsumptionRecord]) -> IllustrationKPISummary {
        let totalRecords = records.count
        let totalAmount = records.reduce(0) { $0 + $1.totalBill }
        let totalPerPerson = records.reduce(0) { $0 + $1.amountPerPerson }
        let totalTip = records.reduce(0) { $0 + $1.totalTip }
        return IllustrationKPISummary(
            totalRecords: totalRecords,
            totalAmount: totalAmount,
            averagePerPerson: totalRecords > 0 ? totalPerPerson / Double(totalRecords) : 0,
            averageTip: totalRecords > 0 ? totalTip / Double(totalRecords) : 0
        )
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
            var weekSums: [(start: Date, end: Date)] = []
            for i in 0..<12 {
                guard let weekStart = calendar.date(byAdding: .weekOfYear, value: -i, to: now),
                      let range = calendar.dateInterval(of: .weekOfYear, for: weekStart) else { continue }
                weekSums.append((range.start, range.end))
            }
            weekSums.reverse()
            var sums: [Date: Double] = [:]
            for w in weekSums { sums[w.start] = 0 }
            for record in records {
                guard let date = record.createdAt else { continue }
                if let range = weekSums.first(where: { date >= $0.start && date < $0.end }) {
                    sums[range.start, default: 0] += record.totalBill
                }
            }
            return weekSums.map { w in
                TrendChartItem(label: formatter.string(from: w.start), totalAmount: sums[w.start] ?? 0)
            }

        case .month:
            formatter.dateFormat = "M月"
            let year = calendar.component(.year, from: now)
            var monthSums: [Int: Double] = Dictionary(uniqueKeysWithValues: (1...12).map { ($0, 0) })
            for record in records {
                guard let date = record.createdAt,
                      calendar.component(.year, from: date) == year else { continue }
                let month = calendar.component(.month, from: date)
                monthSums[month, default: 0] += record.totalBill
            }
            return (1...12).map { month in
                let d = calendar.date(from: DateComponents(year: year, month: month, day: 1)) ?? now
                return TrendChartItem(label: formatter.string(from: d), totalAmount: monthSums[month] ?? 0)
            }

        case .year:
            let currentYear = calendar.component(.year, from: now)
            let years = (0..<5).map { currentYear - $0 }.reversed()
            var yearSums: [Int: Double] = [:]
            for y in years { yearSums[y] = 0 }
            for record in records {
                guard let date = record.createdAt else { continue }
                let y = calendar.component(.year, from: date)
                if yearSums[y] != nil {
                    yearSums[y, default: 0] += record.totalBill
                }
            }
            return years.map { y in
                TrendChartItem(label: "\(y)年", totalAmount: yearSums[y] ?? 0)
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
