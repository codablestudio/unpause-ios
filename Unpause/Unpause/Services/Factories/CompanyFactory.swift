//
//  CompanyFactory.swift
//  Unpause
//
//  Created by Krešimir Baković on 04/03/2020.
//  Copyright © 2020 Krešimir Baković. All rights reserved.
//

import Foundation
import Firebase

class CompanyFactory {
    
    static func createCompanyReference(from document: DocumentSnapshot) throws -> DocumentReference? {
        guard let companyReference = document.get("companyReference") as? DocumentReference else { throw UnpauseError.defaultError }
        return companyReference
    }
    
    static func createCompany(from document: DocumentSnapshot) throws -> Company? {
        guard let documentData = document.data() else { return Company() }
        guard let email = document.get("email") as? String else { throw UnpauseError.defaultError }
        guard let name = document.get("name") as? String else { throw UnpauseError.defaultError }
        let locationsData = documentData["locations"] as? [[String: Any]] ?? []
        let locations = createGeoPoints(from: locationsData)
        let company = Company()
        company.email = email
        company.name = name
        company.locations = locations
        return company
    }
    
    static func createGeoPoint(from data: [String: Any]) throws -> GeoPoint {
        guard let geoPoint = data["geopoint"] as? GeoPoint else { throw UnpauseError.defaultError }
        return geoPoint
    }
    
    static func createGeoPoints(from data: [[String: Any]]) -> [GeoPoint] {
        var geoPoints = [GeoPoint]()
        for locationData in data {
            do {
                let geoPoint =  try createGeoPoint(from: locationData)
                geoPoints.append(geoPoint)
            } catch (let error) {
                print("ERROR: \(error.localizedDescription)")
            }
        }
        return geoPoints
    }
}
