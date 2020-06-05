//
//  Location.swift
//  Unpause
//
//  Created by Krešimir Baković on 05/06/2020.
//  Copyright © 2020 Krešimir Baković. All rights reserved.
//

import Foundation
import MapKit

class Location {
    var locationCoordinate: CLLocationCoordinate2D
    var name: String
    
    init(locationCoordinate: CLLocationCoordinate2D, name: String) {
        self.locationCoordinate = locationCoordinate
        self.name = name
    }
}
