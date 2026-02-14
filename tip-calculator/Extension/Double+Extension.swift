//
//  Double+Extension.swift
//  tip-calculator
//
//  Created by Willy Hsu on 2025/3/30.
//

import Foundation

extension Double {
    var currencyFormatted: String {
        var isWholeNumber: Bool {
            isZero ? true : !isNormal ? false : self == self.rounded()
        }
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = isWholeNumber ? 0 : 2
        return formatter.string(for: self) ?? ""
    }
    
    var currencyAbbreviatedFormatted: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        let symbol = formatter.currencySymbol ?? "$"
        return symbol + abbreviatedFormatted
    }

    var abbreviatedFormatted: String {
        let absValue = abs(self)
        let sign = self < 0 ? "-" : ""
        if absValue >= 1_000_000_000_000 {
            return sign + Self.abbrevValue(absValue / 1_000_000_000_000) + "T"
        }
        if absValue >= 1_000_000_000 {
            return sign + Self.abbrevValue(absValue / 1_000_000_000) + "B"
        }
        if absValue >= 1_000_000 {
            return sign + Self.abbrevValue(absValue / 1_000_000) + "M"
        }
        if absValue >= 1_000 {
            return sign + Self.abbrevValue(absValue / 1_000) + "K"
        }
        var isWholeNumber: Bool {
            isZero ? true : !isNormal ? false : self == self.rounded()
        }
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = isWholeNumber ? 0 : 2
        formatter.minimumFractionDigits = 0
        return formatter.string(for: self) ?? "\(self)"
    }

    private static func abbrevValue(_ value: Double) -> String {
        let absVal = abs(value)
        if absVal >= 10 || absVal == absVal.rounded() {
            return String(format: "%.0f", value)
        }
        let one = String(format: "%.1f", value)
        return one.hasSuffix(".0") ? String(one.dropLast(2)) : one
    }
}
