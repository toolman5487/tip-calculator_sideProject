//
//  ReverseGeocodeService.swift
//  tip-calculator
//
//  Created by Willy Hsu on 2026/3/5.
//

import CoreLocation

protocol ReverseGeocoding {
    func reverseGeocode(latitude: Double, longitude: Double, completion: @escaping (String?) -> Void)
}

struct ReverseGeocodeService: ReverseGeocoding {

    func reverseGeocode(latitude: Double, longitude: Double, completion: @escaping (String?) -> Void) {
        let location = CLLocation(latitude: latitude, longitude: longitude)
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location, preferredLocale: Locale.current) { placemarks, _ in
            guard let place = placemarks?.first else {
                DispatchQueue.main.async { completion(nil) }
                return
            }
            let native = Self.nativeLocale(for: place.isoCountryCode)
            let currentLang = String(Locale.current.identifier.prefix(2))
            let nativeLang = String(native.identifier.prefix(2))
            if currentLang != nativeLang {
                geocoder.reverseGeocodeLocation(location, preferredLocale: native) { placemarks2, _ in
                    let finalPlace = placemarks2?.first ?? place
                    let text = LocationAddressFormatter.full.format(finalPlace) ?? Self.simpleFormat(finalPlace)
                    DispatchQueue.main.async { completion(text.isEmpty ? nil : text) }
                }
                return
            }
            let text = LocationAddressFormatter.full.format(place) ?? Self.simpleFormat(place)
            DispatchQueue.main.async { completion(text.isEmpty ? nil : text) }
        }
    }

    private static func nativeLocale(for isoCountryCode: String?) -> Locale {
        switch isoCountryCode {
        case "TW", "HK", "MO": return Locale(identifier: "zh_TW")
        case "CN": return Locale(identifier: "zh_CN")
        case "JP": return Locale(identifier: "ja_JP")
        case "KR": return Locale(identifier: "ko_KR")
        default: return Locale.current
        }
    }

    private static func simpleFormat(_ place: CLPlacemark) -> String {
        let parts = [place.locality, place.subLocality, place.thoroughfare].compactMap { $0 }
        return parts.joined(separator: " ")
    }
}
