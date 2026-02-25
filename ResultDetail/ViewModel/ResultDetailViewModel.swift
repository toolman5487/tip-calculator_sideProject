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

    var categorySystemImageName: String {
        guard item.categoryDisplayText != "—" else {
            return Category.none.systemImageName ?? "questionmark.circle"
        }
        return Category.allCases.first { $0.displayName == item.categoryDisplayText }?.systemImageName
            ?? Category.none.systemImageName ?? "questionmark.circle"
    }

    // MARK: - Actions

    func deleteRecord() {
        guard let id = item.id else { return }
        store.delete(id: id)
    }
}

