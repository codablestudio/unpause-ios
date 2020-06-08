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

    private let addCompanyLocationButton = UIButton()
    
    var currentPinMapLocationChanges = PublishSubject<CLLocationCoordinate2D?>()
    
    private var selectedAnnotation: MKAnnotation?
    
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
                self.addCompanyLocationButton.backgroundColor = .unpauseGreen
                self.addCompanyLocationButton.setTitle("Add company location", for: .normal)
                self.selectedAnnotation = nil
            }).disposed(by: disposeBag)
        
        currentPinMapLocationChanges
            .bind(to: mapViewModel.currentPinMapLocationChanges)
            .disposed(by: disposeBag)
        
        centerPinTextField.rx.text
            .bind(to: mapViewModel.textInCenterPinTextFieldChanges)
            .disposed(by: disposeBag)
        
        addCompanyLocationButton.rx.tap
            .do(onNext: { [weak self] _ in
                guard let `self` = self else { return }
                UnpauseActivityIndicatorView.shared.show(on: self.view)
            })
            .bind(to: mapViewModel.addCompanyLocationButtonTapped)
            .disposed(by: disposeBag)
        
        mapViewModel.newUserLocationSavingResponse
            .subscribe(onNext: { [weak self] response in
                guard let `self` = self else { return }
                switch response {
                case .success:
                    UnpauseActivityIndicatorView.shared.showSuccessMessageAndDismissWithDelay(from: self.view, successMessage: "Location successfully added.", delay: 1.4)
                    self.saveNewLocationLocallyAndUpdateMapView()
                    self.clearTextInCenterPinTextField()
                case .error(let error):
                    UnpauseActivityIndicatorView.shared.dismiss(from: self.view)
                    self.showOneOptionAlert(title: "Location saving error", message: "\(error.errorMessage)", actionTitle: "OK")
                }
            }).disposed(by: disposeBag)
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
    
    private func saveNewLocationLocallyAndUpdateMapView() {
        let locationCoordinate = mapView.centerCoordinate
        guard let locationName = centerPinTextField.text else {
            return
        }
        let newLocation = Location(coordinate: locationCoordinate, name: locationName)
        SessionManager.shared.currentUser?.privateUserLocations.append(newLocation)
        SessionManager.shared.saveCurrentUserToUserDefaults()
        addAnnotationToMap(location: newLocation)
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
        centerPinImageView.image = UIImage(named: "pin_40x40")
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
        mapView.addSubview(addCompanyLocationButton)
        addCompanyLocationButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(30)
            make.right.equalToSuperview().inset(30)
            make.bottom.equalToSuperview().inset(60)
            make.height.equalTo(55)
        }
        addCompanyLocationButton.setTitle("Add company location", for: .normal)
        addCompanyLocationButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        addCompanyLocationButton.layer.cornerRadius = 25
        addCompanyLocationButton.backgroundColor = .unpauseGreen
    }
}

// MARK: - MKMapViewDelegate
extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        addCompanyLocationButton.setTitle("Remove location", for: .normal)
        addCompanyLocationButton.backgroundColor = .unpauseOrange
        selectedAnnotation = view.annotation
    }
}
