//
//  MainUserInfoViewModel.swift
//  tip-calculator
//

import Foundation
import Combine

@MainActor
final class MainUserInfoViewModel {

    // MARK: - Item ViewModel

    struct ItemViewModel {
        let title: String
        let dateText: String
        let perCapitaText: String
        let peopleText: String
    }

    // MARK: - Dependencies

    private let store: ConsumptionRecordStoring

    // MARK: - State

    @Published private(set) var recordCount: Int = 0
    @Published private(set) var selectedDateFilter: RecordFilterOption = .newest

    private var allRecords: [ConsumptionRecord] = []
    private var filteredRecords: [ConsumptionRecord] = []

    // MARK: - Init

    init(store: ConsumptionRecordStoring = ConsumptionRecordStore()) {
        self.store = store
    }

    // MARK: - Public

    func load() {
        allRecords = store.fetchAll()
        applyFilter()
    }

    func refresh() {
        load()
    }

    func changeFilter(_ option: RecordFilterOption) {
        guard option != selectedDateFilter else { return }
        selectedDateFilter = option
        applyFilter()
    }

    func numberOfItems() -> Int {
        recordCount
    }

    func viewModel(at index: Int) -> ItemViewModel {
        itemViewModel(from: filteredRecords[index])
    }

    func recordDisplayItem(at index: Int) -> RecordDisplayItem? {
        guard index >= 0, index < filteredRecords.count else { return nil }
        let record = filteredRecords[index]
        return RecordDisplayItem.from(record, dateFormatter: AppDateFormatters.detail)
    }

    func deleteRecord(at index: Int) {
        guard index >= 0, index < filteredRecords.count else { return }
        let record = filteredRecords[index]
        guard let id = record.id else { return }

        store.delete(id: id)
        load()
    }

    // MARK: - Private

    private func applyFilter() {
        let filtered = selectedDateFilter.apply(to: allRecords)
        filteredRecords = filtered
        recordCount = filtered.count
    }

    private func itemViewModel(from record: ConsumptionRecord) -> ItemViewModel {
        let date = record.createdAt ?? Date()
        let people = Int(record.split)
        let perCapita = record.amountPerPerson
        return ItemViewModel(
            title: String(format: "帳單 $%.0f", record.totalBill),
            dateText: AppDateFormatters.list.string(from: date),
            perCapitaText: String(format: "$%.0f", perCapita),
            peopleText: "\(people) 人"
        )
    }
}

