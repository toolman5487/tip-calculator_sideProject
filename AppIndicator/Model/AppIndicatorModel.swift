//
//  AppIndicatorModel.swift
//  tip-calculator
//
//  Created by Willy Hsu on 2026/3/17.
//

import Foundation

enum AppIndicatorRow {
    case item(title: String, body: String)
}

struct AppIndicatorSection {
    let pillTitle: String
    let rows: [AppIndicatorRow]
}
