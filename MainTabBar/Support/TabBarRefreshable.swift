//
//  TabBarRefreshable.swift
//  tip-calculator
//

import Foundation

@MainActor
protocol TabBarRefreshable: AnyObject {
    func refreshContent()
}
