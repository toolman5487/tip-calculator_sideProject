//
//  MainIllustrationViewModel.swift
//  tip-calculator
//

import Combine
import Foundation

struct IllustrationKPIDisplay {
    let totalRecordsText: String
    let averagePerPersonText: String
    let personalConsumptionTotalText: String
}

@MainActor
final class MainIllustrationViewModel {

    private let store: ConsumptionRecordStoring

    @Published private(set) var selectedTimeFilter: IllustrationTimeFilterOption = .day
    private(set) var kpi: IllustrationKPISummary?
    @Published private(set) var kpiDisplay: IllustrationKPIDisplay?
    @Published private(set) var kpiCardItems: [KPICardItem] = []
    @Published private(set) var timeChartData: [TrendChartItem] = []
    @Published private(set) var locationStats: [LocationStatItem] = []
    @Published private(set) var filteredRecords: [ConsumptionRecord] = []
    @Published private(set) var dataVersion: UInt = 0

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

    var personalConsumptionTrend: KPITrend? {
        guard kpiCardItems.count > 1 else { return nil }
        return kpiCardItems[1].trend
    }

    private func buildKpiCardItems(
        display: IllustrationKPIDisplay,
        currentSummary: IllustrationKPISummary,
        allRecords: [ConsumptionRecord]
    ) -> [KPICardItem] {
        let calendar = Calendar.current
        let now = Date()
        let timeRange = selectedTimeFilter.consumptionTimeRange
        guard let prevRange = timeRange.previousPeriodRange(calendar: calendar, now: now) else {
            return [
                KPICardItem(title: "平均每筆消費", value: display.averagePerPersonText, actualValue: display.averagePerPersonText, trend: nil),
                KPICardItem(title: "個人消費總和", value: display.personalConsumptionTotalText, actualValue: display.personalConsumptionTotalText, trend: nil),
                KPICardItem(title: "總消費筆數", value: display.totalRecordsText, actualValue: display.totalRecordsText, trend: nil)
            ]
        }
        let prevRecords = allRecords.filter {
            guard let d = $0.effectiveConsumptionTime else { return false }
            return d >= prevRange.start && d < prevRange.end
        }
        let prevSummary = buildKPI(from: prevRecords)
        let recordDelta = currentSummary.totalRecords - prevSummary.totalRecords
        let averageDelta = currentSummary.averagePerRecord - prevSummary.averagePerRecord
        let personalDelta = currentSummary.personalConsumptionTotal - prevSummary.personalConsumptionTotal
        return [
            KPICardItem(
                title: "平均每筆消費",
                value: formatDelta(averageDelta, isCurrency: true),
                actualValue: display.averagePerPersonText,
                trend: compare(currentSummary.averagePerRecord, prevSummary.averagePerRecord)
            ),
            KPICardItem(
                title: "個人消費總和",
                value: formatDelta(personalDelta, isCurrency: true),
                actualValue: display.personalConsumptionTotalText,
                trend: compare(currentSummary.personalConsumptionTotal, prevSummary.personalConsumptionTotal)
            ),
            KPICardItem(
                title: "總消費筆數",
                value: formatDelta(recordDelta, isCurrency: false),
                actualValue: display.totalRecordsText,
                trend: compare(currentSummary.totalRecords, prevSummary.totalRecords)
            )
        ]
    }

    private func formatDelta(_ delta: Double, isCurrency: Bool) -> String {
        let absDelta = abs(delta)
        if isCurrency {
            return absDelta.currencyAbbreviatedFormatted
        } else {
            return "\(Int(absDelta))"
        }
    }

    private func formatDelta(_ delta: Int, isCurrency: Bool) -> String {
        formatDelta(Double(delta), isCurrency: isCurrency)
    }

    private func compare<T: Comparable>(_ current: T, _ previous: T) -> KPITrend {
        if current > previous { return .up }
        if current < previous { return .down }
        return .equal
    }

    func sectionHeaderTitle(for section: IllustrationSection) -> String? {
        switch section {
        case .filterHeader, .result, .kpi: return nil
        case .timeChart: return "消費趨勢"
        case .locationStats: return "消費地區"
        }
    }

    private func applyAggregation(from records: [ConsumptionRecord]) {
        let filtered = filterRecordsByTimeDimension(records)
        filteredRecords = filtered
        let summary = buildKPI(from: filtered)
        kpi = summary
        let display = IllustrationKPIDisplay(
            totalRecordsText: Double(summary.totalRecords).abbreviatedFormatted,
            averagePerPersonText: summary.averagePerRecord.currencyAbbreviatedFormatted,
            personalConsumptionTotalText: summary.personalConsumptionTotal.currencyAbbreviatedFormatted
        )
        kpiDisplay = display
        kpiCardItems = buildKpiCardItems(display: display, currentSummary: summary, allRecords: records)
        timeChartData = buildTimeChartData(from: records)
        locationStats = buildLocationStats(from: filtered)
        dataVersion += 1
    }

    private func buildKPI(from records: [ConsumptionRecord]) -> IllustrationKPISummary {
        let (totalAmount, personalConsumptionTotal, totalTip) = records.reduce((0.0, 0.0, 0.0)) { acc, r in
            (acc.0 + r.totalBill, acc.1 + r.amountPerPerson, acc.2 + r.totalTip)
        }
        let totalRecords = records.count
        return IllustrationKPISummary(
            totalRecords: totalRecords,
            totalAmount: totalAmount,
            personalConsumptionTotal: personalConsumptionTotal,
            averagePerRecord: totalRecords > 0 ? personalConsumptionTotal / Double(totalRecords) : 0,
            averageTip: totalRecords > 0 ? totalTip / Double(totalRecords) : 0
        )
    }

    private func filterRecordsByTimeDimension(_ records: [ConsumptionRecord]) -> [ConsumptionRecord] {
        selectedTimeFilter.consumptionTimeRange.filter(records)
    }

    private static let chartDateFormatters: [String: DateFormatter] = {
        ["M/d", "M月", "yyyy年"].reduce(into: [:]) { acc, format in
            let f = DateFormatter()
            f.locale = Locale(identifier: "zh_TW")
            f.dateFormat = format
            acc[format] = f
        }
    }()

    private func buildTimeChartData(from records: [ConsumptionRecord]) -> [TrendChartItem] {
        let calendar = Calendar.current
        let now = Date()
        let timeRange = selectedTimeFilter.consumptionTimeRange
        let (periods, dateFormat): (Int, String) = {
            switch selectedTimeFilter {
            case .day: return (7, "M/d")
            case .week: return (12, "M/d")
            case .month: return (12, "M月")
            case .year: return (5, "yyyy年")
            }
        }()
        let formatter = Self.chartDateFormatters[dateFormat]
            ?? { let f = DateFormatter(); f.locale = Locale(identifier: "zh_TW"); f.dateFormat = dateFormat; return f }()
        let ranges = timeRange.rangesForChart(periods: periods, calendar: calendar, now: now)
        var sums = Dictionary(uniqueKeysWithValues: ranges.map { ($0.start, 0.0) })
        for record in records {
            guard let date = record.effectiveConsumptionTime else { continue }
            guard let idx = timeRange.bucketIndex(for: date, periods: periods, calendar: calendar, now: now),
                  idx < ranges.count else { continue }
            let key = ranges[idx].start
            sums[key, default: 0] += record.amountPerPerson 
        }
        return ranges.map { r in
            TrendChartItem(label: formatter.string(from: r.start), totalAmount: sums[r.start] ?? 0)
        }
    }

    private func buildLocationStats(from records: [ConsumptionRecord]) -> [LocationStatItem] {
        var counts: [String: Int] = [:]
        for record in records {
            counts[record.districtKey, default: 0] += 1
        }
        return counts
            .map { LocationStatItem(name: $0.key, count: $0.value) }
            .sorted { $0.count == $1.count ? $0.name < $1.name : $0.count > $1.count }
    }

}
