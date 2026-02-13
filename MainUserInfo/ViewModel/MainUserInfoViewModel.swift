//
//  MainUserInfoViewModel.swift
//  tip-calculator
//

import Foundation
import Combine

// MARK: - DeleteAllAlertContent

struct DeleteAllAlertContent {
    let title: String
    let message: String
    let cancelTitle: String
    let confirmTitle: String

    init(
        title: String = "刪除所有紀錄",
        message: String = "確定要刪除所有消費紀錄嗎？此操作無法復原。",
        cancelTitle: String = "取消",
        confirmTitle: String = "刪除"
    ) {
        self.title = title
        self.message = message
        self.cancelTitle = cancelTitle
        self.confirmTitle = confirmTitle
    }
}

// MARK: - RecordListSectionViewModel

struct RecordListSectionViewModel {
    enum Kind {
        case filterHeader(RecordFilterHeaderViewModel)
        case recordGroup(title: String, items: [RecordListCellViewModel])
    }
    let kind: Kind
}

struct RecordListCellViewModel {
    let cell: MainUserInfoViewModel.ItemViewModel
    let detail: RecordDisplayItem
}

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

// MARK: - RecordSnapshot (thread-safe for background processing)

struct RecordSnapshot {
    let id: UUID?
    let createdAt: Date?
    let bill: Double
    let totalTip: Double
    let totalBill: Double
    let amountPerPerson: Double
    let split: Int
    let tipRawValue: String?
    let address: String?
    let locationName: String?
    let latitude: Double?
    let longitude: Double?

    init(_ record: ConsumptionRecord) {
        id = record.id
        createdAt = record.createdAt
        bill = record.bill
        totalTip = record.totalTip
        totalBill = record.totalBill
        amountPerPerson = record.amountPerPerson
        split = Int(record.split)
        tipRawValue = record.tipRawValue
        address = record.address
        locationName = record.locationName
        latitude = record.latitude?.doubleValue
        longitude = record.longitude?.doubleValue
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
    @Published private(set) var displaySections: [RecordListSectionViewModel] = []

    var deleteAllAlertContent: DeleteAllAlertContent { DeleteAllAlertContent() }

    private var allRecords: [ConsumptionRecord] = []
    private var cachedSnapshots: [RecordSnapshot] = []
    private var filteredRecords: [ConsumptionRecord] = []
    private var groupedSections: [(key: Int, title: String, indices: [Int])] = []

    // MARK: - Init

    init(store: ConsumptionRecordStoring = ConsumptionRecordStore()) {
        self.store = store
    }

    // MARK: - Public

    func load() {
        allRecords = store.fetchAll()
        cachedSnapshots = allRecords.map { RecordSnapshot($0) }
        applyFilterAsync()
    }

    func changeFilter(_ option: RecordFilterOption) {
        guard option != selectedDateFilter else { return }
        selectedDateFilter = option
        applyFilterAsync()
    }

    private func applyFilterAsync() {
        let snapshots = cachedSnapshots
        let filter = selectedDateFilter
        let onChangeFilter: (RecordFilterOption) -> Void = { [weak self] option in
            Task { @MainActor in self?.changeFilter(option) }
        }

        Task { @MainActor in
            let result = await Task.detached(priority: .userInitiated) {
                Self.computeDisplayData(snapshots: snapshots, filter: filter, onChangeFilter: onChangeFilter)
            }.value
            self.applyResult(result)
        }
    }

    private func applyResult(_ result: (filtered: [RecordSnapshot], grouped: [(key: Int, title: String, indices: [Int])], count: Int, sections: [RecordListSectionViewModel])) {
        let ids = result.filtered.map { $0.id }
        filteredRecords = ids.compactMap { id in allRecords.first { $0.id == id } }
        groupedSections = result.grouped
        recordCount = result.count
        displaySections = result.sections
    }

    func refresh() {
        load()
    }

    private var hasGroupedSections: Bool {
        !groupedSections.isEmpty
    }

    func deleteRecord(at index: Int) {
        guard let record = record(atFlatIndex: index) else { return }
        guard let id = record.id else { return }

        store.delete(id: id)
        load()
    }

    func deleteAllRecords() {
        store.deleteAll()
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

    // MARK: - Private (static, runs on background)

    private nonisolated static func computeDisplayData(
        snapshots: [RecordSnapshot],
        filter: RecordFilterOption,
        onChangeFilter: @escaping (RecordFilterOption) -> Void
    ) -> (filtered: [RecordSnapshot], grouped: [(key: Int, title: String, indices: [Int])], count: Int, sections: [RecordListSectionViewModel]) {
        let filtered = filter.apply(to: snapshots)
        let calendar = Calendar.current
        let now = Date()
        let grouped: [(key: Int, title: String, indices: [Int])]
        switch filter {
        case .week:
            let currentKey = calendar.component(.weekday, from: now)
            let titles = ["", "週日", "週一", "週二", "週三", "週四", "週五", "週六"]
            grouped = buildGroupedSections(
                from: filtered, range: 1...7, currentKey: currentKey, modulus: 7,
                keyExtractor: { calendar.component(.weekday, from: $0) },
                titleBuilder: { key, _ in titles[key] }
            )
        case .month:
            let currentKey = calendar.component(.day, from: now)
            grouped = buildGroupedSections(
                from: filtered, range: 1...31, currentKey: currentKey, modulus: 31,
                keyExtractor: { calendar.component(.day, from: $0) },
                titleBuilder: { key, firstDate in
                    let month = calendar.component(.month, from: firstDate)
                    return "\(month)月\(key)號"
                }
            )
        case .year:
            let currentKey = calendar.component(.month, from: now)
            grouped = buildGroupedSections(
                from: filtered, range: 1...12, currentKey: currentKey, modulus: 12,
                keyExtractor: { calendar.component(.month, from: $0) },
                titleBuilder: { key, _ in "\(key)月" }
            )
        default:
            grouped = []
        }
        let sections = buildDisplaySections(filter: filter, filtered: filtered, grouped: grouped, onChangeFilter: onChangeFilter)
        return (filtered, grouped, filtered.count, sections)
    }

    private nonisolated static func buildDisplaySections(
        filter: RecordFilterOption,
        filtered: [RecordSnapshot],
        grouped: [(key: Int, title: String, indices: [Int])],
        onChangeFilter: @escaping (RecordFilterOption) -> Void
    ) -> [RecordListSectionViewModel] {
        var sections: [RecordListSectionViewModel] = []
        let filterVM = RecordFilterHeaderViewModel(selected: filter, onSelect: onChangeFilter)
        sections.append(RecordListSectionViewModel(kind: .filterHeader(filterVM)))
        if !grouped.isEmpty {
            for group in grouped {
                let items = group.indices.map { recordListCellViewModel(from: filtered[$0]) }
                sections.append(RecordListSectionViewModel(kind: .recordGroup(title: group.title, items: items)))
            }
        } else if !filtered.isEmpty {
            let items = filtered.map { recordListCellViewModel(from: $0) }
            sections.append(RecordListSectionViewModel(kind: .recordGroup(title: "", items: items)))
        }
        return sections
    }

    private nonisolated static func recordListCellViewModel(from snapshot: RecordSnapshot) -> RecordListCellViewModel {
        let date = snapshot.createdAt ?? Date()
        let listDateText = AppDateFormatters.list.string(from: date)
        let detailDateText = AppDateFormatters.detail.string(from: date)
        return RecordListCellViewModel(
            cell: ItemViewModel(
                title: String(format: "帳單 $%.0f", snapshot.totalBill),
                dateText: listDateText,
                perCapitaText: String(format: "$%.0f", snapshot.amountPerPerson),
                peopleText: "\(snapshot.split) 人"
            ),
            detail: RecordDisplayItem.from(snapshot, dateText: detailDateText)
        )
    }

    private nonisolated static func buildGroupedSections(
        from records: [RecordSnapshot],
        range: ClosedRange<Int>,
        currentKey: Int,
        modulus: Int,
        keyExtractor: (Date) -> Int,
        titleBuilder: (Int, Date) -> String
    ) -> [(key: Int, title: String, indices: [Int])] {
        var grouped: [Int: [Int]] = [:]
        grouped.reserveCapacity(range.count)
        for (index, snapshot) in records.enumerated() {
            guard let date = snapshot.createdAt else { continue }
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
}

