//
//  TotalResultViewModel.swift
//  tip-calculator
//
//  Created by Willy Hsu on 2026/2/5.
//

import Foundation

@MainActor
enum TotalResultRow: Int, CaseIterable {
    case amountPerPerson
    case totalBill
    case totalTip
    case bill
    case tip
    case split
    case save

    var title: String {
        switch self {
        case .amountPerPerson: return "Amount per person"
        case .totalBill:       return "Total bill (with tip)"
        case .totalTip:        return "Total tip"
        case .bill:            return "Bill"
        case .tip:             return "Tip"
        case .split:           return "Split"
        case .save:            return "Save record"
        }
    }

    func value(from result: Result) -> String {
        switch self {
        case .amountPerPerson:
            return result.amountPerPerson.currencyFormatted
        case .totalBill:
            return result.totalBill.currencyFormatted
        case .totalTip:
            return result.totalTip.currencyFormatted
        case .bill:
            return result.bill.currencyFormatted
        case .tip:
            return result.tip.stringValue.isEmpty ? "None" : result.tip.stringValue
        case .split:
            return "\(result.split)"
        case .save:
            return ""
        }
    }
}

@MainActor
final class TotalResultViewModel {

    let result: Result
    let rows: [TotalResultRow] = TotalResultRow.allCases
    private let store: ConsumptionRecordStoring

    init(result: Result, store: ConsumptionRecordStoring = ConsumptionRecordStore()) {
        self.result = result
        self.store = store
    }

    func saveRecord() {
        if store.save(result: result) {
            print("Saved ConsumptionRecord")
        }
    }
}

