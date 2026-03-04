//
//  LocationRecordsSheetViewModel.swift
//  tip-calculator
//
//  Created by Willy Hsu on 2026/3/3.
//

import Foundation

@MainActor
final class LocationRecordsSheetViewModel {

    let locationTitle: String
    let items: [RecordDisplayItem]

    init(locationTitle: String, items: [RecordDisplayItem]) {
        self.locationTitle = locationTitle
        self.items = items
    }

    func item(at index: Int) -> RecordDisplayItem? {
        guard index >= 0, index < items.count else { return nil }
        return items[index]
    }
}
