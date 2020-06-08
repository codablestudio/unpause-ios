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
    
    private let addCompanyLocationContainerView = UIView()
    private let addCompanyLocationButton = UIButton()
    
    var currentPinMapLocationChanges = PublishSubject<CLLocationCoordinate2D?>()
    
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
        zoomInToCurrentUserPosition()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        hideTabBar()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        showTabBar()
    }
    
    private func render() {
        renderAddCompanyLocationButtonContainerView()
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
        
        currentPinMapLocationChanges
            .bind(to: mapViewModel.currentPinMapLocationChanges)
            .disposed(by: disposeBag)
        
        centerPinTextField.rx.text
            .bind(to: mapViewModel.textInCenterPinTextFieldChanges)
            .disposed(by: disposeBag)
        
        mapView.rx.tapGesture().subscribe(onNext: { [weak self] _ in
            guard let `self` = self else { return }
            self.dismissKeyboard()
        }).disposed(by: disposeBag)
        
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
                    self.clearTextInCenterPinTextField()
                    self.dismissKeyboard()
                case .error(let error):
                    UnpauseActivityIndicatorView.shared.dismiss(from: self.view)
                    self.showOneOptionAlert(title: "Location saving error", message: "\(error.errorMessage)", actionTitle: "OK")
                }
            }).disposed(by: disposeBag)
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
        centerPinTextField.text = ""
        centerPinTextField.resignFirstResponder()
    }
}

// MARK: - UI rendering
private extension MapViewController {
    func renderAddCompanyLocationButtonContainerView() {
        view.addSubview(addCompanyLocationContainerView)
        addCompanyLocationContainerView.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.left.right.equalToSuperview()
            make.height.equalTo(100)
        }
        addCompanyLocationContainerView.backgroundColor = .unpauseWhite
    }
    
    func renderMapView() {
        view.addSubview(mapView)
        mapView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.bottom.equalTo(addCompanyLocationContainerView.snp.top)
        }
    }
    
    func renderCenterPinImageView() {
        mapView.addSubview(centerPinImageView)
        centerPinImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(mapView.snp.centerY)
            make.height.width.equalTo(40)
        }
        centerPinImageView.image = UIImage(named: "pin_40x40")
    }
    
    func renderCenterPinTextField() {
        mapView.addSubview(centerPinTextField)
        centerPinTextField.snp.makeConstraints { make in
            make.bottom.equalTo(centerPinImageView.snp.top).offset(-3)
            make.centerX.equalTo(centerPinImageView.snp.centerX)
            make.height.equalTo(20)
        }
        centerPinTextField.textInsets = UIEdgeInsets(top: 1, left: 2, bottom: 2, right: 2)
        centerPinTextField.backgroundColor = .unpauseBlack
        centerPinTextField.textColor = .unpauseWhite
        centerPinTextField.font = .systemFont(ofSize: 12, weight: .regular)
        centerPinTextField.layer.cornerRadius = 6
        centerPinTextField.textAlignment = .center
        centerPinTextField.attributedPlaceholder = NSAttributedString(string: "Location name",
                                                                      attributes: [NSAttributedString.Key.foregroundColor: UIColor.unpauseLightGray])
        centerPinTextField.autocorrectionType = .no
        centerPinTextField.autocapitalizationType = .sentences
        centerPinTextField.minimumFontSize = 12
    }
    
    func renderAddCompanyLocationButton() {
        addCompanyLocationContainerView.addSubview(addCompanyLocationButton)
        addCompanyLocationButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(15)
            make.left.equalToSuperview().offset(30)
            make.right.equalToSuperview().inset(30)
            make.bottom.equalToSuperview().inset(30)
        }
        addCompanyLocationButton.setTitle("Add company location", for: .normal)
        addCompanyLocationButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        addCompanyLocationButton.layer.cornerRadius = 25
        addCompanyLocationButton.backgroundColor = .unpauseGreen
    }
}
