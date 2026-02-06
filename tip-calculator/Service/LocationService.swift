//
//  LocationService.swift
//  tip-calculator
//

import CoreLocation

protocol LocationProviding: AnyObject {
    var lastLocation: CLLocation? { get }
}

final class LocationService: NSObject, LocationProviding {

    static let shared = LocationService()

    private let manager = CLLocationManager()

    private(set) var lastLocation: CLLocation?

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyKilometer
    }

    func start() {
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }

    func stop() {
        manager.stopUpdatingLocation()
    }
}

extension LocationService: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        lastLocation = location
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {}
}
