//
//  LocationNetworking.swift
//  Unpause
//
//  Created by Krešimir Baković on 05/06/2020.
//  Copyright © 2020 Krešimir Baković. All rights reserved.
//

import Foundation
import Firebase
import FirebaseFirestore
import RxSwift
import RxFirebase
import MapKit

protocol LocationNetworkingProtocol {
    func saveNewUsersLocationToDataBase(location: Location) -> Observable<Response>
    func fetchCurrentUsersLocationsAndSaveThemLocally() -> Observable<UnpauseResponse>
}

class LocationNetworking: LocationNetworkingProtocol {
    
    private let dataBaseReference = Firestore.firestore()
    
    func saveNewUsersLocationToDataBase(location: Location) -> Observable<Response> {
        guard let currentUserEmail = SessionManager.shared.currentUser?.email else {
            return Observable.just(Response.error(.noUser))
        }
        let locationServerData = LocationFactory.createLocationData(from: location)
        return dataBaseReference
            .collection("users")
            .document(currentUserEmail)
            .collection("locations")
            .rx
            .addDocument(data: locationServerData)
            .flatMapLatest { documentReference -> Observable<Response> in
                return Observable.just(Response.success)
        }
        .catchError { error -> Observable<Response> in
            return Observable.just(Response.error(error as! UnpauseError))
        }
    }
    
    func fetchCurrentUsersLocationsAndSaveThemLocally() -> Observable<UnpauseResponse> {
        guard let currentUserEmail = SessionManager.shared.currentUser?.email else {
            return Observable.just(UnpauseResponse.error(.noUser))
        }
        return dataBaseReference
            .collection("users")
            .document(currentUserEmail)
            .collection("locations")
            .rx
            .getDocuments()
            .flatMapLatest ({ querySnapshot -> Observable<UnpauseResponse> in
                let userLocationsArray = LocationFactory.createLocations(from: querySnapshot.documents)
                SessionManager.shared.currentUser?.privateUserLocations = userLocationsArray
                SessionManager.shared.saveCurrentUserToUserDefaults()
                return Observable.just(UnpauseResponse.success)
            })
            .catchError { error -> Observable<UnpauseResponse> in
                return Observable.just(UnpauseResponse.error(.locationsFetchingError))
        }
    }
}
