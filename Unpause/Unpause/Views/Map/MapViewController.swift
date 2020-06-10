//
//  MapViewController.swift
//  Unpause
//
//  Created by Krešimir Baković on 29/05/2020.
//  Copyright © 2020 Krešimir Baković. All rights reserved.
//

import UIKit
import MapKit
import RxSwift

class MapViewController: UIViewController {
    
    private let mapViewModel: MapViewModelProtocol
    private let disposeBag = DisposeBag()
    
    private let mapView = MKMapView()
    
    private let centerPinImageView = UIImageView()
    private let centerPinTextField = PaddedTextFieldWithCursor()

    private let addNewCompanyLocationButton = UIButton()
    private let removeSelectedLocationButton = UIButton()
    
    var currentPinMapLocationChanges = PublishSubject<CLLocationCoordinate2D?>()
    var selectedLocation = PublishSubject<Location?>()
    
    private var selectedAnnotationView: MKAnnotationView?
    
    init(mapViewModel: MapViewModelProtocol) {
        self.mapViewModel = mapViewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        render()
        setUpObservables()
        setUpMapViewDelegate()
        zoomInToCurrentUserPosition()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        hideTabBar()
        showExistingLocationsOnMap()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        showTabBar()
    }
    
    private func render() {
        renderMapView()
        renderCenterPinImageView()
        renderCenterPinTextField()
        renderAddCompanyLocationButton()
        renderRemoveSelectedLocationButton()
    }
    
    private func setUpObservables() {
        Observable.combineLatest(mapView.rx.panGesture(), mapView.rx.pinchGesture(), mapView.rx.tapGesture())
            .subscribe(onNext: { [weak self] gesture in
                guard let `self` = self else { return }
                if gesture.0.state == .began || gesture.1.state == .began || gesture.2.state == .began {
                    self.centerPinTextField.fadeOut(withDuration: 0.3, completion: nil)
                }
                if gesture.0.state == .ended || gesture.1.state == .ended || gesture.2.state == .ended {
                    self.centerPinTextField.fadeIn(withDuration: 0.3, completion: nil)
                }
                self.currentPinMapLocationChanges.onNext(self.mapView.centerCoordinate)
            }).disposed(by: disposeBag)
        
        mapView.rx.tapGesture()
            .subscribe(onNext: { [weak self] _ in
                guard let `self` = self else { return }
                self.dismissKeyboard()
                self.selectedAnnotationView?.image = UIImage(named: "pin_40x40_orange")
                self.selectedAnnotationView = nil
                self.removeSelectedLocationButton.isHidden = true
                self.selectedLocation.onNext(nil)
            }).disposed(by: disposeBag)
        
        currentPinMapLocationChanges
            .bind(to: mapViewModel.currentPinMapLocationChanges)
            .disposed(by: disposeBag)
        
        centerPinTextField.rx.text
            .bind(to: mapViewModel.textInCenterPinTextFieldChanges)
            .disposed(by: disposeBag)
        
        addNewCompanyLocationButton.rx.tap
            .do(onNext: { [weak self] _ in
                guard let `self` = self else { return }
                UnpauseActivityIndicatorView.shared.show(on: self.view)
            })
            .bind(to: mapViewModel.addCompanyLocationButtonTapped)
            .disposed(by: disposeBag)
        
        removeSelectedLocationButton.rx.tap
            .do(onNext: { [weak self] _ in
                guard let `self` = self else { return }
                UnpauseActivityIndicatorView.shared.show(on: self.view)
            })
            .bind(to: mapViewModel.removeSelectedLocationButtonTapped)
            .disposed(by: disposeBag)
        
        mapViewModel.newUserLocationSavingResponse
            .subscribe(onNext: { [weak self] newLocationSavingResponse in
                guard let `self` = self else { return }
                switch newLocationSavingResponse {
                case .success(let uid):
                    UnpauseActivityIndicatorView.shared.showSuccessMessageAndDismissWithDelay(from: self.view, successMessage: "Location successfully added.", delay: 1.4)
                    self.saveNewLocationWithUidLocallyAndUpdateMapView(uid: uid)
                    self.clearTextInCenterPinTextField()
                case .error(let error):
                    UnpauseActivityIndicatorView.shared.dismiss(from: self.view)
                    self.showOneOptionAlert(title: "Location saving error", message: "\(error.errorMessage)", actionTitle: "OK")
                }
            }).disposed(by: disposeBag)
        
        mapViewModel.selectedLocationDeletionResponse
            .subscribe(onNext: {  [weak self] deletionResponse in
                guard let `self` = self else { return }
                switch deletionResponse {
                case .success:
                    self.mapViewModel.removeDeletedLocationFromCurrentUserLocations()
                    self.removeDeletedLocationFromMap()
                    self.selectedAnnotationView = nil
                    self.selectedLocation.onNext(nil)
                    self.removeSelectedLocationButton.isHidden = true
                    UnpauseActivityIndicatorView.shared.showSuccessMessageAndDismissWithDelay(from: self.view, successMessage: "Location successfully removed.", delay: 1.4)
                case .error(let error):
                    UnpauseActivityIndicatorView.shared.dismiss(from: self.view)
                    self.showOneOptionAlert(title: "Location deletion error", message: "\(error.errorMessage)", actionTitle: "OK")
                }
            }).disposed(by: disposeBag)
        
        selectedLocation.bind(to: mapViewModel.userSelectedLocation)
            .disposed(by: disposeBag)
    }
    
    private func setUpMapViewDelegate() {
        mapView.delegate = self
    }
    
    private func zoomInToCurrentUserPosition() {
        guard let currentUserLocation = LocationManager.shared.getLocationManager().location?.coordinate else {
            return
        }
        let regionCenter = CLLocationCoordinate2D(latitude: currentUserLocation.latitude,
                                                  longitude: currentUserLocation.longitude)
        let region = MKCoordinateRegion(center: regionCenter, latitudinalMeters: 1000, longitudinalMeters: 1000)
        mapView.setRegion(region, animated: true)
    }
    
    private func clearTextInCenterPinTextField() {
        centerPinTextField.becomeFirstResponder()
        centerPinTextField.text?.removeAll()
        centerPinTextField.resignFirstResponder()
    }
    
    private func showExistingLocationsOnMap() {
        guard let allUserLocations = SessionManager.shared.currentUser?.privateUserLocations else {
            return
        }
        for location in allUserLocations {
            addAnnotationToMap(location: location)
        }
    }
    
    private func saveNewLocationWithUidLocallyAndUpdateMapView(uid: String) {
        let locationCoordinate = mapView.centerCoordinate
        guard let locationName = centerPinTextField.text else {
            return
        }
        let newLocation = Location(coordinate: locationCoordinate, name: locationName)
        newLocation.uid = uid
        SessionManager.shared.currentUser?.privateUserLocations.append(newLocation)
        SessionManager.shared.saveCurrentUserToUserDefaults()
        addAnnotationToMap(location: newLocation)
    }
    
    private func removeDeletedLocationFromMap() {
        guard let annotationToRemove = selectedAnnotationView?.annotation else {
            return
        }
        mapView.removeAnnotation(annotationToRemove)
    }
    
    private func addAnnotationToMap(location: Location) {
        let annotation = MKPointAnnotation()
        annotation.title = location.name
        annotation.coordinate = location.coordinate
        mapView.addAnnotation(annotation)
    }
}

// MARK: - UI rendering
private extension MapViewController {
    func renderMapView() {
        view.addSubview(mapView)
        mapView.snp.makeConstraints { make in
            make.top.left.right.bottom.equalToSuperview()
        }
    }
    
    func renderCenterPinImageView() {
        mapView.addSubview(centerPinImageView)
        centerPinImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.height.width.equalTo(40)
            make.bottom.equalTo(mapView.snp.centerY).offset(40)
        }
        centerPinImageView.image = UIImage(named: "pin_40x40_green")
    }
    
    func renderCenterPinTextField() {
        mapView.addSubview(centerPinTextField)
        centerPinTextField.snp.makeConstraints { make in
            make.bottom.equalTo(centerPinImageView.snp.top).offset(-5)
            make.centerX.equalTo(centerPinImageView.snp.centerX)
        }
        centerPinTextField.textInsets = UIEdgeInsets(top: 5, left: 8, bottom: 5, right: 8)
        centerPinTextField.backgroundColor = .unpauseBlack
        centerPinTextField.textColor = .unpauseWhite
        centerPinTextField.font = .systemFont(ofSize: 12, weight: .regular)
        centerPinTextField.layer.cornerRadius = 10
        centerPinTextField.textAlignment = .center
        centerPinTextField.attributedPlaceholder = NSAttributedString(string: "Location name",
                                                                      attributes: [NSAttributedString.Key.foregroundColor: UIColor.unpauseLightGray])
        centerPinTextField.autocorrectionType = .no
        centerPinTextField.autocapitalizationType = .sentences
        centerPinTextField.minimumFontSize = 12
    }
    
    func renderAddCompanyLocationButton() {
        mapView.addSubview(addNewCompanyLocationButton)
        addNewCompanyLocationButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(30)
            make.right.equalToSuperview().inset(30)
            make.bottom.equalToSuperview().inset(60)
            make.height.equalTo(55)
        }
        addNewCompanyLocationButton.setTitle("Add company location", for: .normal)
        addNewCompanyLocationButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        addNewCompanyLocationButton.layer.cornerRadius = 25
        addNewCompanyLocationButton.backgroundColor = .unpauseGreen
    }
    
    func renderRemoveSelectedLocationButton() {
        mapView.addSubview(removeSelectedLocationButton)
        removeSelectedLocationButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(30)
            make.right.equalToSuperview().inset(30)
            make.bottom.equalToSuperview().inset(60)
            make.height.equalTo(55)
        }
        removeSelectedLocationButton.setTitle("Remove location", for: .normal)
        removeSelectedLocationButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        removeSelectedLocationButton.layer.cornerRadius = 25
        removeSelectedLocationButton.backgroundColor = .unpauseRed
        removeSelectedLocationButton.isHidden = true
    }
}

// MARK: - MKMapViewDelegate
extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        setSelectedLocation(with: view)
        removeSelectedLocationButton.isHidden = false
        view.image = UIImage(named: "pin_40x40_red")
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKAnnotationView { return nil }
        else {
            let greenPinIdentifier = "greenPin"
            var pinView: MKAnnotationView?
            if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: greenPinIdentifier) {
                dequeuedView.annotation = annotation
                pinView = dequeuedView
            }
            else {
                pinView = MKAnnotationView(annotation: annotation, reuseIdentifier: greenPinIdentifier)
                pinView?.image = UIImage(named: "pin_40x40_orange")
                pinView?.canShowCallout = true
            }
            return pinView
        }
    }
    
    func setSelectedLocation(with annotationView: MKAnnotationView) {
        selectedAnnotationView = annotationView
        guard let annotationTitle = annotationView.annotation?.title,
            let annotationCoordinate = annotationView.annotation?.coordinate else {
                return
        }
        let location = Location(coordinate: annotationCoordinate, name: annotationTitle!)
        let uid = findUIDForSelectedLocation(selectedLocation: location)
        location.uid = uid
        selectedLocation.onNext(location)
    }
    
    func findUIDForSelectedLocation(selectedLocation: Location) -> String? {
        var uid: String?
        guard let currentUserLocations = SessionManager.shared.currentUser?.privateUserLocations else {
            return ""
        }
        for location in currentUserLocations {
            if location.name == selectedLocation.name && location.coordinate.latitude == selectedLocation.coordinate.latitude && selectedLocation.coordinate.longitude == location.coordinate.longitude {
                uid = location.uid
            }
        }
        return uid
    }
}
