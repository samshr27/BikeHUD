//
//  RideTracker.swift
//  BikeHUD
//
//  Created by Samuel Shrestha on 8/18/25.
//

import Foundation
import CoreLocation

@MainActor
final class RideTracker: NSObject, ObservableObject {
    @Published var speedMps: Double = 0         // meters per second
    @Published var distanceMeters: Double = 0
    @Published var authorized = false

    private let manager = CLLocationManager()
    private var lastLocation: CLLocation?

    override init() {
        super.init()
        manager.delegate = self
        manager.activityType = .fitness
        manager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        manager.pausesLocationUpdatesAutomatically = false
    }

    func requestPermission() {
        manager.requestWhenInUseAuthorization()
    }

    func start() { manager.startUpdatingLocation() }
    func stop()  { manager.stopUpdatingLocation() }
}

extension RideTracker: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorized = (manager.authorizationStatus == .authorizedWhenInUse ||
                      manager.authorizationStatus == .authorizedAlways)
        if authorized { start() }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let loc = locations.last, loc.horizontalAccuracy > 0 else { return }

        // Distance
        if let last = lastLocation {
            let d = loc.distance(from: last)
            if d >= 0, d < 100 { distanceMeters += d } // ignore huge jumps
        }
        lastLocation = loc

        // Speed (m/s), -1 means invalid
        speedMps = max(0, loc.speed)
    }
}
