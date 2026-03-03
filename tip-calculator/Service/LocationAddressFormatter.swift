//
//  LocationAddressFormatter.swift
//  tip-calculator
//

import CoreLocation
import Foundation

enum LocationAddressFormatter {

    static func format(_ place: CLPlacemark) -> String? {
        guard let countryCode = place.isoCountryCode else { return nil }
        let formatter: (CLPlacemark) -> String?
        switch countryCode {
        case "TW":
            formatter = formatTaiwan
        case "JP":
            formatter = formatJapan
        case "CN", "HK", "MO":
            formatter = formatGreaterChina
        default:
            formatter = formatGeneric
        }
        return formatter(place)
    }

    private static func formatTaiwan(_ place: CLPlacemark) -> String? {
        let adminArea = place.administrativeArea ?? ""
        let locality = place.locality ?? ""
        let subLocality = place.subLocality ?? ""
        let street = place.thoroughfare ?? ""

        let (tier1, tier2) = parseTaiwanTiers(adminArea: adminArea, locality: locality, subLocality: subLocality)
        let base = [tier1, tier2].filter { !$0.isEmpty }
        guard !base.isEmpty else { return nil }
        var parts = base
        if !street.isEmpty { parts.append(street) }
        return parts.joined(separator: " ")
    }

    private static func parseTaiwanTiers(adminArea: String, locality: String, subLocality: String) -> (String, String) {
        let isTier1: (String) -> Bool = { $0.hasSuffix("縣") || $0.hasSuffix("市") }
        switch (isTier1(adminArea), isTier1(locality)) {
        case (true, _): return (adminArea, locality)
        case (_, true): return (locality, subLocality)
        default:
            let t1 = adminArea.isEmpty ? locality : adminArea
            let t2 = (t1 == adminArea && locality != adminArea) ? locality : (t1 == locality ? subLocality : "")
            return (t1, t2)
        }
    }

    private static func formatJapan(_ place: CLPlacemark) -> String? {
        let adminArea = place.administrativeArea ?? ""
        let locality = place.locality ?? ""
        let subLocality = place.subLocality ?? ""
        let street = place.thoroughfare ?? ""
        let parts = [adminArea, locality, subLocality, street].filter { !$0.isEmpty }
        return parts.isEmpty ? nil : parts.joined()
    }

    private static func formatGreaterChina(_ place: CLPlacemark) -> String? {
        let adminArea = place.administrativeArea ?? ""
        let locality = place.locality ?? ""
        let subLocality = place.subLocality ?? ""
        let street = place.thoroughfare ?? ""
        let parts = [adminArea, locality, subLocality, street].filter { !$0.isEmpty }
        return parts.isEmpty ? nil : parts.joined(separator: " ")
    }

    private static func formatGeneric(_ place: CLPlacemark) -> String? {
        let locality = place.locality ?? ""
        let adminArea = place.administrativeArea ?? ""
        let subLocality = place.subLocality ?? ""
        let thoroughfare = place.thoroughfare ?? ""
        let parts = [locality, adminArea, subLocality, thoroughfare].filter { !$0.isEmpty }
        return parts.isEmpty ? nil : parts.joined(separator: ", ")
    }
}
