//
//  LocationService.swift
//  tip-calculator
//

import CoreLocation

protocol LocationProviding: AnyObject {
    var lastLocation: CLLocation? { get }
    var authorizationStatus: CLAuthorizationStatus { get }
}

final class LocationService: NSObject, LocationProviding {

    static let shared = LocationService()

    private let manager = CLLocationManager()

    private(set) var lastLocation: CLLocation?
    var authorizationStatus: CLAuthorizationStatus { manager.authorizationStatus }

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        manager.distanceFilter = kCLDistanceFilterNone
        manager.activityType = .other
    }

    func start() {
        manager.requestWhenInUseAuthorization()
        startLocationUpdatesIfAuthorized()
    }

    func stop() {
        manager.stopUpdatingLocation()
    }

    private func startLocationUpdatesIfAuthorized() {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            manager.startUpdatingLocation()
        case .notDetermined:
            break
        case .restricted, .denied:
            lastLocation = nil
        @unknown default:
            break
        }
    }
}

extension LocationService: CLLocationManagerDelegate {

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        startLocationUpdatesIfAuthorized()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let freshLocations = locations.filter { $0.horizontalAccuracy > 0 }
        guard let best = freshLocations.sorted(by: { $0.horizontalAccuracy < $1.horizontalAccuracy }).first else {
            return
        }
        lastLocation = best
        if best.horizontalAccuracy <= 100 {
            manager.stopUpdatingLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if (error as? CLError)?.code == .denied {
            lastLocation = nil
        }
    }
}
