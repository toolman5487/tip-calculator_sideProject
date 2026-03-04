//
//  LocationDetailViewModel.swift
//  tip-calculator
//
//  Created by Willy Hsu on 2026/3/3.
//

import CoreLocation
import Foundation
import MapKit

/// 自訂 MKAnnotation，用來在 mapView(_:didSelect:) 時取得對應的消費紀錄
final class LocationPinAnnotation: NSObject, MKAnnotation {
    let coordinate: CLLocationCoordinate2D
    let title: String?
    let subtitle: String?
    let records: [ConsumptionRecord]

    init(coordinate: CLLocationCoordinate2D, title: String?, subtitle: String?, records: [ConsumptionRecord]) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
        self.records = records
    }
}

struct LocationMapAnnotation {
    let coordinate: CLLocationCoordinate2D
    let title: String?
    let subtitle: String?
    let records: [ConsumptionRecord]
}

@MainActor
final class LocationDetailViewModel {

    @Published private(set) var annotations: [LocationMapAnnotation] = []
    @Published private(set) var region: MKMapRect?

    private let store: ConsumptionRecordStoring
    private let timeFilter: IllustrationTimeFilterOption

    init(timeFilter: IllustrationTimeFilterOption, store: ConsumptionRecordStoring = ConsumptionRecordStore()) {
        self.timeFilter = timeFilter
        self.store = store
        load()
    }

    func load() {
        let allFiltered = filteredRecordsByTime()
        var byDistrict: [String: (CLLocationCoordinate2D?, String, [ConsumptionRecord])] = [:]
        for record in allFiltered {
            let raw = record.locationName?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            let key: String = raw.isEmpty ? "未知地區" : LocationAddressFormatter.district.format(raw)
            let coord: CLLocationCoordinate2D?
            if let lat = record.latitude?.doubleValue, let lon = record.longitude?.doubleValue {
                coord = CLLocationCoordinate2D(latitude: lat, longitude: lon)
            } else {
                coord = nil
            }
            if var existing = byDistrict[key] {
                existing.2.append(record)
                if existing.0 == nil, let c = coord {
                    existing.0 = c
                }
                byDistrict[key] = existing
            } else {
                byDistrict[key] = (coord, key, [record])
            }
        }
        annotations = byDistrict
            .compactMap { _, value -> LocationMapAnnotation? in
                let (coord, name, recs) = value
                guard let coord else { return nil }
                return LocationMapAnnotation(
                    coordinate: coord,
                    title: "\(name) (\(recs.count))",
                    subtitle: nil,
                    records: recs
                )
            }
        region = fittedMapRect(for: annotations.map(\.coordinate))
    }

    private func filteredRecordsByTime() -> [ConsumptionRecord] {
        let all = store.fetchAll()
        let calendar = Calendar.current
        let now = Date()
        let timeRange = timeFilter.consumptionTimeRange
        guard let r = timeRange.range(calendar: calendar, now: now) else { return [] }
        return all.filter {
            guard let d = $0.createdAt else { return false }
            return timeRange.contains(d, range: r)
        }
    }

    /// 將消費紀錄轉為 sheet 所需之顯示資料
    func sheetContent(for records: [ConsumptionRecord], title: String?) -> (title: String, items: [RecordDisplayItem]) {
        let items = records.map { RecordDisplayItem.from($0, dateFormatter: AppDateFormatters.detail) }
        return (title ?? "消費紀錄", items)
    }

    private func fittedMapRect(for coordinates: [CLLocationCoordinate2D]) -> MKMapRect? {
        guard !coordinates.isEmpty else { return nil }
        var rect = MKMapRect.null
        for coord in coordinates {
            let point = MKMapPoint(coord)
            let pointRect = MKMapRect(x: point.x, y: point.y, width: 0, height: 0)
            rect = rect.isNull ? pointRect : rect.union(pointRect)
        }
        let minSize: Double = 5000
        let w = max(rect.width, minSize)
        let h = max(rect.height, minSize)
        let midX = rect.minX + rect.width / 2
        let midY = rect.minY + rect.height / 2
        return MKMapRect(
            x: midX - w * 0.75,
            y: midY - h * 0.75,
            width: w * 1.5,
            height: h * 1.5
        )
    }
}
