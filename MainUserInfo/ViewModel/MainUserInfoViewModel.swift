//
//  MainUserInfoViewModel.swift
//  tip-calculator
//

import Foundation
import Combine

// MARK: - RecordFilterHeaderViewModel

struct RecordFilterHeaderViewModel {
    let selected: RecordFilterOption
    let options: [RecordFilterOption]
    let onSelect: (RecordFilterOption) -> Void

    init(selected: RecordFilterOption, onSelect: @escaping (RecordFilterOption) -> Void) {
        self.selected = selected
        self.options = RecordFilterOption.allCases
        self.onSelect = onSelect
    }
}

// MARK: - MainUserInfoViewModel

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
    private var groupedSections: [(key: Int, title: String, indices: [Int])] = []

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

    private var hasGroupedSections: Bool {
        !groupedSections.isEmpty
    }

    func numberOfSections() -> Int {
        hasGroupedSections ? 1 + groupedSections.count : 1
    }

    func numberOfItems(in section: Int) -> Int {
        if hasGroupedSections {
            guard section > 0 else { return 0 }
            let idx = section - 1
            return idx < groupedSections.count ? groupedSections[idx].indices.count : 0
        }
        return section == 0 ? filteredRecords.count : 0
    }

    func isFilterHeaderSection(_ section: Int) -> Bool {
        section == 0
    }

    func sectionTitle(for section: Int) -> String? {
        guard hasGroupedSections, section > 0 else { return nil }
        let idx = section - 1
        return idx < groupedSections.count ? groupedSections[idx].title : nil
    }

    func viewModel(section: Int, item: Int) -> ItemViewModel {
        itemViewModel(from: record(at: section, item: item))
    }

    func recordDisplayItem(section: Int, item: Int) -> RecordDisplayItem? {
        let record = record(at: section, item: item)
        return RecordDisplayItem.from(record, dateFormatter: AppDateFormatters.detail)
    }

    private func record(at section: Int, item: Int) -> ConsumptionRecord {
        if hasGroupedSections, section > 0 {
            let idx = groupedSections[section - 1].indices[item]
            return filteredRecords[idx]
        }
        return filteredRecords[item]
    }

    func deleteRecord(at index: Int) {
        guard let record = record(atFlatIndex: index) else { return }
        guard let id = record.id else { return }

        store.delete(id: id)
        load()
    }

    private func record(atFlatIndex flatIndex: Int) -> ConsumptionRecord? {
        if hasGroupedSections {
            var remaining = flatIndex
            for section in groupedSections {
                let count = section.indices.count
                if remaining < count {
                    return filteredRecords[section.indices[remaining]]
                }
                remaining -= count
            }
            return nil
        }
        return flatIndex >= 0 && flatIndex < filteredRecords.count ? filteredRecords[flatIndex] : nil
    }

    // MARK: - Private

    private func applyFilter() {
        let filtered = selectedDateFilter.apply(to: allRecords)
        filteredRecords = filtered
        let calendar = Calendar.current
        let now = Date()
        switch selectedDateFilter {
        case .week:
            let currentKey = calendar.component(.weekday, from: now)
            let titles = ["", "週日", "週一", "週二", "週三", "週四", "週五", "週六"]
            groupedSections = buildGroupedSections(
                from: filtered, range: 1...7, currentKey: currentKey, modulus: 7,
                keyExtractor: { calendar.component(.weekday, from: $0) },
                titleBuilder: { key, _ in titles[key] }
            )
        case .month:
            let currentKey = calendar.component(.day, from: now)
            groupedSections = buildGroupedSections(
                from: filtered, range: 1...31, currentKey: currentKey, modulus: 31,
                keyExtractor: { calendar.component(.day, from: $0) },
                titleBuilder: { key, firstDate in
                    let month = calendar.component(.month, from: firstDate)
                    return "\(month)月\(key)號"
                }
            )
        case .year:
            let currentKey = calendar.component(.month, from: now)
            groupedSections = buildGroupedSections(
                from: filtered, range: 1...12, currentKey: currentKey, modulus: 12,
                keyExtractor: { calendar.component(.month, from: $0) },
                titleBuilder: { key, _ in "\(key)月" }
            )
        default:
            groupedSections = []
        }
        recordCount = filtered.count
    }

    private func buildGroupedSections(
        from records: [ConsumptionRecord],
        range: ClosedRange<Int>,
        currentKey: Int,
        modulus: Int,
        keyExtractor: (Date) -> Int,
        titleBuilder: (Int, Date) -> String
    ) -> [(key: Int, title: String, indices: [Int])] {
        var grouped: [Int: [Int]] = [:]
        grouped.reserveCapacity(range.count)
        for (index, record) in records.enumerated() {
            guard let date = record.createdAt else { continue }
            let key = keyExtractor(date)
            grouped[key, default: []].append(index)
        }
        let sortedKeys = range.sorted { a, b in
            let distA = (currentKey - a + modulus) % modulus
            let distB = (currentKey - b + modulus) % modulus
            return distA < distB
        }
        return sortedKeys.compactMap { key in
            guard let indices = grouped[key], !indices.isEmpty,
                  let firstDate = records[indices[0]].createdAt else { return nil }
            return (key: key, title: titleBuilder(key, firstDate), indices: indices)
        }
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

