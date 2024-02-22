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

class HomeViewController: UIViewController, HomeViewControllerProtocol, CLLocationManagerDelegate, MKMapViewDelegate, UISearchBarDelegate {
    let eventHandler: HomeEventHandlerProtocol
    var mapView = MKMapView()
    let locationManager = CLLocationManager()
    
    var routeInfoContainerView = UIView()
    var searchBar =  UISearchBar()
    var routeInfoContainerViewBottomConstraint = NSLayoutConstraint()
    var distanceLabel = UILabel()
    var estimatedTimeLabel = UILabel()
    var endRouteButton = UIButton()

    init(eventHandler: HomeEventHandlerProtocol) {
        self.eventHandler = eventHandler
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    
    }

    private func setupMapView() {
        mapView = MKMapView(frame: view.bounds)
         view.addSubview(mapView)
         mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
         mapView.delegate = self
         mapView.showsUserLocation = true

        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        } else {
           print("Location Services not available")
        }
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        mapView.showsUserLocation = true
            
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
     }
    
    func centerMapOnLocation(location: CLLocation) {
        let regionRadius: CLLocationDistance = 1000
        let coordinateRegion = MKCoordinateRegion(
            center: location.coordinate,
            latitudinalMeters: regionRadius,
            longitudinalMeters: regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    

    private func setup() {
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.delegate = self
        mapView.showsUserLocation = true
        view.addSubview(mapView)
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        } else {
            print("Location services are not available.")
        }
        
        routeInfoContainerView.translatesAutoresizingMaskIntoConstraints = false
        routeInfoContainerViewBottomConstraint = routeInfoContainerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        routeInfoContainerView.backgroundColor = .systemBackground

        view.addSubview(routeInfoContainerView)
        
        let blurEffect = UIBlurEffect(style: .systemMaterial)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.translatesAutoresizingMaskIntoConstraints = false
        routeInfoContainerView.addSubview(blurEffectView)
        
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.placeholder = "Enter destination..."
        searchBar.delegate = self
        searchBar.showsCancelButton = true
        routeInfoContainerView.addSubview(searchBar)
        
        distanceLabel.translatesAutoresizingMaskIntoConstraints = false
        distanceLabel.textAlignment = .center
        distanceLabel.text = "Distance"
        distanceLabel.backgroundColor = .systemBackground
        distanceLabel.isHidden = true
        routeInfoContainerView.addSubview(distanceLabel)
        
        estimatedTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        estimatedTimeLabel.textAlignment = .center
        estimatedTimeLabel.text = "Estimated Time"
        estimatedTimeLabel.backgroundColor = .systemBackground
        estimatedTimeLabel.isHidden = true
        routeInfoContainerView.addSubview(estimatedTimeLabel)
        
        endRouteButton.translatesAutoresizingMaskIntoConstraints = false
        endRouteButton.setTitle("End Route", for: .normal)
        endRouteButton.backgroundColor = .red
        endRouteButton.setTitleColor(.label, for: .normal)
        endRouteButton.addTarget(self, action: #selector(endCurrentRoute), for: .touchUpInside)
        endRouteButton.isHidden = true
        routeInfoContainerView.addSubview(endRouteButton)
        
        NSLayoutConstraint.activate([

            
            routeInfoContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            routeInfoContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            routeInfoContainerViewBottomConstraint,
            
            blurEffectView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            blurEffectView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            blurEffectView.topAnchor.constraint(equalTo: view.topAnchor),
            blurEffectView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: -50),

            
            searchBar.topAnchor.constraint(equalTo: routeInfoContainerView.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: routeInfoContainerView.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: routeInfoContainerView.trailingAnchor),
            searchBar.heightAnchor.constraint(equalToConstant: 50),
            
            distanceLabel.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 8),
            distanceLabel.leadingAnchor.constraint(equalTo: routeInfoContainerView.leadingAnchor, constant: 12),
            distanceLabel.trailingAnchor.constraint(equalTo: routeInfoContainerView.trailingAnchor, constant: -12),
            
            estimatedTimeLabel.topAnchor.constraint(equalTo: distanceLabel.bottomAnchor, constant: 8),
            estimatedTimeLabel.leadingAnchor.constraint(equalTo: routeInfoContainerView.leadingAnchor, constant: 12),
            estimatedTimeLabel.trailingAnchor.constraint(equalTo: routeInfoContainerView.trailingAnchor, constant: -12),
            
            endRouteButton.topAnchor.constraint(equalTo: estimatedTimeLabel.bottomAnchor, constant: 8),
            endRouteButton.centerXAnchor.constraint(equalTo: routeInfoContainerView.centerXAnchor),
            endRouteButton.heightAnchor.constraint(equalToConstant: 44),
            endRouteButton.widthAnchor.constraint(equalToConstant: 100),
            endRouteButton.bottomAnchor.constraint(equalTo: routeInfoContainerView.bottomAnchor, constant: -20),
            
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: routeInfoContainerView.topAnchor)
        ])
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }


    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        
        if let destinationString = searchBar.text, !destinationString.isEmpty {
            let geocoder = CLGeocoder()
            geocoder.geocodeAddressString(destinationString) { [weak self] (placemarks, error) in
                guard let strongSelf = self else { return }
                
                if let error = error {
                    print("Geocoding error: \(error.localizedDescription)")
                    return
                }
                
                guard let placemark = placemarks?.first, let destinationLocation = placemark.location else {
                    print("No valid locations found.")
                    return
                }
                
                // Now using the geocoded destination for routing
                if let userLocation = strongSelf.locationManager.location {
                    strongSelf.showRouteOnMap(pickupCoordinate: userLocation.coordinate, destinationCoordinate: destinationLocation.coordinate)
                } else {
                    print("User location is not available.")
                }
            }
        }
    }


    func getCoordinateFrom(address: String, completion: @escaping (_ coordinate: CLLocationCoordinate2D?, _ error: Error?) -> ()) {
        CLGeocoder().geocodeAddressString(address) { placemarks, error in
            completion(placemarks?.first?.location?.coordinate, error)
        }
    }
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let keyboardHeight = keyboardSize.height
            UIView.animate(withDuration: 0.3) {
                self.routeInfoContainerViewBottomConstraint.constant = -keyboardHeight + self.view.safeAreaInsets.bottom
                self.view.layoutIfNeeded()
            }
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        UIView.animate(withDuration: 0.3) {
            self.routeInfoContainerViewBottomConstraint.constant = 0
            self.view.layoutIfNeeded()
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = nil
        searchBar.resignFirstResponder()
    }
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            manager.startUpdatingLocation()
            mapView.showsUserLocation = true
        } else {
          print("Accessed Denied")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            let region = MKCoordinateRegion(center: center, latitudinalMeters: 1000, longitudinalMeters: 1000)
            mapView.setRegion(region, animated: true)
        }
    }
    @objc func endCurrentRoute() {
        mapView.overlays.forEach { if $0 is MKPolyline { mapView.removeOverlay($0) } }
        if let userLocation = locationManager.location {
            let region = MKCoordinateRegion(center: userLocation.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
            mapView.setRegion(region, animated: true)
            endRouteButton.isHidden = true
            distanceLabel.isHidden = true
            estimatedTimeLabel.isHidden = true
        }
    }
    func showRouteOnMap(pickupCoordinate: CLLocationCoordinate2D, destinationCoordinate: CLLocationCoordinate2D) {
        let pickupPlacemark = MKPlacemark(coordinate: pickupCoordinate)
        let destinationPlacemark = MKPlacemark(coordinate: destinationCoordinate)
        
        let pickupItem = MKMapItem(placemark: pickupPlacemark)
        let destinationItem = MKMapItem(placemark: destinationPlacemark)
        
        let directionRequest = MKDirections.Request()
        directionRequest.source = pickupItem
        directionRequest.destination = destinationItem
        directionRequest.transportType = .automobile
        
        self.searchBar.text = nil
        
        let directions = MKDirections(request: directionRequest)
        directions.calculate { (response, error) in
            if let error = error {
                print("Error calculating directions: \(error.localizedDescription)")
                return
            }
            guard let response = response, let route = response.routes.first else {
                print("No routes found.")
                return
            }
            
            self.mapView.addOverlay(route.polyline, level: .aboveRoads)
            let rect = route.polyline.boundingMapRect
            self.mapView.setRegion(MKCoordinateRegion(rect), animated: true)

            // Update UI with route details
            let distance = route.distance / 1609.34 // Convert meters to miles
            let estimatedTravelTime = route.expectedTravelTime / 60 // Convert seconds to minutes

            self.distanceLabel.text = String(format: "%.2f miles", distance)
            self.estimatedTimeLabel.text = String(format: "%.0f minutes", estimatedTravelTime)
            self.distanceLabel.isHidden = false
            self.estimatedTimeLabel.isHidden = false
            self.endRouteButton.isHidden = false
            
        }

    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolyline {
            let renderer = MKPolylineRenderer(overlay: overlay)
            renderer.strokeColor = UIColor.blue
            renderer.lineWidth = 4.0
            return renderer
        }
        return MKOverlayRenderer()
    }
}

