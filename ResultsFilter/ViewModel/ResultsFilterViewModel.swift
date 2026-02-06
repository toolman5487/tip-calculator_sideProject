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

    init(store: ConsumptionRecordStoring = ConsumptionRecordStore()) {
        self.store = store
    }

    @MainActor
    func loadRecords() {
        let records = store.fetchAll()
        recordDisplayItems = records.map { record in
            let dateText = record.createdAt.map { dateFormatter.string(from: $0) } ?? ""
            let tipDisplay = (record.tipRawValue?.isEmpty == false) ? (record.tipRawValue ?? "無") : "無"
            let addressText = record.address ?? ""
            return RecordDisplayItem(
                dateText: dateText,
                billText: record.bill.currencyFormatted,
                totalTipText: record.totalTip.currencyFormatted,
                totalBillText: record.totalBill.currencyFormatted,
                amountPerPersonText: record.amountPerPerson.currencyFormatted,
                splitText: "\(record.split) 人",
                tipDisplayText: tipDisplay,
                addressText: addressText
            )
        }
    }
}
