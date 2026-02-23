//
//  ResultDetailViewModel.swift
//  tip-calculator
//
//  Created by Willy Hsu on 2026/2/10.
//

import Foundation

@MainActor
final class ResultDetailViewModel {

    // MARK: - Dependencies

    private let store: ConsumptionRecordStoring

    // MARK: - State

    let item: RecordDisplayItem

    // MARK: - Init

    init(item: RecordDisplayItem, store: ConsumptionRecordStoring = ConsumptionRecordStore()) {
        self.item = item
        self.store = store
    }

    // MARK: - Computed

    var shouldShowAddressSection: Bool {
        !(item.addressText.isEmpty && item.latitude == nil && item.longitude == nil)
    }

    var shouldShowCategorySection: Bool {
        item.categoryDisplayText != "—"
    }

    var categorySystemImageName: String? {
        switch item.categoryDisplayText {
        case "食": return "fork.knife"
        case "衣": return "tshirt.fill"
        case "住": return "house.fill"
        case "行": return "car.fill"
        case "育": return "book.fill"
        case "樂": return "gamecontroller.fill"
        default: return nil
        }
    }

    // MARK: - Actions

    func deleteRecord() {
        guard let id = item.id else { return }
        store.delete(id: id)
    }
}

