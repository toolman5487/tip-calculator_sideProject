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
    private var filteredRecords: [ConsumptionRecord] = []

    private let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .short
        f.locale = Locale(identifier: "zh_TW")
        return f
    }()

    private let listDateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy/MM/dd HH:mm"
        f.locale = Locale(identifier: "zh_TW")
        return f
    }()

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

    func recordDisplayItem(at index: Int) -> RecordDisplayItem? {
        guard index >= 0, index < filteredRecords.count else { return nil }
        let record = filteredRecords[index]
        let dateText = record.createdAt.map { dateFormatter.string(from: $0) } ?? ""
        let tipDisplay = (record.tipRawValue?.isEmpty == false) ? (record.tipRawValue ?? "無") : "無"
        return RecordDisplayItem(
            dateText: dateText,
            billText: record.bill.currencyFormatted,
            billValue: record.bill,
            totalTipText: record.totalTip.currencyFormatted,
            totalBillText: record.totalBill.currencyFormatted,
            totalBillValue: record.totalBill,
            amountPerPersonText: record.amountPerPerson.currencyFormatted,
            amountPerPersonValue: record.amountPerPerson,
            splitText: "\(record.split) 人",
            tipDisplayText: tipDisplay,
            addressText: record.address ?? "",
            latitude: record.latitude?.doubleValue,
            longitude: record.longitude?.doubleValue
        )
    }

    // MARK: - Private

    private func applyFilter() {
        let filtered = selectedDateFilter.apply(to: allRecords)
        filteredRecords = filtered
        perCapitaViewModels = filtered.map { record in
            let date = record.createdAt ?? Date()
            let people = Int(record.split)
            let perCapita = record.amountPerPerson
            return ItemViewModel(
                title: String(format: "帳單 $%.0f", record.totalBill),
                dateText: listDateFormatter.string(from: date),
                perCapitaText: String(format: "$%.0f", perCapita),
                peopleText: "\(people) 人"
            )
        }
    }
}

