//
//  Formatter+Location.swift
//  Unpause
//
//  Created by Krešimir Baković on 08/06/2020.
//  Copyright © 2020 Krešimir Baković. All rights reserved.
//

import Foundation
import Firebase
import MapKit

extension Formatter {
    func convertGeoPointToCLLocationCoordinateTwoD(geoPoint: GeoPoint) -> CLLocationCoordinate2D {
        let latitude = geoPoint.latitude
        let longitude = geoPoint.longitude
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
