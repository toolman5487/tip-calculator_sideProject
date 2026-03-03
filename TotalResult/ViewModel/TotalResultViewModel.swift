//
//  TotalResultViewModel.swift
//  tip-calculator
//
//  Created by Willy Hsu on 2026/2/5.
//

import Foundation
import CoreLocation
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
            locationDisplayText = "無法定位"
            isLocationLoading = false
            locationNameForRecord = nil
            return
        }
        resolveCityDistrict(location: location)
    }

    private func locationString(from place: CLPlacemark) -> String? {
        let locality = place.locality ?? ""
        let adminArea = place.administrativeArea ?? ""
        let subLoc = place.subLocality ?? ""
        let street = place.thoroughfare ?? ""

        let city: String
        let district: String
        if adminArea.hasSuffix("市") && locality.hasSuffix("區") {
            city = adminArea
            district = locality
        } else if locality.hasSuffix("市") {
            city = locality
            district = subLoc
        } else {
            city = locality.isEmpty ? adminArea : locality
            district = subLoc
        }

        let base = [city, district].filter { !$0.isEmpty }
        guard !base.isEmpty else { return nil }
        var parts = base
        if !street.isEmpty { parts.append(street) }
        return parts.joined(separator: " ")
    }

    private func resolveCityDistrict(location: CLLocation) {
        let geocoder = CLGeocoder()
        let locale = Locale(identifier: "zh_TW")
        geocoder.reverseGeocodeLocation(location, preferredLocale: locale) { [weak self] placemarks, _ in
            Task { @MainActor in
                guard let self else { return }
                if let place = placemarks?.first,
                   let text = self.locationString(from: place) {
                    self.isLocationLoading = false
                    self.locationDisplayText = text
                    self.locationNameForRecord = text
                    return
                }
                if let google = self.googleGeocodingService,
                   let addr = await google.reverseGeocode(
                    latitude: location.coordinate.latitude,
                    longitude: location.coordinate.longitude
                   ), !addr.isEmpty {
                    self.isLocationLoading = false
                    self.locationDisplayText = addr
                    self.locationNameForRecord = addr
                    return
                }
                self.isLocationLoading = false
                self.locationDisplayText = "無法取得地區"
                self.locationNameForRecord = nil
            }
        }
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

