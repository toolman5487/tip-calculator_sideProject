//
//  ResultsFilterViewModel.swift
//  tip-calculator
//
//  Created by Willy Hsu on 2026/2/5.
//

import Foundation
import CoreData
import Combine

@MainActor
final class ResultsFilterViewModel {

    private let store: ConsumptionRecordStoring

    @Published private(set) var recordDisplayItems: [RecordDisplayItem] = []

    private var allRecords: [ConsumptionRecord] = []
    private var filteredRecords: [ConsumptionRecord] = []
    private var loadedCount: Int = 0
    private let pageSize: Int = 10
    private var currentKeyword: String = ""

    init(store: ConsumptionRecordStoring = ConsumptionRecordStore()) {
        self.store = store
    }

    func loadRecords() {
        allRecords = store.fetchAll()
        currentKeyword = ""
        filteredRecords = allRecords
        loadedCount = min(pageSize, filteredRecords.count)
        applyDisplayItems()
    }

    /// 重新從 store 取資料，並保留目前搜尋關鍵字再篩選一次
    func refresh() {
        allRecords = store.fetchAll()
        if currentKeyword.isEmpty {
            filteredRecords = allRecords
            loadedCount = min(pageSize, filteredRecords.count)
        } else {
            filter(keyword: currentKeyword)
            return
        }
        applyDisplayItems()
    }

    func loadMoreIfNeeded(currentIndex: Int) {
        guard currentKeyword.isEmpty else { return }
        guard currentIndex >= loadedCount - 3 else { return }
        guard loadedCount < filteredRecords.count else { return }

        loadedCount = min(loadedCount + pageSize, filteredRecords.count)
        applyDisplayItems()
    }

    func filter(keyword: String) {
        let trimmed = keyword.trimmingCharacters(in: .whitespacesAndNewlines)
        currentKeyword = trimmed

        if trimmed.isEmpty {
            filteredRecords = allRecords
            loadedCount = min(pageSize, filteredRecords.count)
        } else if let numeric = Double(trimmed) {
            let v = numeric
            filteredRecords = allRecords.filter { record in
                abs(record.bill - v) < 0.0001
                    || abs(record.totalBill - v) < 0.0001
                    || abs(record.amountPerPerson - v) < 0.0001
            }
            loadedCount = filteredRecords.count
        } else {
            filteredRecords = allRecords.filter { record in
                (record.address ?? "").localizedCaseInsensitiveContains(trimmed)
            }
            loadedCount = filteredRecords.count
        }
        applyDisplayItems()
    }

    // MARK: - Private

    private func applyDisplayItems() {
        let slice = Array(filteredRecords.prefix(loadedCount))
        recordDisplayItems = slice.map { RecordDisplayItem.from($0, dateFormatter: AppDateFormatters.detail) }
    }
}
