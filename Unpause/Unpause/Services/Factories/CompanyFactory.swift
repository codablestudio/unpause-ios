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
        guard let documentData = document.data() else { return nil }
        guard let email = document.get("email") as? String else { throw UnpauseError.defaultError }
        guard let name = document.get("name") as? String else { throw UnpauseError.defaultError }
        let locationsData = documentData["locations"] as? [[String: Any]] ?? []
        let locations = createGeoPoints(from: locationsData)
        let company = Company(email: email, name: name, locations: locations)
        return company
    }
    
    static func createCompany(from queryDocument: QueryDocumentSnapshot) throws -> Company? {
        let documentData = queryDocument.data()
        guard let email = queryDocument.get("email") as? String else { throw UnpauseError.defaultError }
        guard let name = queryDocument.get("name") as? String else { throw UnpauseError.defaultError }
        let locationsData = documentData["locations"] as? [[String: Any]] ?? []
        let locations = createGeoPoints(from: locationsData)
        let company = Company(email: email, name: name, locations: locations)
        return company
    }
    
    static func createCompanies(from queryDocuments: [QueryDocumentSnapshot]) throws -> [Company]? {
        var newCompanyArray = [Company]()
        for documentData in queryDocuments {
            do {
                guard let company = try createCompany(from: documentData) else { return [] }
                newCompanyArray.append(company)
            } catch (let error) {
                print("ERROR: \(error.localizedDescription)")
            }
        }
        return newCompanyArray
    }
    
    static func createCompanyValidationData(from queryDocument: QueryDocumentSnapshot) throws -> CompanyValidationData? {
        guard let name = queryDocument.get("name") as? String else { throw UnpauseError.defaultError }
        guard let passcode = queryDocument.get("passcode") as? String else { throw UnpauseError.defaultError }
        let reference = queryDocument.documentID
        let companyValidationData = CompanyValidationData(companyName: name, companyPassCode: passcode, companyReference: reference)
        return companyValidationData
    }
    
    static func createCompaniesValidationData(from queryDocuments: [QueryDocumentSnapshot]) throws -> [CompanyValidationData]? {
        var newCompaniesValidationDataArray = [CompanyValidationData]()
        for documentData in queryDocuments {
            do {
                guard let companyValidationData = try createCompanyValidationData(from: documentData) else { return [] }
                newCompaniesValidationDataArray.append(companyValidationData)
            } catch (let error) {
                print("ERROR: \(error.localizedDescription)")
            }
        }
        return newCompaniesValidationDataArray
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
