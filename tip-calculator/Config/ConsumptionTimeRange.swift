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
            guard let sixDaysAgo = calendar.date(byAdding: .day, value: -6, to: now) else { return nil }
            let start = calendar.startOfDay(for: sixDaysAgo)
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
        r.map { date >= $0.start && date <= $0.end } ?? false
    }

    func rangesForChart(periods: Int, calendar: Calendar = .current, now: Date = Date()) -> [(start: Date, end: Date)] {
        typealias RangeTuple = (start: Date, end: Date)
        let indices = (0..<periods).reversed()

        switch self {
        case .day:
            return indices.compactMap { i -> RangeTuple? in
                guard let date = calendar.date(byAdding: .day, value: -i, to: now) else { return nil }
                let start = calendar.startOfDay(for: date)
                let end = calendar.date(byAdding: .day, value: 1, to: start) ?? start
                return (start, end)
            }
        case .week:
            return indices.compactMap { i -> RangeTuple? in
                guard let startDate = calendar.date(byAdding: .day, value: -6 - i * 7, to: now) else { return nil }
                let start = calendar.startOfDay(for: startDate)
                let end = i == 0 ? now : calendar.date(byAdding: .day, value: -6 - (i - 1) * 7, to: now).map { calendar.startOfDay(for: $0) }
                guard let end = end else { return nil }
                return (start, end)
            }
        case .month:
            return indices.compactMap { i -> RangeTuple? in
                guard let end = calendar.date(byAdding: .month, value: -i, to: now),
                      let start = calendar.date(byAdding: .month, value: -1, to: end) else { return nil }
                return (start, end)
            }
        case .year:
            return indices.compactMap { i -> RangeTuple? in
                guard let end = calendar.date(byAdding: .year, value: -i, to: now),
                      let start = calendar.date(byAdding: .year, value: -1, to: end) else { return nil }
                return (start, end)
            }
        }
    }

    func bucketIndex(for date: Date, periods: Int, calendar: Calendar = .current, now: Date = Date()) -> Int? {
        switch self {
        case .day:
            let dStart = calendar.startOfDay(for: date)
            let nowStart = calendar.startOfDay(for: now)
            guard let days = calendar.dateComponents([.day], from: dStart, to: nowStart).day, days >= 0, days < periods else { return nil }
            return periods - 1 - days
        case .week:
            guard let sixDaysAgo = calendar.date(byAdding: .day, value: -6, to: now) else { return nil }
            let week0Start = calendar.startOfDay(for: sixDaysAgo)
            guard date <= now else { return nil }
            if date >= week0Start { return periods - 1 }
            let daysBefore = calendar.dateComponents([.day], from: date, to: week0Start).day ?? 0
            let periodIndex = periods - 1 - (1 + (daysBefore - 1) / 7)
            guard periodIndex >= 0, periodIndex < periods else { return nil }
            return periodIndex
        case .month:
            guard let months = calendar.dateComponents([.month], from: date, to: now).month, months >= 0, months < periods else { return nil }
            return periods - 1 - months
        case .year:
            guard let years = calendar.dateComponents([.year], from: date, to: now).year, years >= 0, years < periods else { return nil }
            return periods - 1 - years
        }
    }
}
