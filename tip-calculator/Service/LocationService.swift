//
//  LocationService.swift
//  tip-calculator
//

import CoreLocation

final class LocationService: NSObject {

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
        let lat = location.coordinate.latitude
        let lon = location.coordinate.longitude
        print("[LocationService] 收到定位 lat=\(lat), lon=\(lon)")
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("[LocationService] 定位錯誤: \(error.localizedDescription)")
    }
}
