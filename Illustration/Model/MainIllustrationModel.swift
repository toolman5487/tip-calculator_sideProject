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
        case .day: return "每日"
        case .week: return "每週"
        case .month: return "每月"
        case .year: return "每年"
        }
    }
}

struct IllustrationKPISummary {
    let totalRecords: Int
    let totalAmount: Double
    let averagePerPerson: Double
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
