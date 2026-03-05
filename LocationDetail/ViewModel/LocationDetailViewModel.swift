//
//  LocationDetailViewModel.swift
//  tip-calculator
//
//  Created by Willy Hsu on 2026/3/3.
//

import CoreLocation
import Foundation
import MapKit

final class LocationMapAnnotation: NSObject, MKAnnotation {
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
        annotations = buildAnnotations(from: filteredRecordsByTime())
        region = fittedMapRect(for: annotations.map(\.coordinate))
    }

    private struct LocationGroup {
        let coordinate: CLLocationCoordinate2D
        let name: String
        var records: [ConsumptionRecord]
    }

    private func buildAnnotations(from records: [ConsumptionRecord]) -> [LocationMapAnnotation] {
        let roundedPrecision: Double = 3e-4 // ~30m（1° ≈ 111km）
        func roundedCoord(_ c: CLLocationCoordinate2D) -> (lat: Double, lon: Double) {
            (lat: (c.latitude / roundedPrecision).rounded() * roundedPrecision,
             lon: (c.longitude / roundedPrecision).rounded() * roundedPrecision)
        }

        var byLocation: [String: LocationGroup] = [:]

        for record in records {
            guard let coord = record.coordinate else { continue }
            let key = "\(roundedCoord(coord).lat),\(roundedCoord(coord).lon)"
            let districtName = record.districtKey

            if var group = byLocation[key] {
                group.records.append(record)
                byLocation[key] = group
            } else {
                byLocation[key] = LocationGroup(coordinate: coord, name: districtName, records: [record])
            }
        }

        return byLocation.values.map { group in
            LocationMapAnnotation(
                coordinate: group.coordinate,
                title: "\(group.name) (\(group.records.count))",
                subtitle: nil,
                records: group.records
            )
        }
    }

    private func filteredRecordsByTime() -> [ConsumptionRecord] {
        timeFilter.consumptionTimeRange.filter(store.fetchAll())
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
