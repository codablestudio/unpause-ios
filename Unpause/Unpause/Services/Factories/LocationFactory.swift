//
//  LocationFactory.swift
//  Unpause
//
//  Created by Krešimir Baković on 05/06/2020.
//  Copyright © 2020 Krešimir Baković. All rights reserved.
//

import Foundation
import Firebase
import MapKit

class LocationFactory {
    static func createLocationData(from location: Location) -> [String: Any] {
        var locationData = [String: Any]()
        let geopoint = GeoPoint(latitude: location.locationCoordinate.latitude,
                                longitude: location.locationCoordinate.longitude)
        locationData["name"] = location.name
        locationData["geopoint"] = geopoint
        return locationData
    }
}
