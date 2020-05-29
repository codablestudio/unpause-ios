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
    private let segmentedControl = UISegmentedControl()
    
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        hideTabBar()
    }
    
    private func render() {
        renderMapView()
        renderSegmentedControl()
    }
    
    private func setUpObservables() {
        segmentedControl.rx.selectedSegmentIndex
        .subscribe(onNext: { [weak self] selectedIndex in
            guard let `self` = self else { return }
            if selectedIndex == 0 {
                self.mapView.mapType = .standard
            } else if selectedIndex == 1 {
                self.mapView.mapType = .mutedStandard
            } else if selectedIndex == 2 {
                self.mapView.mapType = .satellite
            }
        }).disposed(by: disposeBag)
    }
    
    private func hideTabBar() {
        tabBarController?.tabBar.isHidden = true
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
    
    func renderSegmentedControl() {
        view.addSubview(segmentedControl)
        
        segmentedControl.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
            make.centerX.equalToSuperview()
        }
        segmentedControl.insertSegment(withTitle: "Map", at: 0, animated: true)
        segmentedControl.insertSegment(withTitle: "Transit", at: 1, animated: true)
        segmentedControl.insertSegment(withTitle: "Satellite", at: 2, animated: true)
        segmentedControl.selectedSegmentIndex = 0
    }
}
