//
//  MainAccountDetailViewModel.swift
//  tip-calculator
//
//  Created by Willy Hsu on 2026/3/11.
//

import Combine
import CoreData
import Foundation

// MARK: - MainAccountDetailViewModel

@MainActor
final class MainAccountDetailViewModel {

    // MARK: - Dependencies

    private let store: ConsumptionRecordStoring

    // MARK: - Published State

    @Published private(set) var overviewItem: AccountDetailOverviewItem?
    @Published private(set) var sectionCount: Int = 2
    @Published private(set) var dataVersion: UInt = 0

    // MARK: - Init

    init(store: ConsumptionRecordStoring = ConsumptionRecordStore()) {
        self.store = store
    }

    // MARK: - Public

    func load() {
        let records = store.fetchAll()
        let snapshots = records.map { AccountDetailRecordSnapshot(from: $0) }
        Task {
            let item = await Task.detached(priority: .userInitiated) {
                Self.buildOverviewItem(from: snapshots)
            }.value
            overviewItem = item
            dataVersion += 1
        }
    }

    // MARK: - Cell 1: Carousel

    private nonisolated static func buildOverviewItem(from snapshots: [AccountDetailRecordSnapshot]) -> AccountDetailOverviewItem {
        let agg = aggregateInSinglePass(snapshots)
        let usageDays = agg.minDate.flatMap { minD in
            agg.maxDate.map { maxD in
                let components = Calendar.current.dateComponents([.day], from: minD, to: maxD)
                return (components.day ?? 0) + 1
            }
        }
        let topLocation = agg.locationCounts
            .filter { $0.key != "未知地區" || agg.locationCounts.count == 1 }
            .max(by: { $0.value < $1.value })?
            .key
        let topCategory = agg.categoryCounts
            .max(by: { $0.value < $1.value })
            .flatMap { Category(identifier: $0.key) }

        var statCardItems: [AccountDetailStatCardItem] = []
        if snapshots.count > 0 {
            statCardItems.append(AccountDetailStatCardItem(
                title: "總消費數量",
                value: "\(snapshots.count) 筆",
                systemImageName: nil
            ))
        }
        if let maxAmount = agg.maxAmount, maxAmount > 0 {
            statCardItems.append(AccountDetailStatCardItem(
                title: "最高單筆",
                value: maxAmount.currencyFormatted,
                systemImageName: nil
            ))
        }
        if let minAmount = agg.minAmount, minAmount > 0 {
            statCardItems.append(AccountDetailStatCardItem(
                title: "最低消費",
                value: minAmount.currencyFormatted,
                systemImageName: nil
            ))
        }
        if let days = usageDays, days > 0 {
            statCardItems.append(AccountDetailStatCardItem(
                title: "使用天數",
                value: "\(days) 天",
                systemImageName: nil
            ))
        }
        if let category = topCategory, !category.displayName.isEmpty {
            statCardItems.append(AccountDetailStatCardItem(
                title: "主要消費",
                value: category.displayName,
                systemImageName: category.systemImageName
            ))
        }
        if agg.locationCounts.count > 0 {
            statCardItems.append(AccountDetailStatCardItem(
                title: "消費地點",
                value: "\(agg.locationCounts.count) 處",
                systemImageName: nil
            ))
        }

        return AccountDetailOverviewItem(
            totalRecordCount: snapshots.count,
            totalRecordCountText: Double(snapshots.count).abbreviatedFormatted,
            personalConsumptionTotal: agg.personalTotal,
            personalConsumptionTotalText: agg.personalTotal.currencyFormatted,
            usageDays: usageDays,
            usageDaysText: usageDays.map { "\($0) 天" } ?? "—",
            topLocationName: topLocation ?? "—",
            statCardItems: statCardItems
        )
    }

    // MARK: - Single-Pass Aggregation

    private struct AccountDetailRecordSnapshot: Sendable {
        let amountPerPerson: Double
        let totalTip: Double
        let effectiveConsumptionTime: Date?
        let districtKey: String
        let categoryIdentifier: String?

        init(from record: ConsumptionRecord) {
            amountPerPerson = record.amountPerPerson
            totalTip = record.totalTip
            effectiveConsumptionTime = record.effectiveConsumptionTime
            districtKey = record.districtKey
            categoryIdentifier = record.categoryIdentifier
        }
    }

    private struct AggregationResult {
        var personalTotal: Double = 0
        var totalTip: Double = 0
        var minDate: Date?
        var maxDate: Date?
        var locationCounts: [String: Int] = [:]
        var categoryCounts: [String: Int] = [:]
        var maxAmount: Double?
        var minAmount: Double?
    }

    private nonisolated static func aggregateInSinglePass(_ snapshots: [AccountDetailRecordSnapshot]) -> AggregationResult {
        var agg = AggregationResult()
        for s in snapshots {
            agg.personalTotal += s.amountPerPerson
            agg.totalTip += s.totalTip
            if let d = s.effectiveConsumptionTime {
                if agg.minDate == nil || d < agg.minDate! { agg.minDate = d }
                if agg.maxDate == nil || d > agg.maxDate! { agg.maxDate = d }
            }
            agg.locationCounts[s.districtKey, default: 0] += 1
            if let id = s.categoryIdentifier, !id.isEmpty {
                agg.categoryCounts[id, default: 0] += 1
            }
            if agg.maxAmount == nil || s.amountPerPerson > agg.maxAmount! { agg.maxAmount = s.amountPerPerson }
            if agg.minAmount == nil || s.amountPerPerson < agg.minAmount! { agg.minAmount = s.amountPerPerson }
        }
        return agg
    }
}
