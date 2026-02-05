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

    var title: String {
        switch self {
        case .amountPerPerson: return "Amount per person"
        case .totalBill:       return "Total bill (with tip)"
        case .totalTip:        return "Total tip"
        case .bill:            return "Bill"
        case .tip:             return "Tip"
        case .split:           return "Split"
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
        }
    }
}

@MainActor
final class TotalResultViewModel {

    let result: Result
    let rows: [TotalResultRow] = TotalResultRow.allCases

    init(result: Result) {
        self.result = result
    }
}

