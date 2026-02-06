//
//  ResultsFilterViewModel.swift
//  tip-calculator
//
//  Created by Willy Hsu on 2026/2/5.
//

import Foundation
import CoreData
import Combine

final class ResultsFilterViewModel {

    private let store: ConsumptionRecordStoring
    private let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .short
        f.locale = Locale(identifier: "zh_TW")
        return f
    }()

    @Published private(set) var recordDisplayItems: [RecordDisplayItem] = []
    private var allItems: [RecordDisplayItem] = []
    private let pageSize: Int = 10
    private var currentKeyword: String = ""

    init(store: ConsumptionRecordStoring = ConsumptionRecordStore()) {
        self.store = store
    }

    @MainActor
    func loadRecords() {
        let records = store.fetchAll()
        allItems = records.map { record in
            let dateText = record.createdAt.map { dateFormatter.string(from: $0) } ?? ""
            let tipDisplay = (record.tipRawValue?.isEmpty == false) ? (record.tipRawValue ?? "無") : "無"
            let addressText = record.address ?? ""
            let latitude = record.latitude?.doubleValue
            let longitude = record.longitude?.doubleValue
            return RecordDisplayItem(
                dateText: dateText,
                billText: record.bill.currencyFormatted,
                billValue: record.bill,
                totalTipText: record.totalTip.currencyFormatted,
                totalBillText: record.totalBill.currencyFormatted,
                totalBillValue: record.totalBill,
                amountPerPersonText: record.amountPerPerson.currencyFormatted,
                amountPerPersonValue: record.amountPerPerson,
                splitText: "\(record.split) 人",
                tipDisplayText: tipDisplay,
                addressText: addressText,
                latitude: latitude,
                longitude: longitude
            )
        }
        if currentKeyword.isEmpty {
            recordDisplayItems = Array(allItems.prefix(pageSize))
        } else {
            filter(keyword: currentKeyword)
        }
    }

    @MainActor
    func loadMoreIfNeeded(currentIndex: Int) {
        guard currentKeyword.isEmpty else { return }

        let loadedCount = recordDisplayItems.count
        guard loadedCount < allItems.count else { return }
        guard currentIndex >= loadedCount - 3 else { return }

        let nextEnd = min(loadedCount + pageSize, allItems.count)
        guard nextEnd > loadedCount else { return }
        let nextSlice = allItems[loadedCount..<nextEnd]
        recordDisplayItems.append(contentsOf: nextSlice)
    }

    @MainActor
    func filter(keyword: String) {
        let trimmed = keyword.trimmingCharacters(in: .whitespacesAndNewlines)
        currentKeyword = trimmed

        if trimmed.isEmpty {
            recordDisplayItems = Array(allItems.prefix(pageSize))
        } else if let numeric = Double(trimmed) {
            recordDisplayItems = allItems.filter { item in
                let v = numeric
                let billMatch = abs(item.billValue - v) < 0.0001
                let totalMatch = abs(item.totalBillValue - v) < 0.0001
                let perPersonMatch = abs(item.amountPerPersonValue - v) < 0.0001
                return billMatch || totalMatch || perPersonMatch
            }
        } else {
            recordDisplayItems = allItems.filter { item in
                return item.addressText.localizedCaseInsensitiveContains(trimmed)
            }
        }
    }
}
