//
//  ResultDetailEditViewModel.swift
//  tip-calculator
//

import Foundation
import Combine

enum ResultDetailEditRow {
    case consumptionTimePicker(date: Date)
    case amount(value: Double)
    case tip(tip: Tip)
    case split(value: Int)
    case category(identifier: String?)
    case address(value: String)
}

extension Tip {
    static func from(rawValue: String?) -> Tip {
        guard let raw = rawValue, !raw.isEmpty else { return .none }
        switch raw {
        case "10%": return .tenPercent
        case "15%": return .fifteenPercent
        case "20%": return .twentyPercent
        default:
            if let v = Int(raw) { return .custom(value: v) }
            return .none
        }
    }
}

private func getTipAmount(bill: Double, tip: Tip) -> Double {
    switch tip {
    case .none: return 0
    case .tenPercent: return bill * 0.1
    case .fifteenPercent: return bill * 0.15
    case .twentyPercent: return bill * 0.2
    case .custom(let value): return Double(value)
    }
}

@MainActor
final class ResultDetailEditViewModel {

    private let store: ConsumptionRecordStoring
    let recordId: UUID

    @Published private(set) var rows: [ResultDetailEditRow] = []

    var selectedConsumptionTime: Date
    var bill: Double
    var tip: Tip
    var split: Int
    var categoryIdentifier: String?
    var address: String
    var latitude: Double?
    var longitude: Double?

    private var record: ConsumptionRecord?

    init(recordId: UUID, store: ConsumptionRecordStoring = ConsumptionRecordStore()) {
        self.recordId = recordId
        self.store = store
        self.selectedConsumptionTime = Date()
        self.bill = 0
        self.tip = .none
        self.split = 1
        self.categoryIdentifier = nil
        self.address = ""
        self.latitude = nil
        self.longitude = nil
        load()
    }

    func load() {
        guard let record = store.fetch(id: recordId) else {
            buildRows()
            return
        }
        self.record = record
        selectedConsumptionTime = record.effectiveConsumptionTime ?? Date()
        bill = record.bill
        tip = Tip.from(rawValue: record.tipRawValue)
        split = Int(record.split)
        categoryIdentifier = record.categoryIdentifier
        address = record.address ?? ""
        latitude = record.latitude?.doubleValue
        longitude = record.longitude?.doubleValue
        buildRows()
    }

    func updateConsumptionTime(_ date: Date) {
        selectedConsumptionTime = date
        buildRows()
    }

    func updateBill(_ value: Double) {
        bill = max(0, value)
        buildRows()
    }

    func updateTip(_ newTip: Tip) {
        tip = newTip
        buildRows()
    }

    func updateSplit(_ value: Int) {
        split = max(1, min(99, value))
        buildRows()
    }

    func updateCategory(_ identifier: String?) {
        categoryIdentifier = identifier
        buildRows()
    }

    func updateAddress(_ value: String) {
        address = value
        buildRows()
    }

    func updateLocation(address: String, latitude: Double, longitude: Double) {
        self.address = address
        self.latitude = latitude
        self.longitude = longitude
        buildRows()
    }

    func save() -> Bool {
        let totalTip = getTipAmount(bill: bill, tip: tip)
        let totalBill = bill + totalTip
        let amountPerPerson = totalBill / Double(split)
        let result = Result(
            amountPerPerson: amountPerPerson,
            totalBill: totalBill,
            totalTip: totalTip,
            bill: bill,
            tip: tip,
            split: split,
            categoryIdentifier: categoryIdentifier?.isEmpty == true ? nil : categoryIdentifier
        )
        let lat = latitude ?? record?.latitude?.doubleValue
        let lon = longitude ?? record?.longitude?.doubleValue
        return store.update(
            id: recordId,
            result: result,
            latitude: lat,
            longitude: lon,
            address: address.isEmpty ? nil : address,
            locationName: address.isEmpty ? record?.locationName : address,
            categoryIdentifier: categoryIdentifier,
            consumptionTime: selectedConsumptionTime
        )
    }

    private func buildRows() {
        rows = [
            .consumptionTimePicker(date: selectedConsumptionTime),
            .amount(value: bill),
            .tip(tip: tip),
            .split(value: split),
            .category(identifier: categoryIdentifier),
            .address(value: address)
        ]
    }
}
