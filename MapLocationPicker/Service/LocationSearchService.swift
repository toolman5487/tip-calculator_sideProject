//
//  LocationSearchService.swift
//  tip-calculator
//
//  Created by Willy Hsu on 2026/3/5.
//

import CoreLocation
import MapKit

protocol LocationSearching {
    func search(query: String, regionCenter: CLLocationCoordinate2D, completion: @escaping ([MKMapItem]) -> Void)
}

struct MKLocationSearchService: LocationSearching {
    func search(query: String, regionCenter: CLLocationCoordinate2D, completion: @escaping ([MKMapItem]) -> Void) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        request.region = MKCoordinateRegion(center: regionCenter, latitudinalMeters: 50_000, longitudinalMeters: 50_000)
        let search = MKLocalSearch(request: request)
        search.start { response, _ in
            DispatchQueue.main.async {
                completion(response?.mapItems ?? [])
            }
        }
    }
}
