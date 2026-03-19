//
//  MainAccountDetailViewModel.swift
//  tip-calculator
//
//  Created by Willy Hsu on 2026/3/11.
//

import Combine
import Foundation

// MARK: - MainAccountDetailViewModel

@MainActor
final class MainAccountDetailViewModel {

    // MARK: - Dependencies

    private let store: ConsumptionRecordStoring

    // MARK: - Published State

    @Published private(set) var overviewItem: AccountDetailOverviewItem?
    var sectionCount: Int { AccountDetailSection.effectiveCases.count }
    @Published private(set) var dataVersion: UInt = 0

    // MARK: - Init

    init(store: ConsumptionRecordStoring = ConsumptionRecordStore()) {
        self.store = store
    }

    // MARK: - Public

    var exportShareText: String {
        let totalCountText = overviewItem?.totalRecordCountText ?? "—"
        let totalAmountText = overviewItem?.personalConsumptionTotalText ?? "—"
        let usageDaysText = overviewItem?.usageDaysText ?? "—"
        let topLocationText = overviewItem?.topLocationName ?? "—"
        return """
        匯出全部資料
        總筆數：\(totalCountText)
        個人總消費：\(totalAmountText)
        使用天數：\(usageDaysText)
        常去地點：\(topLocationText)
        """
    }

    func exportAllRecordsText() -> String {
        let records = store.fetchAll()
        guard !records.isEmpty else { return "目前沒有任何資料" }

        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "zh_Hant_TW")
        dateFormatter.timeZone = .current
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"

        var lines: [String] = []
        lines.append("匯出全部資料")
        lines.append("總筆數：\(records.count)")
        lines.append("")
        lines.append("時間\t帳單\tTip\t總金額\t每人\t人數\tTip型態\t分類\t地點\t地址\t緯度\t經度")

        for record in records {
            let timeText = dateFormatter.string(from: record.effectiveConsumptionTime ?? .distantPast)
            let billText = String(format: "%.2f", record.bill)
            let tipText = String(format: "%.2f", record.totalTip)
            let totalText = String(format: "%.2f", record.totalBill)
            let perPersonText = String(format: "%.2f", record.amountPerPerson)
            let splitText = "\(record.split)"
            let tipRaw = record.tipRawValue ?? ""
            let category = record.categoryIdentifier ?? ""
            let location = record.locationName ?? ""
            let address = record.address ?? ""
            let lat = record.latitude?.stringValue ?? ""
            let lon = record.longitude?.stringValue ?? ""

            lines.append([
                timeText,
                billText,
                tipText,
                totalText,
                perPersonText,
                splitText,
                tipRaw,
                category,
                location,
                address,
                lat,
                lon
            ].joined(separator: "\t"))
        }

        return lines.joined(separator: "\n")
    }

    func load() {
        let records = store.fetchAll()
        let snapshots = records.map { AccountDetailOverviewUseCase.RecordSnapshot(from: $0) }
        Task {
            let item = await Task.detached(priority: .userInitiated) {
                AccountDetailOverviewUseCase.buildOverview(from: snapshots)
            }.value
            overviewItem = item
            dataVersion += 1
        }
    }

    func headerTitle(for sectionIndex: Int) -> String? {
        guard let section = AccountDetailSection.effectiveSection(at: sectionIndex) else { return nil }
        switch section {
        case .categoryDistribution:
            return "消費分布"
        case .achievement:
            return "消費成就"
        case .header, .carousel, .aiAnalysis:
            return nil
        }
    }
}
