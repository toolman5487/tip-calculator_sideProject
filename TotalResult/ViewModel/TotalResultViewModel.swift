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
    private let reverseGeocodeService: ReverseGeocoding

    @Published private(set) var locationDisplayText: String = ""
    @Published private(set) var isLocationLoading = true
    @Published private(set) var locationNameForRecord: String?

    private var mapPickedLocation: (address: String, latitude: Double, longitude: Double)?

    init(
        result: Result,
        store: ConsumptionRecordStoring = ConsumptionRecordStore(),
        locationProvider: LocationProviding = LocationService.shared,
        reverseGeocodeService: ReverseGeocoding = ReverseGeocodeService()
    ) {
        self.result = result
        self.store = store
        self.locationProvider = locationProvider
        self.reverseGeocodeService = reverseGeocodeService
    }

    func updateLocationFromMapPicker(address: String, latitude: Double, longitude: Double) {
        mapPickedLocation = (address, latitude, longitude)
        locationDisplayText = address
        locationNameForRecord = address
        isLocationLoading = false
    }

    var latitudeForSave: Double? {
        mapPickedLocation?.latitude ?? locationProvider.lastLocation?.coordinate.latitude
    }

    var longitudeForSave: Double? {
        mapPickedLocation?.longitude ?? locationProvider.lastLocation?.coordinate.longitude
    }

    var initialLocationForMapPicker: (address: String?, latitude: Double?, longitude: Double?) {
        let addr = locationDisplayText.isEmpty || locationDisplayText == "無法定位" || locationDisplayText == "請開啟定位權限"
            ? nil
            : locationDisplayText
        return (
            addr,
            mapPickedLocation?.latitude ?? locationProvider.lastLocation?.coordinate.latitude,
            mapPickedLocation?.longitude ?? locationProvider.lastLocation?.coordinate.longitude
        )
    }

    func refreshLocation() {
        guard mapPickedLocation == nil else { return }
        isLocationLoading = true
        guard let location = locationProvider.lastLocation else {
            locationDisplayText = locationErrorMessage
            isLocationLoading = false
            locationNameForRecord = nil
            return
        }
        reverseGeocodeService.reverseGeocode(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude) { [weak self] addr in
            guard let self else { return }
            self.isLocationLoading = false
            if let addr = addr, !addr.isEmpty {
                self.locationDisplayText = addr
                self.locationNameForRecord = addr
            } else {
                self.locationDisplayText = "無法取得地區"
                self.locationNameForRecord = nil
            }
        }
    }

    private var locationErrorMessage: String {
        switch locationProvider.authorizationStatus {
        case .denied, .restricted:
            return "請開啟定位權限"
        default:
            return "無法定位"
        }
    }

    @discardableResult
    func saveRecord() -> Bool {
        let address = locationDisplayText.isEmpty ? nil : locationDisplayText
        let success = store.save(
            result: result,
            latitude: latitudeForSave,
            longitude: longitudeForSave,
            address: address,
            locationName: locationNameForRecord,
            categoryIdentifier: result.categoryIdentifier
        )
        if success {
            TabBarBadgePublisher.increment(on: .userInfo)
        }
        return success
    }
}

