//
//  MainIllustrationViewModel.swift
//  tip-calculator
//

import Foundation
import Combine

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
    let personalConsumptionTotalText: String
}

@MainActor
final class MainIllustrationViewModel {

    private let store: ConsumptionRecordStoring

    @Published private(set) var selectedTimeFilter: IllustrationTimeFilterOption = .day
    @Published private(set) var kpi: IllustrationKPISummary?
    @Published private(set) var kpiDisplay: IllustrationKPIDisplay?
    @Published private(set) var timeChartData: [TrendChartItem] = []
    @Published private(set) var locationStats: [LocationStatItem] = []
    @Published private(set) var filteredRecords: [ConsumptionRecord] = []

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

    var kpiCardItems: [KPICardItem] {
        let display = kpiDisplay ?? IllustrationKPIDisplay(totalRecordsText: "0", averagePerPersonText: "$0", personalConsumptionTotalText: "$0")
        return [
            KPICardItem(title: "總消費筆數", value: display.totalRecordsText),
            KPICardItem(title: "平均每筆消費", value: display.averagePerPersonText),
            KPICardItem(title: "個人消費總和", value: display.personalConsumptionTotalText)
        ]
    }

    func sectionHeaderTitle(for section: IllustrationSection) -> String? {
        switch section {
        case .filterHeader, .kpi: return nil
        case .timeChart: return "消費趨勢"
        case .locationStats: return "消費地區"
        }
    }

    private func applyAggregation(from records: [ConsumptionRecord]) {
        let filtered = filterRecordsByTimeDimension(records)
        filteredRecords = filtered
        let summary = buildKPI(from: filtered)
        kpi = summary
        kpiDisplay = IllustrationKPIDisplay(
            totalRecordsText: Double(summary.totalRecords).abbreviatedFormatted,
            averagePerPersonText: summary.averagePerRecord.currencyAbbreviatedFormatted,
            personalConsumptionTotalText: summary.totalAmount.currencyAbbreviatedFormatted
        )
        timeChartData = buildTimeChartData(from: records)
        locationStats = buildLocationStats(from: filtered)
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
        var sums = Dictionary(uniqueKeysWithValues: ranges.map { ($0.start, 0.0) })
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

    private func buildLocationStats(from records: [ConsumptionRecord]) -> [LocationStatItem] {
        var counts: [String: Int] = [:]
        for record in records {
            let raw = record.locationName?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            let key = raw.isEmpty ? "未知地區" : raw
            counts[key, default: 0] += 1
        }
        return counts
            .map { LocationStatItem(name: $0.key, count: $0.value) }
            .sorted { $0.count == $1.count ? $0.name < $1.name : $0.count > $1.count }
    }

}
