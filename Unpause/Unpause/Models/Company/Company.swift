//
//  Company.swift
//  Unpause
//
//  Created by Krešimir Baković on 04/03/2020.
//  Copyright © 2020 Krešimir Baković. All rights reserved.
//

import Foundation
import Firebase

class Company: NSObject, NSCoding {
    var email: String?
    var name: String?
    var locations = [GeoPoint]()
    
    required init?(coder: NSCoder) {
        email = coder.decodeObject(forKey: "email") as? String
        name = coder.decodeObject(forKey: "name") as? String
        
        let longitudes = coder.decodeObject(forKey: "longitudes") as? [Double] ?? []
        let latitudes = coder.decodeObject(forKey: "latitudes") as? [Double] ?? []
        guard longitudes.count == latitudes.count, !longitudes.isEmpty else { return }
        locations = []
        for index in 0...longitudes.count-1 {
            let newPoint = GeoPoint(latitude: latitudes[index], longitude: longitudes[index])
            locations.append(newPoint)
        }
    }
    
    init(email: String?, name: String?, locations: [GeoPoint]) {
        self.email = email
        self.name = name
        self.locations = locations
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(email, forKey: "email")
        coder.encode(name, forKey: "name")
        
        let longitudes = locations.map({ $0.longitude })
        coder.encode(longitudes, forKey: "longitudes")
        
        let latitudes = locations.map({ $0.latitude })
        coder.encode(latitudes, forKey: "latitudes")
    }
}
