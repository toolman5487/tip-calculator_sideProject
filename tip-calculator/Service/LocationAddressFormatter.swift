//
//  LocationAddressFormatter.swift
//  tip-calculator
//

import CoreLocation
import Foundation

enum LocationAddressFormatter {

    case full
    case district

    func format(_ place: CLPlacemark) -> String? {
        let raw = LocationAddressFormatter.formatFull(place)
        guard let raw else { return nil }
        return applyStyle(to: raw)
    }

    func format(_ address: String) -> String {
        let trimmed = address.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return trimmed }
        return applyStyle(to: trimmed)
    }

    private func applyStyle(to address: String) -> String {
        switch self {
        case .full: return address
        case .district: return Self.truncateToDistrict(address)
        }
    }

    private static func formatFull(_ place: CLPlacemark) -> String? {
        guard let countryCode = place.isoCountryCode else { return nil }
        switch countryCode {
        case "TW": return formatTaiwan(place)
        case "JP": return formatJapan(place)
        case "CN", "HK", "MO": return formatGreaterChina(place)
        default: return formatGeneric(place)
        }
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

    private static func truncateToDistrict(_ address: String) -> String {
        let trimmed = address.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return trimmed }
        if let cjk = truncateCJK(toDistrict: trimmed) { return cjk }
        if let western = truncateWestern(toDistrict: trimmed) { return western }
        return trimmed
    }

    private static func truncateCJK(toDistrict address: String) -> String? {
        let suffixes = ["區", "区", "鄉", "鎮", "町", "村"]
        var endIndex: String.Index?
        for suffix in suffixes {
            guard let range = address.range(of: suffix, options: .backwards) else { continue }
            let end = address.index(after: range.lowerBound)
            if let current = endIndex, end <= current { continue }
            endIndex = end
        }
        if let end = endIndex {
            return String(address[..<end]).trimmingCharacters(in: .whitespaces)
        }
        let parts = address.split(separator: " ", omittingEmptySubsequences: true).map(String.init)
        if parts.count >= 2, parts[1].hasSuffix("市") {
            return parts.prefix(2).joined(separator: " ")
        }
        return nil
    }

    private static func truncateWestern(toDistrict address: String) -> String? {
        guard address.contains(",") else { return nil }
        let parts = address.split(separator: ",", maxSplits: 2, omittingEmptySubsequences: true)
            .map { $0.trimmingCharacters(in: .whitespaces) }
        guard parts.count >= 2 else { return nil }
        return parts.prefix(2).joined(separator: ", ")
    }
}
