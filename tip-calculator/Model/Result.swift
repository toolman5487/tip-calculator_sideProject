//
//  Result.swift
//  tip-calculator
//
//  Created by Willy Hsu on 2025/3/30.
//

import Foundation

struct Result: Sendable {
    let amountPerPerson: Double
    let totalBill: Double
    let totalTip: Double
    let bill: Double
    let tip: Tip
    let split: Int
    /// 消費種類 identifier，如 "food", "clothing"
    let categoryIdentifier: String?

    /// 用於顯示的種類名稱，如 "食", "衣"
    var categoryDisplayTitle: String? {
        guard let id = categoryIdentifier else { return nil }
        switch id {
        case "food": return "食"
        case "clothing": return "衣"
        case "housing": return "住"
        case "transport": return "行"
        case "education": return "育"
        case "entertainment": return "樂"
        default: return nil
        }
    }
}
