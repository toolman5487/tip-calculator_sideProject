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
    func save(
        result: Result,
        latitude: Double?,
        longitude: Double?,
        address: String?,
        locationName: String?,
        categoryIdentifier: String?
    ) -> Bool

    @MainActor
    func fetchAll() -> [ConsumptionRecord]

    @MainActor
    func fetch(id: UUID) -> ConsumptionRecord?

    @MainActor
    @discardableResult
    func update(
        id: UUID,
        result: Result,
        latitude: Double?,
        longitude: Double?,
        address: String?,
        locationName: String?,
        categoryIdentifier: String?,
        consumptionTime: Date?
    ) -> Bool

    @MainActor
    func delete(id: UUID)

    @MainActor
    func deleteAll()

    @MainActor
    @discardableResult
    func updateConsumptionTime(id: UUID, consumptionTime: Date) -> Bool
}

struct ConsumptionRecordStore: ConsumptionRecordStoring {

    @MainActor
    @discardableResult
    func save(
        result: Result,
        latitude: Double? = nil,
        longitude: Double? = nil,
        address: String? = nil,
        locationName: String? = nil,
        categoryIdentifier: String? = nil
    ) -> Bool {
        let context = CoreDataStack.viewContext

        let record = ConsumptionRecord(context: context)
        record.id = UUID()
        record.createdAt = Date()
        record.consumptionTime = Date()
        record.bill = result.bill
        record.totalTip = result.totalTip
        record.totalBill = result.totalBill
        record.amountPerPerson = result.amountPerPerson
        record.split = Int16(result.split)
        record.tipRawValue = result.tip.stringValue
        record.categoryIdentifier = categoryIdentifier?.isEmpty == true ? nil : categoryIdentifier
        record.latitude = latitude.map { NSNumber(value: $0) }
        record.longitude = longitude.map { NSNumber(value: $0) }
        record.address = address?.isEmpty == true ? nil : address
        record.locationName = locationName?.isEmpty == true ? nil : locationName

        return CoreDataStack.saveContext()
    }

    @MainActor
    func fetchAll() -> [ConsumptionRecord] {
        let request = ConsumptionRecord.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \ConsumptionRecord.consumptionTime, ascending: false),
            NSSortDescriptor(keyPath: \ConsumptionRecord.createdAt, ascending: false)
        ]
        do {
            let records = try CoreDataStack.viewContext.fetch(request)
            let allHaveConsumptionTime = records.allSatisfy { $0.consumptionTime != nil }
            if allHaveConsumptionTime {
                return records
            }
            return records.sorted { ($0.effectiveConsumptionTime ?? .distantPast) > ($1.effectiveConsumptionTime ?? .distantPast) }
        } catch {
            return []
        }
    }

    @MainActor
    func fetch(id: UUID) -> ConsumptionRecord? {
        let request = ConsumptionRecord.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1
        do {
            return try CoreDataStack.viewContext.fetch(request).first
        } catch {
            return nil
        }
    }

    @MainActor
    @discardableResult
    func update(
        id: UUID,
        result: Result,
        latitude: Double? = nil,
        longitude: Double? = nil,
        address: String? = nil,
        locationName: String? = nil,
        categoryIdentifier: String? = nil,
        consumptionTime: Date? = nil
    ) -> Bool {
        guard let record = fetch(id: id) else { return false }
        record.bill = result.bill
        record.totalTip = result.totalTip
        record.totalBill = result.totalBill
        record.amountPerPerson = result.amountPerPerson
        record.split = Int16(result.split)
        record.tipRawValue = result.tip.stringValue
        record.categoryIdentifier = categoryIdentifier?.isEmpty == true ? nil : categoryIdentifier
        record.latitude = latitude.map { NSNumber(value: $0) }
        record.longitude = longitude.map { NSNumber(value: $0) }
        record.address = address?.isEmpty == true ? nil : address
        record.locationName = locationName?.isEmpty == true ? nil : locationName
        if let consumptionTime { record.consumptionTime = consumptionTime }
        return CoreDataStack.saveContext()
    }

    @MainActor
    @discardableResult
    func updateConsumptionTime(id: UUID, consumptionTime: Date) -> Bool {
        guard let record = fetch(id: id) else { return false }
        record.consumptionTime = consumptionTime
        return CoreDataStack.saveContext()
    }

    @MainActor
    func delete(id: UUID) {
        let context = CoreDataStack.viewContext
        let request = ConsumptionRecord.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1

        do {
            if let record = try context.fetch(request).first {
                context.delete(record)
                _ = CoreDataStack.saveContext()
            }
        } catch {
            print("Failed to delete ConsumptionRecord with id \(id): \(error)")
        }
    }

    @MainActor
    func deleteAll() {
        let context = CoreDataStack.viewContext
        let request = ConsumptionRecord.fetchRequest()
        do {
            let records = try context.fetch(request)
            records.forEach { context.delete($0) }
            _ = CoreDataStack.saveContext()
        } catch {
            print("Failed to delete all ConsumptionRecords: \(error)")
        }
    }
}

