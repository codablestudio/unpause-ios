//
//  Location.swift
//  Unpause
//
//  Created by Krešimir Baković on 05/06/2020.
//  Copyright © 2020 Krešimir Baković. All rights reserved.
//

import Foundation
import MapKit

class Location: NSObject, NSCoding {
    
    var locationCoordinate: CLLocationCoordinate2D!
    var name: String
    
    init(locationCoordinate: CLLocationCoordinate2D, name: String) {
        self.locationCoordinate = locationCoordinate
        self.name = name
    }
    
    required init?(coder: NSCoder) {
        name = coder.decodeObject(forKey: "name") as! String
        super.init()
        decodeLocation(coder: coder)
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(name, forKey: "name")
        encodeLocation(with: coder)
    }
}

private extension Location {
    func decodeLocation(coder: NSCoder) {
        let locationLatitude = coder.decodeObject(forKey: "locationCoordinateLatitude") as? CLLocationDegrees ?? 0
        let locationLongitude = coder.decodeObject(forKey: "locationCoordinateLongitude") as? CLLocationDegrees ?? 0
        self.locationCoordinate = CLLocationCoordinate2D(latitude: locationLatitude, longitude: locationLongitude)
    }
    
    func encodeLocation(with coder: NSCoder) {
        coder.encode(locationCoordinate.latitude, forKey: "locationCoordinateLatitude")
        coder.encode(locationCoordinate.longitude, forKey: "locationCoordinateLongitude")
    }
}
