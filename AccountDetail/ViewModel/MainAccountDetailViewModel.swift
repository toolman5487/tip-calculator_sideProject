//
//  MainAccountDetailViewModel.swift
//  tip-calculator
//
//  Created by Willy Hsu on 2026/3/11.
//

import Combine
import Foundation

// MARK: - MainAccountDetailViewModel

@MainActor
final class MainAccountDetailViewModel {

    // MARK: - Dependencies

    private let store: ConsumptionRecordStoring

    // MARK: - Published State

    @Published private(set) var overviewItem: AccountDetailOverviewItem?
    @Published private(set) var sectionCount: Int = 3
    @Published private(set) var dataVersion: UInt = 0

    // MARK: - Init

    init(store: ConsumptionRecordStoring = ConsumptionRecordStore()) {
        self.store = store
    }

    // MARK: - Public

    func load() {
        let records = store.fetchAll()
        let snapshots = records.map { AccountDetailOverviewUseCase.RecordSnapshot(from: $0) }
        Task {
            let item = await Task.detached(priority: .userInitiated) {
                AccountDetailOverviewUseCase.buildOverview(from: snapshots)
            }.value
            overviewItem = item
            dataVersion += 1
        }
    }
}
