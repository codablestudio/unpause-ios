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
    
    private let addCompanyLocationContainerView = UIView()
    private let addCompanyLocationButton = UIButton()
    
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
        renderAddCompanyLocationButton()
    }
    
    private func setUpObservables() {
        
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
