//
//  SelectedLocationAnnotation.swift
//  tip-calculator
//
//  Created by Willy Hsu on 2026/3/5.
//

import MapKit

final class SelectedLocationAnnotation: NSObject, MKAnnotation {
    let coordinate: CLLocationCoordinate2D
    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
    }
}
