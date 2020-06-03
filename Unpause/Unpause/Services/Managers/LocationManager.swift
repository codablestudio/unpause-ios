//
//  LocationManager.swift
//  Unpause
//
//  Created by Krešimir Baković on 04/03/2020.
//  Copyright © 2020 Krešimir Baković. All rights reserved.
//

import Foundation
import CoreLocation

class LocationManager {
    
    static var shared = LocationManager()
    
    private let locationManager = CLLocationManager()
    
    private init() {
        locationManager.delegate = self as? CLLocationManagerDelegate
    }
    
    func getLocationManager() -> CLLocationManager {
        return locationManager
    }
    
    func configure() {
        LocationManager.shared.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        LocationManager.shared.locationManager.pausesLocationUpdatesAutomatically = false
        LocationManager.shared.locationManager.requestWhenInUseAuthorization()
        LocationManager.shared.locationManager.startUpdatingLocation()
    }
    
    func makeSpecificCircularRegion(latitude: CLLocationDegrees,
                                    longitude: CLLocationDegrees,
                                    radius: CLLocationDistance,
                                    notifyOnEntry: Bool,
                                    notifyOnExit: Bool) -> CLCircularRegion {
        let centerLocation = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let region = CLCircularRegion(center: centerLocation, radius: radius, identifier: UUID().uuidString)
        region.notifyOnEntry = notifyOnEntry
        region.notifyOnExit = notifyOnExit
        return region
    }
}
