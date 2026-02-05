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
        case .amountPerPerson: return "每人應付金額"
        case .totalBill:       return "含小費總金額"
        case .totalTip:        return "小費總額"
        case .bill:            return "帳單金額"
        case .tip:             return "小費設定"
        case .split:           return "分攤人數"
        case .save:            return "儲存紀錄"
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
            return result.tip.stringValue.isEmpty ? "無" : result.tip.stringValue
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

    @discardableResult
    func saveRecord() -> Bool {
        store.save(result: result)
    }
}

