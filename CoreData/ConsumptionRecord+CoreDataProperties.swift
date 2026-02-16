//
//  ConsumptionRecord+CoreDataProperties.swift
//  tip-calculator
//
//  Created by Willy Hsu on 2026/2/5.
//
//

public import Foundation
public import CoreData


public typealias ConsumptionRecordCoreDataPropertiesSet = NSSet

extension ConsumptionRecord {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ConsumptionRecord> {
        return NSFetchRequest<ConsumptionRecord>(entityName: "ConsumptionRecord")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var createdAt: Date?
    @NSManaged public var address: String?
    @NSManaged public var locationName: String?
    @NSManaged public var latitude: NSNumber?
    @NSManaged public var longitude: NSNumber?
    @NSManaged public var bill: Double
    @NSManaged public var categoryIdentifier: String?
    @NSManaged public var totalTip: Double
    @NSManaged public var totalBill: Double
    @NSManaged public var amountPerPerson: Double
    @NSManaged public var split: Int16
    @NSManaged public var tipRawValue: String?

}

extension ConsumptionRecord : Identifiable {}
