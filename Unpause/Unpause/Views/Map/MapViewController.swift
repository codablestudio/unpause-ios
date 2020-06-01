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

class MapViewController: UIViewController, UIGestureRecognizerDelegate {
    
    private let mapViewModel: MapViewModelProtocol
    private let disposeBag = DisposeBag()
    
    private let mapView = MKMapView()
    
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
        addGestureRecognizer()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        hideTabBar()
    }
    
    private func render() {
        renderMapView()
    }
    
    private func setUpObservables() {
        
    }
    
    private func addGestureRecognizer() {
        mapView.rx.tapGesture().when(.recognized)
            .subscribe(onNext: { [weak self] tapGesture in
                guard let `self` = self else { return }
                let location = tapGesture.location(in: self.mapView)
                let coordinate = self.mapView.convert(location, toCoordinateFrom: self.mapView)
                
                let annotation = MKPointAnnotation()
                annotation.coordinate = coordinate
                self.mapView.addAnnotation(annotation)
            }).disposed(by: disposeBag)
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
}
