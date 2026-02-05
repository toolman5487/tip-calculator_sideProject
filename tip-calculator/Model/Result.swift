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
}
