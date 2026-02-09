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

    private var allRecords: [ConsumptionRecord] = []

    @Published private(set) var perCapitaViewModels: [ItemViewModel] = []
    @Published private(set) var selectedDateFilter: RecordFilterOption = .newest

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
        perCapitaViewModels.count
    }

    func viewModel(at index: Int) -> ItemViewModel {
        perCapitaViewModels[index]
    }

    // MARK: - Private

    private func applyFilter() {
        let filtered = selectedDateFilter.apply(to: allRecords)
        perCapitaViewModels = filtered.map { record in
            let date = record.createdAt ?? Date()
            let people = Int(record.split)
            let perCapita = record.amountPerPerson

            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy/MM/dd HH:mm"
            formatter.locale = Locale(identifier: "zh_TW")

            return ItemViewModel(
                title: String(format: "帳單 $%.0f", record.totalBill),
                dateText: formatter.string(from: date),
                perCapitaText: String(format: "$%.0f", perCapita),
                peopleText: "\(people) 人"
            )
        }
    }
}

