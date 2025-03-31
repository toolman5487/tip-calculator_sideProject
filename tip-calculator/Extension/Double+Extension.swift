//
//  Double+Extension.swift
//  tip-calculator
//
//  Created by Willy Hsu on 2025/3/30.
//

import Foundation

extension Double{
    var currencyFormatted: String {
        var isWholeNumber: Bool {
            isZero ? true: !isNormal ? false: self == self.rounded()
        }
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = isWholeNumber ? 0 : 2
        return formatter.string(for: self) ?? ""
    }
}
