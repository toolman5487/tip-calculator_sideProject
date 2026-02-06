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
    func save(result: Result, latitude: Double?, longitude: Double?) -> Bool

    @MainActor
    func fetchAll() -> [ConsumptionRecord]
}

struct ConsumptionRecordStore: ConsumptionRecordStoring {

    @MainActor
    @discardableResult
    func save(result: Result, latitude: Double? = nil, longitude: Double? = nil) -> Bool {
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

        let success = CoreDataStack.saveContext()
        if success {
            print("[CoreData] 儲存一筆消費紀錄:", [
                "id: \(record.id?.uuidString ?? "")",
                "createdAt: \(record.createdAt?.description ?? "")",
                "bill: \(record.bill)",
                "totalTip: \(record.totalTip)",
                "totalBill: \(record.totalBill)",
                "amountPerPerson: \(record.amountPerPerson)",
                "split: \(record.split)",
                "tipRawValue: \(record.tipRawValue ?? "")",
                "latitude: \(record.latitude?.doubleValue ?? 0)",
                "longitude: \(record.longitude?.doubleValue ?? 0)"
            ].joined(separator: ", "))
        }
        return success
    }

    @MainActor
    func fetchAll() -> [ConsumptionRecord] {
        let request = ConsumptionRecord.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \ConsumptionRecord.createdAt, ascending: false)]
        do {
            return try CoreDataStack.viewContext.fetch(request)
        } catch {
            print("Core Data fetch error: \(error)")
            return []
        }
    }
}

