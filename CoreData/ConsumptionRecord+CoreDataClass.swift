//
//  ConsumptionRecord+CoreDataClass.swift
//  tip-calculator
//
//  Created by Willy Hsu on 2026/2/5.
//
//

public import Foundation
public import CoreData
import CoreLocation

public typealias ConsumptionRecordCoreDataClassSet = NSSet

@objc(ConsumptionRecord)
public class ConsumptionRecord: NSManagedObject {

}

extension ConsumptionRecord {
    var effectiveConsumptionTime: Date? {
        consumptionTime ?? createdAt
    }

    var coordinate: CLLocationCoordinate2D? {
        guard let lat = latitude?.doubleValue, let lon = longitude?.doubleValue else { return nil }
        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }

    var districtKey: String {
        let raw = (locationName ?? address)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return raw.isEmpty ? "Unknown Area" : LocationAddressFormatter.district.format(raw)
    }
}
