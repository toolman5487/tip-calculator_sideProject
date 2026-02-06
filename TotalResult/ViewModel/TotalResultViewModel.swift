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
            return
        }
        let lat = location.coordinate.latitude
        let lon = location.coordinate.longitude
        Task { @MainActor in
            if let google = googleGeocodingService,
               let addr = await google.reverseGeocode(latitude: lat, longitude: lon) {
                self.locationDisplayText = addr
                self.isLocationLoading = false
                return
            }
            self.fallbackToAppleGeocoder(location: location)
        }
    }

    private func fallbackToAppleGeocoder(location: CLLocation) {
        let geocoder = CLGeocoder()
        let locale = Locale(identifier: "zh_TW")
        geocoder.reverseGeocodeLocation(location, preferredLocale: locale) { [weak self] placemarks, _ in
            Task { @MainActor in
                guard let self else { return }
                self.isLocationLoading = false
                if let place = placemarks?.first {
                    let area = place.administrativeArea ?? ""
                    let district = place.subLocality ?? ""
                    let street = place.thoroughfare ?? ""
                    let parts = [area, district, street].filter { !$0.isEmpty }
                    self.locationDisplayText = parts.isEmpty ? "無法取得地區" : parts.joined(separator: " ")
                } else {
                    self.locationDisplayText = "無法取得地區"
                }
            }
        }
    }

    @discardableResult
    func saveRecord(latitude: Double? = nil, longitude: Double? = nil, address: String? = nil) -> Bool {
        store.save(result: result, latitude: latitude, longitude: longitude, address: address)
    }
}

