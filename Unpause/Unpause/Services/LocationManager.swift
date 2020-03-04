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
    
    let locationManager = CLLocationManager()
    
    init() {
        locationManager.delegate = self as? CLLocationManagerDelegate
    }
    
    func makeSpecificCircularRegion(latitude: CLLocationDegrees,
                                    longitude: CLLocationDegrees,
                                    radius: CLLocationDistance) -> CLCircularRegion {
        let centerLocation = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let region = CLCircularRegion(center: centerLocation, radius: radius, identifier: UUID().uuidString)
        region.notifyOnEntry = true
        region.notifyOnExit = true
        return region
    }
}
