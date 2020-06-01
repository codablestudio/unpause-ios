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
    }
    
    private func setUpObservables() {
        
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
