//
//  RecordFilterOption.swift
//  tip-calculator
//

import Foundation

enum RecordFilterOption: Int, CaseIterable {
    case newest
    case day
    case week
    case month
    case year
    case mostExpensive
    case cheapest
    case oldest

    var title: String {
        switch self {
        case .newest:        return "最新紀錄"
        case .day:           return "本日消費"
        case .week:          return "本週消費"
        case .month:         return "本月消費"
        case .year:          return "今年消費"
        case .mostExpensive: return "最高消費"
        case .cheapest:      return "最低消費"
        case .oldest:        return "最舊紀錄"
        }
    }

    func apply(to records: [ConsumptionRecord]) -> [ConsumptionRecord] {
        let snapshots = records.map { RecordSnapshot($0) }
        let filtered = apply(to: snapshots)
        let byId = Dictionary(uniqueKeysWithValues: records.compactMap { r in r.id.map { ($0, r) } })
        return filtered.compactMap { s in s.id.flatMap { byId[$0] } }
    }

    private var consumptionTimeRange: ConsumptionTimeRange? {
        switch self {
        case .day: return .day
        case .week: return .week
        case .month: return .month
        case .year: return .year
        default: return nil
        }
    }

    func apply(to snapshots: [RecordSnapshot]) -> [RecordSnapshot] {
        let calendar = Calendar.current
        let now = Date()
        let filtered: [RecordSnapshot]
        if let timeRange = consumptionTimeRange, let r = timeRange.range(calendar: calendar, now: now) {
            filtered = snapshots.filter {
                guard let d = $0.createdAt else { return false }
                return timeRange.contains(d, range: r)
            }
        } else {
            filtered = snapshots
        }
        switch self {
        case .newest, .day, .week, .month, .year:
            return filtered.sorted { ($0.createdAt ?? .distantPast) > ($1.createdAt ?? .distantPast) }
        case .oldest:
            return filtered.sorted { ($0.createdAt ?? .distantPast) < ($1.createdAt ?? .distantPast) }
        case .mostExpensive:
            return filtered.sorted { $0.amountPerPerson > $1.amountPerPerson }
        case .cheapest:
            return filtered.sorted { $0.amountPerPerson < $1.amountPerPerson }
        }
    }
}
