//
//  AccountDetailOverviewUseCase.swift
//  tip-calculator
//

import Foundation

enum AccountDetailOverviewUseCase {

    struct RecordSnapshot: Sendable {
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

    static func buildOverview(from snapshots: [RecordSnapshot]) -> AccountDetailOverviewItem {
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
        let topCategory = agg.categoryAmounts
            .max(by: { a, b in
                if a.value != b.value { return a.value < b.value }
                return a.key > b.key
            })
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

        let categoryDistributionItems = buildCategoryDistributionItems(agg: agg)
        let achievementSections = buildAchievementSections(personalTotal: agg.personalTotal)
        return AccountDetailOverviewItem(
            totalRecordCount: snapshots.count,
            totalRecordCountText: Double(snapshots.count).abbreviatedFormatted,
            personalConsumptionTotal: agg.personalTotal,
            personalConsumptionTotalText: agg.personalTotal.currencyFormatted,
            usageDays: usageDays,
            usageDaysText: usageDays.map { "\($0) 天" } ?? "—",
            topLocationName: topLocation ?? "—",
            statCardItems: statCardItems,
            categoryDistributionItems: categoryDistributionItems,
            achievementSections: achievementSections
        )
    }
}

// MARK: - Private

private extension AccountDetailOverviewUseCase {

    struct AggregationResult {
        var personalTotal: Double = 0
        var minDate: Date?
        var maxDate: Date?
        var locationCounts: [String: Int] = [:]
        var categoryAmounts: [String: Double] = [:]
        var maxAmount: Double?
        var minAmount: Double?
    }

    static func aggregateInSinglePass(_ snapshots: [RecordSnapshot]) -> AggregationResult {
        var agg = AggregationResult()
        for s in snapshots {
            agg.personalTotal += s.amountPerPerson
            if let d = s.effectiveConsumptionTime {
                if agg.minDate == nil || d < agg.minDate! { agg.minDate = d }
                if agg.maxDate == nil || d > agg.maxDate! { agg.maxDate = d }
            }
            agg.locationCounts[s.districtKey, default: 0] += 1
            if let id = s.categoryIdentifier, !id.isEmpty {
                agg.categoryAmounts[id, default: 0] += s.amountPerPerson
            }
            if agg.maxAmount == nil || s.amountPerPerson > agg.maxAmount! { agg.maxAmount = s.amountPerPerson }
            if agg.minAmount == nil || s.amountPerPerson < agg.minAmount! { agg.minAmount = s.amountPerPerson }
        }
        return agg
    }

    static func buildCategoryDistributionItems(agg: AggregationResult) -> [AccountDetailCategoryDistributionItem] {
        let total = agg.personalTotal
        guard total > 0, !agg.categoryAmounts.isEmpty else { return [] }
        let sorted = agg.categoryAmounts.sorted { $0.value > $1.value }
        let top4 = Array(sorted.prefix(4))
        let others = sorted.dropFirst(4)
        let othersAmount = others.reduce(0.0) { $0 + $1.value }
        var items: [AccountDetailCategoryDistributionItem] = []
        for (id, amount) in top4 {
            guard let category = Category(identifier: id) else { continue }
            items.append(AccountDetailCategoryDistributionItem(
                displayName: category.displayName,
                amount: amount,
                percentage: amount / total * 100,
                systemImageName: category.systemImageName
            ))
        }
        if othersAmount > 0 {
            items.append(AccountDetailCategoryDistributionItem(
                displayName: "其他",
                amount: othersAmount,
                percentage: othersAmount / total * 100,
                systemImageName: "ellipsis.circle"
            ))
        }
        return Array(items.prefix(5))
    }

    static func buildAchievementSections(personalTotal: Double) -> [AccountDetailAchievementSection] {
        let kTargets: [Double] = [10_000, 100_000, 1_000_000]
        let mTargets: [Double] = [10_000_000, 100_000_000, 1_000_000_000]
        let bTargets: [Double] = [10_000_000_000, 100_000_000_000, 1_000_000_000_000]
        let tTargets: [Double] = [1_000_000_000_000, 10_000_000_000_000, 100_000_000_000_000]
        return [
            AccountDetailAchievementSection(title: "K Level", items: kTargets.map { makeAchievementItem(target: $0, personalTotal: personalTotal) }, personalTotal: personalTotal, maxTarget: 1_000_000, gaugeProgress: gaugeProgress(targets: kTargets, personalTotal: personalTotal), progressRangeText: progressRangeText(targets: kTargets, personalTotal: personalTotal)),
            AccountDetailAchievementSection(title: "M Level", items: mTargets.map { makeAchievementItem(target: $0, personalTotal: personalTotal) }, personalTotal: personalTotal, maxTarget: 1_000_000_000, gaugeProgress: gaugeProgress(targets: mTargets, personalTotal: personalTotal), progressRangeText: progressRangeText(targets: mTargets, personalTotal: personalTotal)),
            AccountDetailAchievementSection(title: "B Level", items: bTargets.map { makeAchievementItem(target: $0, personalTotal: personalTotal) }, personalTotal: personalTotal, maxTarget: 1_000_000_000_000, gaugeProgress: gaugeProgress(targets: bTargets, personalTotal: personalTotal), progressRangeText: progressRangeText(targets: bTargets, personalTotal: personalTotal)),
            AccountDetailAchievementSection(title: "T Level", items: tTargets.map { makeAchievementItem(target: $0, personalTotal: personalTotal) }, personalTotal: personalTotal, maxTarget: 100_000_000_000_000, gaugeProgress: gaugeProgress(targets: tTargets, personalTotal: personalTotal), progressRangeText: progressRangeText(targets: tTargets, personalTotal: personalTotal))
        ]
    }

    private static func progressRangeText(targets: [Double], personalTotal: Double) -> String {
        guard let (_, denom) = progressValues(targets: targets, personalTotal: personalTotal) else { return "0 / 0" }
        return "\(personalTotal.progressFormatted) / \(denom.progressFormatted)"
    }

    private static func gaugeProgress(targets: [Double], personalTotal: Double) -> Double {
        guard let (current, denom) = progressValues(targets: targets, personalTotal: personalTotal) else { return 0 }
        return min(1, current / denom)
    }

    private static func progressValues(targets: [Double], personalTotal: Double) -> (current: Double, denom: Double)? {
        let sorted = targets.sorted()
        guard let first = sorted.first, let last = sorted.last else { return nil }
        let denom = max(1, last - 1)
        let current: Double
        if personalTotal < first {
            current = 0
        } else {
            current = min(personalTotal, last)
        }
        return (current, denom)
    }

    private static func makeAchievementItem(target: Double, personalTotal: Double) -> AccountDetailAchievementItem {
        let displayName = milestoneDisplayName(target: target)
        let progress = target > 0 ? min(1, personalTotal / target) : 0
        let isCompleted = personalTotal >= target
        return AccountDetailAchievementItem(
            displayName: displayName,
            targetAmount: target,
            progress: progress,
            isCompleted: isCompleted
        )
    }

    private static func milestoneDisplayName(target: Double) -> String {
        switch target {
        case 10_000: return "10K"
        case 100_000: return "100K"
        case 1_000_000: return "1M"
        case 10_000_000: return "10M"
        case 100_000_000: return "100M"
        case 1_000_000_000: return "1B"
        case 10_000_000_000: return "10B"
        case 100_000_000_000: return "100B"
        case 1_000_000_000_000: return "1T"
        case 10_000_000_000_000: return "10T"
        case 100_000_000_000_000: return "100T"
        default: return target.currencyFormatted
        }
    }
}
