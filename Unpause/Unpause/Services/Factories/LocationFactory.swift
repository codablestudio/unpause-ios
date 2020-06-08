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
        let geoPoint = GeoPoint(latitude: location.locationCoordinate.latitude,
                                longitude: location.locationCoordinate.longitude)
        locationData["name"] = location.name
        locationData["geopoint"] = geoPoint
        return locationData
    }
    
    static func createLocations(from queryDocumentSnapshots: [QueryDocumentSnapshot]) -> [Location] {
        var locationsArray: [Location] = []
        for queryDocumentSnapshot in queryDocumentSnapshots {
            let newLocation = createLocation(from: queryDocumentSnapshot)
            locationsArray.append(newLocation)
        }
        return locationsArray
    }
    
    static func createLocation(from queryDocumentSnapshot: QueryDocumentSnapshot) -> Location {
        let locationData = queryDocumentSnapshot.data()
        let geoPoint = locationData["geopoint"] as? GeoPoint
        let name = locationData["name"] as? String
        guard let geoPointCoordinate = geoPoint,
        let locationName = name else {
            return Location(locationCoordinate: CLLocationCoordinate2D(), name: "No name")
        }
        let locationCoordinate = Formatter.shared.convertGeoPointToCLLocationCoordinateTwoD(geoPoint: geoPointCoordinate)
        return Location(locationCoordinate: locationCoordinate, name: locationName)
    }
}
