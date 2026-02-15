//
//  ConsumptionTimeRange.swift
//  tip-calculator
//

import Foundation

enum ConsumptionTimeRange {
    case day
    case week
    case month
    case year

    func range(calendar: Calendar = .current, now: Date = Date()) -> (start: Date, end: Date)? {
        switch self {
        case .day:
            let start = calendar.startOfDay(for: now)
            return (start, now)
        case .week:
            guard let start = calendar.date(byAdding: .day, value: -7, to: now) else { return nil }
            return (start, now)
        case .month:
            guard let start = calendar.date(byAdding: .month, value: -1, to: now) else { return nil }
            return (start, now)
        case .year:
            guard let start = calendar.date(byAdding: .year, value: -1, to: now) else { return nil }
            return (start, now)
        }
    }

    func contains(_ date: Date, range r: (start: Date, end: Date)?) -> Bool {
        guard let r = r else { return false }
        return date >= r.start && date <= r.end
    }

    func rangesForChart(periods: Int, calendar: Calendar = .current, now: Date = Date()) -> [(start: Date, end: Date)] {
        var result: [(start: Date, end: Date)] = []
        switch self {
        case .day:
            for i in 0..<periods {
                guard let date = calendar.date(byAdding: .day, value: -i, to: now) else { continue }
                let start = calendar.startOfDay(for: date)
                let end = calendar.date(byAdding: .day, value: 1, to: start) ?? start
                result.append((start, end))
            }
        case .week:
            for i in 0..<periods {
                guard let end = calendar.date(byAdding: .day, value: -i * 7, to: now),
                      let start = calendar.date(byAdding: .day, value: -7, to: end) else { continue }
                result.append((start, end))
            }
        case .month:
            for i in 0..<periods {
                guard let end = calendar.date(byAdding: .month, value: -i, to: now),
                      let start = calendar.date(byAdding: .month, value: -1, to: end) else { continue }
                result.append((start, end))
            }
        case .year:
            for i in 0..<periods {
                guard let end = calendar.date(byAdding: .year, value: -i, to: now),
                      let start = calendar.date(byAdding: .year, value: -1, to: end) else { continue }
                result.append((start, end))
            }
        }
        result.reverse()
        return result
    }

    func bucketIndex(for date: Date, periods: Int, calendar: Calendar = .current, now: Date = Date()) -> Int? {
        switch self {
        case .day:
            let dStart = calendar.startOfDay(for: date)
            let nowStart = calendar.startOfDay(for: now)
            guard let days = calendar.dateComponents([.day], from: dStart, to: nowStart).day, days >= 0, days < periods else { return nil }
            return periods - 1 - days
        case .week:
            let sec = now.timeIntervalSince(date)
            guard sec >= 0 else { return nil }
            let periodSec: TimeInterval = 7 * 24 * 3600
            let periodsAgo = Int(sec / periodSec)
            guard periodsAgo < periods else { return nil }
            return periods - 1 - periodsAgo
        case .month:
            guard let months = calendar.dateComponents([.month], from: date, to: now).month, months >= 0, months < periods else { return nil }
            return periods - 1 - months
        case .year:
            guard let years = calendar.dateComponents([.year], from: date, to: now).year, years >= 0, years < periods else { return nil }
            return periods - 1 - years
        }
    }
}
