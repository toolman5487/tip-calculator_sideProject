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
    func save(result: Result) -> Bool

    @MainActor
    func fetchAll() -> [ConsumptionRecord]
}

struct ConsumptionRecordStore: ConsumptionRecordStoring {

    @MainActor
    @discardableResult
    func save(result: Result) -> Bool {
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

        return CoreDataStack.saveContext()
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

