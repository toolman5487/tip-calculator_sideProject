//
//  TotalResultViewModel.swift
//  tip-calculator
//
//  Created by Willy Hsu on 2026/2/5.
//

import Foundation
@preconcurrency import CoreLocation
import Combine

@MainActor
enum TotalResultRow: Int, CaseIterable {
    case amountPerPerson
    case totalBill
    case totalTip
    case bill
    case tip
    case split
    case category
    case location
    case save

    var title: String {
        switch self {
        case .amountPerPerson: return "每人應付金額"
        case .totalBill:       return "含小費總金額"
        case .totalTip:        return "小費總額"
        case .bill:            return "帳單金額"
        case .tip:             return "小費設定"
        case .split:           return "分攤人數"
        case .category:        return "消費種類"
        case .location:        return "消費地點"
        case .save:            return "儲存紀錄"
        }
    }

    func value(from result: Result) -> String {
        switch self {
        case .amountPerPerson:
            return result.amountPerPerson.currencyFormatted
        case .totalBill:
            return result.totalBill.currencyFormatted
        case .totalTip:
            return result.totalTip.currencyFormatted
        case .bill:
            return result.bill.currencyFormatted
        case .tip:
            return result.tip.stringValue.isEmpty ? "無" : result.tip.stringValue
        case .split:
            return "\(result.split)"
        case .category:
            return result.categoryDisplayTitle ?? "—"
        case .location:
            return ""
        case .save:
            return ""
        }
    }
}

@MainActor
final class TotalResultViewModel {

    let result: Result
    let rows: [TotalResultRow] = TotalResultRow.allCases
    private let store: ConsumptionRecordStoring
    private let locationProvider: LocationProviding
    private let googleGeocodingService: GoogleGeocodingService?

    @Published private(set) var locationDisplayText: String = ""
    @Published private(set) var isLocationLoading = true
    @Published private(set) var locationNameForRecord: String?

    init(
        result: Result,
        store: ConsumptionRecordStoring = ConsumptionRecordStore(),
        locationProvider: LocationProviding = LocationService.shared,
        googleGeocodingService: GoogleGeocodingService? = nil
    ) {
        self.result = result
        self.store = store
        self.locationProvider = locationProvider
        self.googleGeocodingService = googleGeocodingService
    }

    func refreshLocation() {
        isLocationLoading = true
        guard let location = locationProvider.lastLocation else {
            locationDisplayText = locationErrorMessage
            isLocationLoading = false
            locationNameForRecord = nil
            return
        }
        resolveCityDistrict(location: location)
    }

    private var locationErrorMessage: String {
        switch locationProvider.authorizationStatus {
        case .denied, .restricted:
            return "請開啟定位權限"
        default:
            return "無法定位"
        }
    }

    private func locationString(from place: CLPlacemark) -> String? {
        LocationAddressFormatter.full.format(place)
    }

    private static func nativeLocale(for isoCountryCode: String?) -> Locale {
        switch isoCountryCode {
        case "TW", "HK", "MO": return Locale(identifier: "zh_TW")
        case "CN":              return Locale(identifier: "zh_CN")
        case "JP":              return Locale(identifier: "ja_JP")
        case "KR":              return Locale(identifier: "ko_KR")
        default:                return Locale.current
        }
    }

    private func resolveCityDistrict(location: CLLocation) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location, preferredLocale: Locale.current) { [weak self] placemarks, _ in
            Task { @MainActor in
                guard let self else { return }
                guard let place = placemarks?.first else {
                    await self.applyGoogleFallback(location: location)
                    return
                }

                let native = Self.nativeLocale(for: place.isoCountryCode)
                let currentLang = String(Locale.current.identifier.prefix(2))
                let nativeLang  = String(native.identifier.prefix(2))

                if currentLang == nativeLang {
                    if let text = self.locationString(from: place) {
                        self.isLocationLoading = false
                        self.locationDisplayText = text
                        self.locationNameForRecord = text
                    } else {
                        await self.applyGoogleFallback(location: location, locale: native)
                    }
                    return
                }

                geocoder.reverseGeocodeLocation(location, preferredLocale: native) { [weak self] placemarks2, _ in
                    Task { @MainActor in
                        guard let self else { return }
                        let finalPlace = placemarks2?.first ?? place
                        if let text = self.locationString(from: finalPlace) {
                            self.isLocationLoading = false
                            self.locationDisplayText = text
                            self.locationNameForRecord = text
                        } else {
                            await self.applyGoogleFallback(location: location, locale: native)
                        }
                    }
                }
            }
        }
    }

    private func applyGoogleFallback(location: CLLocation, locale: Locale = Locale.current) async {
        let lang = locale.identifier.replacingOccurrences(of: "_", with: "-")
        if let google = googleGeocodingService,
           let addr = await google.reverseGeocode(
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude,
            language: lang
           ), !addr.isEmpty {
            isLocationLoading = false
            locationDisplayText = addr
            locationNameForRecord = addr
            return
        }
        isLocationLoading = false
        locationDisplayText = "無法取得地區"
        locationNameForRecord = nil
    }

    @discardableResult
    func saveRecord(latitude: Double? = nil, longitude: Double? = nil, address: String? = nil, locationName: String? = nil) -> Bool {
        let success = store.save(
            result: result,
            latitude: latitude,
            longitude: longitude,
            address: address,
            locationName: locationName,
            categoryIdentifier: result.categoryIdentifier
        )
        if success {
            TabBarBadgePublisher.increment(on: .userInfo)
        }
        return success
    }
}

