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
    func saveNewUsersLocationToDataBase(location: Location) -> Observable<NewLocationSavingResponse>
    func fetchCurrentUsersLocationsAndSaveThemLocally() -> Observable<UnpauseResponse>
    func deleteLocationFromDataBase(locationToDelete: Location) -> Observable<UnpauseResponse>
}

class LocationNetworking: LocationNetworkingProtocol {
    
    private let dataBaseReference = Firestore.firestore()
    
    func saveNewUsersLocationToDataBase(location: Location) -> Observable<NewLocationSavingResponse> {
        guard let currentUserEmail = SessionManager.shared.currentUser?.email else {
            return Observable.just(NewLocationSavingResponse.error(.noUser))
        }
        let locationServerData = LocationFactory.createLocationData(from: location)
        return dataBaseReference
            .collection("users")
            .document(currentUserEmail)
            .collection("locations")
            .rx
            .addDocument(data: locationServerData)
            .flatMapLatest ({ documentReference -> Observable<NewLocationSavingResponse> in
                return Observable.just(NewLocationSavingResponse.success(documentReference.documentID))
            })
            .catchError ({ error -> Observable<NewLocationSavingResponse> in
                return Observable.just(NewLocationSavingResponse.error(error as! UnpauseError))
            })
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
            .catchError ({ error -> Observable<UnpauseResponse> in
                return Observable.just(UnpauseResponse.error(.locationsFetchingError))
            })
    }
    
    func deleteLocationFromDataBase(locationToDelete: Location) -> Observable<UnpauseResponse> {
        guard let currentUserEmail = SessionManager.shared.currentUser?.email else {
            return Observable.just(UnpauseResponse.error(.noUser))
        }
        guard let locationUID = locationToDelete.uid else {
            return Observable.just(UnpauseResponse.error(.deletionError))
        }
        return dataBaseReference
            .collection("users")
            .document(currentUserEmail)
            .collection("locations")
            .document(locationUID)
            .rx
            .delete()
            .flatMapLatest ({ _ -> Observable<UnpauseResponse> in
                return Observable.just(UnpauseResponse.success)
            })
            .catchError ({ error -> Observable<UnpauseResponse> in
                return Observable.just(UnpauseResponse.error(.otherError(error)))
            })
    }
}
