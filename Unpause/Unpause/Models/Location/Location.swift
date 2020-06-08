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
    
    var coordinate: CLLocationCoordinate2D!
    var name: String
    
    init(coordinate: CLLocationCoordinate2D, name: String) {
        self.coordinate = coordinate
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
        let locationLatitude = coder.decodeDouble(forKey: "locationLatitude")
        let locationLongitude = coder.decodeDouble(forKey: "locationLongitude")
        self.coordinate = CLLocationCoordinate2D(latitude: locationLatitude, longitude: locationLongitude)
    }
    
    func encodeLocation(with coder: NSCoder) {
        coder.encode(Double(coordinate.latitude), forKey: "locationLatitude")
        coder.encode(Double(coordinate.longitude), forKey: "locationLongitude")
    }
}
