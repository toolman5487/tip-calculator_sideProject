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
        return filtered.compactMap { s in records.first { $0.id == s.id } }
    }

    func apply(to snapshots: [RecordSnapshot]) -> [RecordSnapshot] {
        let calendar = Calendar.current
        let now = Date()

        let filtered: [RecordSnapshot]
        switch self {
        case .day:
            filtered = snapshots.filter {
                guard let date = $0.createdAt else { return false }
                return calendar.isDateInToday(date)
            }
        case .week:
            filtered = snapshots.filter {
                guard let date = $0.createdAt else { return false }
                return calendar.isDate(date, equalTo: now, toGranularity: .weekOfYear)
            }
        case .month:
            filtered = snapshots.filter {
                guard let date = $0.createdAt else { return false }
                return calendar.isDate(date, equalTo: now, toGranularity: .month)
            }
        case .year:
            filtered = snapshots.filter {
                guard let date = $0.createdAt else { return false }
                return calendar.isDate(date, equalTo: now, toGranularity: .year)
            }
        case .newest, .oldest, .mostExpensive, .cheapest:
            filtered = snapshots
        }

        switch self {
        case .newest, .day, .week, .month, .year:
            return filtered.sorted {
                ($0.createdAt ?? .distantPast) > ($1.createdAt ?? .distantPast)
            }
        case .oldest:
            return filtered.sorted {
                ($0.createdAt ?? .distantPast) < ($1.createdAt ?? .distantPast)
            }
        case .mostExpensive:
            return filtered.sorted { $0.amountPerPerson > $1.amountPerPerson }
        case .cheapest:
            return filtered.sorted { $0.amountPerPerson < $1.amountPerPerson }
        }
    }
}
