//
//  ConsumptionRecordStore.swift
//  tip-calculator
//
//  Created by Willy Hsu on 2026/2/5.
//

import Foundation
import CoreData

protocol ConsumptionRecordStoring {
    @MainActor
    @discardableResult
    func save(result: Result, latitude: Double?, longitude: Double?, address: String?) -> Bool

    @MainActor
    func fetchAll() -> [ConsumptionRecord]
}

struct ConsumptionRecordStore: ConsumptionRecordStoring {

    @MainActor
    @discardableResult
    func save(result: Result, latitude: Double? = nil, longitude: Double? = nil, address: String? = nil) -> Bool {
        let context = CoreDataStack.viewContext

        let record = ConsumptionRecord(context: context)
        record.id = UUID()
        record.createdAt = Date()
        record.bill = result.bill
        record.totalTip = result.totalTip
        record.totalBill = result.totalBill
        record.amountPerPerson = result.amountPerPerson
        record.split = Int16(result.split)
        record.tipRawValue = result.tip.stringValue
        record.latitude = latitude.map { NSNumber(value: $0) }
        record.longitude = longitude.map { NSNumber(value: $0) }
        record.address = address?.isEmpty == true ? nil : address

        return CoreDataStack.saveContext()
    }

    @MainActor
    func fetchAll() -> [ConsumptionRecord] {
        let request = ConsumptionRecord.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \ConsumptionRecord.createdAt, ascending: false)]
        do {
            return try CoreDataStack.viewContext.fetch(request)
        } catch {
            return []
        }
    }
}

