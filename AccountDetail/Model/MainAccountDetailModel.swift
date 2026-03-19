//
//  MainAccountDetailModel.swift
//  tip-calculator
//
//  Created by Willy Hsu on 2026/3/11.
//

import Foundation

// MARK: - Cell 0: Header

struct AccountDetailOverviewItem {
    let totalRecordCount: Int
    let totalRecordCountText: String
    let personalConsumptionTotal: Double
    let personalConsumptionTotalText: String
    let usageDays: Int?
    let usageDaysText: String
    let topLocationName: String
    let statCardItems: [AccountDetailStatCardItem]
    let categoryDistributionItems: [AccountDetailCategoryDistributionItem]
    let achievementSections: [AccountDetailAchievementSection]
}

struct AccountDetailAchievementSection: Equatable {
    let title: String
    let personalTotal: Double
    let maxTarget: Double
    let gaugeProgress: Double
    let progressRangeText: String
}

// MARK: - Cell 1: Carousel

struct AccountDetailStatCardItem {
    let title: String
    let value: String
    let systemImageName: String?
}

struct AccountDetailCategoryDistributionItem: Equatable {
    let displayName: String
    let amount: Double
    let percentage: Double
    let systemImageName: String?
}

// MARK: - Section

enum AccountDetailSection: Int, CaseIterable {
    case header
    case carousel
    case categoryDistribution
    case achievement
    case aiAnalysis

    static var effectiveCases: [AccountDetailSection] {
        if #available(iOS 18, *) {
            return allCases
        } else {
            return allCases.filter { $0 != .aiAnalysis }
        }
    }

    static func effectiveSection(at index: Int) -> AccountDetailSection? {
        guard index >= 0, index < effectiveCases.count else { return nil }
        return effectiveCases[index]
    }
}
