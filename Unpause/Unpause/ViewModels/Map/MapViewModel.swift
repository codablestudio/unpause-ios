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
    var textInCenterPinTextFieldChanges: PublishSubject<String?> { get }
    var currentPinMapLocationChanges: PublishSubject<CLLocationCoordinate2D?> { get }
    
    var newUserLocationSavingResponse: Observable<Response>! { get }
}

class MapViewModel: MapViewModelProtocol {
    
    private let disposeBag = DisposeBag()
    private let locationNetworking: LocationNetworkingProtocol
    
    var addCompanyLocationButtonTapped = PublishSubject<Void>()
    var textInCenterPinTextFieldChanges = PublishSubject<String?>()
    var currentPinMapLocationChanges = PublishSubject<CLLocationCoordinate2D?>()
    
    var newUserLocationSavingResponse: Observable<Response>!
    
    private var textInCenterPinTextField: String?
    private var currentPinMapLocation: CLLocationCoordinate2D?
    
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
            .flatMapLatest({ [weak self] _ -> Observable<Response> in
                guard let `self` = self,
                    let locationCoordinate = self.currentPinMapLocation,
                    let locationName = self.textInCenterPinTextField,
                    !locationName.isEmpty else {
                        return Observable.just(Response.error(.locationNameError))
                }
                let newUserLocation = Location(coordinate: locationCoordinate, name: locationName)
                return self.locationNetworking.saveNewUsersLocationToDataBase(location: newUserLocation)
            })
    }
}
