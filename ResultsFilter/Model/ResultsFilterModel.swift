//
//  ResultsFilterModel.swift
//  tip-calculator
//
//  Created by Willy Hsu on 2026/2/6.
//

import Foundation
import CoreData

struct RecordDisplayItem: Hashable {
    let id: UUID?
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
    let categoryDisplayText: String
    let addressText: String
    let locationNameText: String
    let latitude: Double?
    let longitude: Double?

    static func categoryDisplayText(from identifier: String?) -> String {
        guard let id = identifier else { return "—" }
        switch id {
        case "food": return "食"
        case "clothing": return "衣"
        case "housing": return "住"
        case "transport": return "行"
        case "education": return "育"
        case "entertainment": return "樂"
        default: return "—"
        }
    }

    // MARK: - Mapper

    static func from(_ snapshot: RecordSnapshot, dateText: String) -> RecordDisplayItem {
        let tipDisplay = (snapshot.tipRawValue?.isEmpty == false) ? (snapshot.tipRawValue ?? "無") : "無"
        return RecordDisplayItem(
            id: snapshot.id,
            dateText: dateText,
            billText: snapshot.bill.currencyFormatted,
            billValue: snapshot.bill,
            totalTipText: snapshot.totalTip.currencyFormatted,
            totalBillText: snapshot.totalBill.currencyFormatted,
            totalBillValue: snapshot.totalBill,
            amountPerPersonText: snapshot.amountPerPerson.currencyFormatted,
            amountPerPersonValue: snapshot.amountPerPerson,
            splitText: "\(snapshot.split) 人",
            tipDisplayText: tipDisplay,
            categoryDisplayText: categoryDisplayText(from: snapshot.categoryIdentifier),
            addressText: snapshot.address ?? "",
            locationNameText: snapshot.locationName ?? "",
            latitude: snapshot.latitude,
            longitude: snapshot.longitude
        )
    }

    static func from(_ record: ConsumptionRecord, dateFormatter: DateFormatter, dateText: String? = nil) -> RecordDisplayItem {
        let snapshot = RecordSnapshot(record)
        let resolvedDateText = dateText ?? record.createdAt.map { dateFormatter.string(from: $0) } ?? ""
        return from(snapshot, dateText: resolvedDateText)
    }
}
