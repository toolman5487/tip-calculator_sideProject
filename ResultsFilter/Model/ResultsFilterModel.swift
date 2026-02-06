//
//  ResultsFilterModel.swift
//  tip-calculator
//
//  Created by Willy Hsu on 2026/2/6.
//

import Foundation

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
    let latitude: Double?
    let longitude: Double?
}
