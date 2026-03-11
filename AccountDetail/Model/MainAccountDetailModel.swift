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
}

// MARK: - Cell 1: Carousel

struct AccountDetailStatCardItem {
    let title: String
    let value: String
    let systemImageName: String?
}

// MARK: - Section

enum AccountDetailSection: Int, CaseIterable {
    case header
    case carousel
}
