//
//  UserFactory.swift
//  Unpause
//
//  Created by Krešimir Baković on 08/01/2020.
//  Copyright © 2020 Krešimir Baković. All rights reserved.
//

import Foundation
import Firebase
import CoreLocation

class UserFactory {
    static func createUser(from document: DocumentSnapshot) throws -> User {
        guard let email = document.get("email") as? String else { throw UnpauseError.defaultError }
        guard let firstName = document.get("firstName") as? String else { throw UnpauseError.defaultError }
        guard let lastName = document.get("lastName") as? String else { throw UnpauseError.defaultError }
        return User(firstName: firstName, lastName: lastName, email: email)
    }
    
    static func createBoss(from document: DocumentSnapshot) throws -> User {
        guard let bossData = document.get("boss") as? [String: Any] else { throw UnpauseError.defaultError }
        guard let bossFirstName = bossData["firstName"] as? String else { throw UnpauseError.defaultError }
        guard let bossLastName = bossData["lastName"] as? String else { throw UnpauseError.defaultError }
        guard let bossEmail = bossData["email"] as? String else { throw UnpauseError.defaultError }
        return User(firstName: bossFirstName, lastName: bossLastName, email: bossEmail)
    }
    
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
    
    static func initialize(firstName: String, lastName: String, email: String) -> User {
        let newUser = User(firstName: firstName, lastName: lastName, email: email)
        return newUser
    }
}
