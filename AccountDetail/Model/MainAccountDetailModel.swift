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
    let achievementItems: [AccountDetailAchievementItem]
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

struct AccountDetailAchievementItem: Equatable {
    let displayName: String
    let targetAmount: Double
    let progress: Double
    let isCompleted: Bool
}

// MARK: - Section

enum AccountDetailSection: Int, CaseIterable {
    case header
    case carousel
    case categoryDistribution
    case achievement
}
