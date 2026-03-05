//
//  MapLocationPickerModel.swift
//  tip-calculator
//
//  Created by Willy Hsu on 2026/3/5.
//

import CoreLocation
import MapKit

struct MapLocationPickerSearchResultItem {
    let title: String
    let subtitle: String
    let coordinate: CLLocationCoordinate2D
    let displayAddress: String

    init(mkMapItem: MKMapItem) {
        self.title = mkMapItem.name ?? ""
        self.subtitle = mkMapItem.placemark.title ?? ""
        self.coordinate = mkMapItem.placemark.coordinate
        let parts = [title, subtitle].filter { !$0.isEmpty }
        self.displayAddress = parts.joined(separator: " · ")
    }
}
