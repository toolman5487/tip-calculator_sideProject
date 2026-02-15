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
}
