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
    let categoryIdentifier: String?

    var categoryDisplayTitle: String? {
        categoryIdentifier.flatMap { Category(identifier: $0)?.displayName }
    }

    var categorySystemImageName: String? {
        categoryIdentifier.flatMap { Category(identifier: $0)?.systemImageName }
    }
}
