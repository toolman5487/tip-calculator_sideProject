//
//  AppDateFormatters.swift
//  tip-calculator
//

import Foundation

enum AppDateFormatters {

    static let list: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        formatter.locale = Locale.autoupdatingCurrent
        return formatter
    }()

    static let detail: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale.autoupdatingCurrent
        return formatter
    }()
}
