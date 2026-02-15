//
//  MainIllustrationModel.swift
//  tip-calculator
//

import Foundation

enum IllustrationTimeFilterOption: Int, CaseIterable {
    case day
    case week
    case month
    case year

    var title: String {
        switch self {
        case .day: return "每日消費"
        case .week: return "每週消費"
        case .month: return "每月消費"
        case .year: return "每年消費"
        }
    }

    var consumptionTimeRange: ConsumptionTimeRange {
        switch self {
        case .day: return .day
        case .week: return .week
        case .month: return .month
        case .year: return .year
        }
    }
}

struct IllustrationKPISummary {
    let totalRecords: Int
    let totalAmount: Double
    let averagePerRecord: Double
    let averageTip: Double
}

struct MonthlyChartItem {
    let month: Int
    let label: String
    let totalAmount: Double
}

struct AmountRangeChartItem {
    let rangeLabel: String
    let count: Int
}

struct TrendChartItem {
    let label: String
    let totalAmount: Double
}
