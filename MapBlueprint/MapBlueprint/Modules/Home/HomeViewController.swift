//
//  HomeViewController.swift
//  MapBlueprint
//
//  Created by Alex Shirazi on 1/31/24.
//

import Foundation
import UIKit
import CoreLocation
import MapKit

protocol HomeViewControllerProtocol: AnyObject {
    
}

class HomeViewController: UIViewController, HomeViewControllerProtocol, CLLocationManagerDelegate, MKMapViewDelegate {
    let eventHandler: HomeEventHandlerProtocol
    var mapView = MKMapView()
    let locationManager = CLLocationManager()

    init(eventHandler: HomeEventHandlerProtocol) {
        self.eventHandler = eventHandler
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupMapView()
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        mapView.showsUserLocation = true
 
        let initialLocation = CLLocation(latitude: 37.427475, longitude: -122.169716)
        centerMapOnLocation(location: initialLocation)
    }
    private func setupMapView() {
         mapView = MKMapView(frame: view.bounds)
         view.addSubview(mapView)
         mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
         mapView.delegate = self
         mapView.layoutMargins = UIEdgeInsets(top: -100, left: 0, bottom: -100, right: 0)
         mapView.showsUserLocation = true
     }
    func centerMapOnLocation(location: CLLocation) {
        let regionRadius: CLLocationDistance = 1000
        let coordinateRegion = MKCoordinateRegion(
            center: location.coordinate,
            latitudinalMeters: regionRadius,
            longitudinalMeters: regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
    }
}
