//
//  ResultsFilterModel.swift
//  tip-calculator
//
//  Created by Willy Hsu on 2026/2/6.
//

import Foundation
import CoreData

struct RecordDisplayItem: Hashable {
    let dateText: String
    let billText: String
    let billValue: Double
    let totalTipText: String
    let totalBillText: String
    let totalBillValue: Double
    let amountPerPersonText: String
    let amountPerPersonValue: Double
    let splitText: String
    let tipDisplayText: String
    let addressText: String
    let locationNameText: String
    let latitude: Double?
    let longitude: Double?

    // MARK: - Mapper

    static func from(_ record: ConsumptionRecord, dateFormatter: DateFormatter) -> RecordDisplayItem {
        let dateText = record.createdAt.map { dateFormatter.string(from: $0) } ?? ""
        let tipDisplay = (record.tipRawValue?.isEmpty == false) ? (record.tipRawValue ?? "無") : "無"
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
            addressText: record.address ?? "",
            locationNameText: record.locationName ?? "",
            latitude: record.latitude?.doubleValue,
            longitude: record.longitude?.doubleValue
        )
    }
}
