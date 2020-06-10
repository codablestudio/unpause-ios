//
//  MapViewModel.swift
//  Unpause
//
//  Created by Krešimir Baković on 29/05/2020.
//  Copyright © 2020 Krešimir Baković. All rights reserved.
//

import Foundation
import RxSwift
import MapKit

protocol MapViewModelProtocol {
    var addCompanyLocationButtonTapped: PublishSubject<Void> { get }
    var removeSelectedLocationButtonTapped: PublishSubject<Void> { get }
    var textInCenterPinTextFieldChanges: PublishSubject<String?> { get }
    var currentPinMapLocationChanges: PublishSubject<CLLocationCoordinate2D?> { get }
    var userSelectedLocation: PublishSubject<Location?> { get }
    
    var newUserLocationSavingResponse: Observable<NewLocationSavingResponse>! { get }
    var selectedLocationDeletionResponse: Observable<UnpauseResponse>! { get }
    
    func removeDeletedLocationFromCurrentUserLocations()
}

class MapViewModel: MapViewModelProtocol {
    
    private let disposeBag = DisposeBag()
    private let locationNetworking: LocationNetworkingProtocol
    
    var addCompanyLocationButtonTapped = PublishSubject<Void>()
    var removeSelectedLocationButtonTapped = PublishSubject<Void>()
    var textInCenterPinTextFieldChanges = PublishSubject<String?>()
    var currentPinMapLocationChanges = PublishSubject<CLLocationCoordinate2D?>()
    var userSelectedLocation = PublishSubject<Location?>()
    
    var newUserLocationSavingResponse: Observable<NewLocationSavingResponse>!
    var selectedLocationDeletionResponse: Observable<UnpauseResponse>!
    
    private var textInCenterPinTextField: String?
    private var currentPinMapLocation: CLLocationCoordinate2D?
    private var selectedLocation: Location?
    
    init(locationNetworking: LocationNetworkingProtocol) {
        self.locationNetworking = locationNetworking
        setUpObservables()
    }
    
    private func setUpObservables() {
        currentPinMapLocationChanges.subscribe(onNext: { [weak self] cLLocationCoordinate2D in
            guard let `self` = self else { return }
            self.currentPinMapLocation = cLLocationCoordinate2D
        }).disposed(by: disposeBag)
        
        textInCenterPinTextFieldChanges.subscribe(onNext: { newText in
            self.textInCenterPinTextField = newText
        }).disposed(by: disposeBag)
        
        newUserLocationSavingResponse = addCompanyLocationButtonTapped
            .flatMapLatest({ [weak self] _ -> Observable<NewLocationSavingResponse> in
                guard let `self` = self else { return Observable.empty() }
                guard let locationCoordinate = self.currentPinMapLocation,
                    let locationName = self.textInCenterPinTextField,
                    !locationName.isEmpty else {
                        return Observable.just(NewLocationSavingResponse.error(.locationNameError))
                }
                let newUserLocation = Location(coordinate: locationCoordinate, name: locationName)
                return self.locationNetworking.saveNewUsersLocationToDataBase(location: newUserLocation)
            })
        
        selectedLocationDeletionResponse = removeSelectedLocationButtonTapped
            .flatMapLatest({ [weak self] _ -> Observable<UnpauseResponse> in
                guard let `self` = self else { return Observable.empty() }
                guard let selectedLocation = self.selectedLocation else {
                    return Observable.just(UnpauseResponse.error(.selectedLocationError))
                }
                return self.locationNetworking.deleteLocationFromDataBase(locationToDelete: selectedLocation)
            })
        
        userSelectedLocation.subscribe(onNext: { [weak self] location in
            guard let `self` = self else { return }
            self.selectedLocation = location
        }).disposed(by: disposeBag)
    }
    
    func removeDeletedLocationFromCurrentUserLocations() {
        guard let allUserLocations = SessionManager.shared.currentUser?.privateUserLocations else {
            return
        }
        for (index, location) in allUserLocations.enumerated() {
            if location.name == selectedLocation?.name && location.coordinate.longitude == selectedLocation?.coordinate.longitude && location.coordinate.latitude == selectedLocation?.coordinate.latitude {
                SessionManager.shared.currentUser?.privateUserLocations.remove(at: index)
                SessionManager.shared.saveCurrentUserToUserDefaults()
            }
        }
    }
}
