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
    var searchBar =  UISearchBar()
    var searchBarBottomConstraint = NSLayoutConstraint()
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
        setupMapView()
        setupRouteInfoUI()
    
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
    

    func setupRouteInfoUI() {
        
        let guide = view.safeAreaLayoutGuide
        
        searchBar = UISearchBar()
        searchBar.placeholder = "Enter destination..."
        searchBar.delegate = self
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.showsCancelButton = true
        searchBarBottomConstraint = searchBar.bottomAnchor.constraint(equalTo: guide.bottomAnchor, constant: -(navigationController?.toolbar.frame.size.height ?? 0))
        
        distanceLabel.translatesAutoresizingMaskIntoConstraints = false
        distanceLabel.textAlignment = .center
        distanceLabel.text = "Distance"
        distanceLabel.backgroundColor = .systemBackground
        distanceLabel.isHidden = true
        
     
        estimatedTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        estimatedTimeLabel.textAlignment = .center
        estimatedTimeLabel.text = "Estimated Time"
        estimatedTimeLabel.backgroundColor = .systemBackground
        estimatedTimeLabel.isHidden = true
        
        endRouteButton = UIButton(type: .system)
        endRouteButton.translatesAutoresizingMaskIntoConstraints = false
        endRouteButton.setTitle("End Route", for: .normal)
        endRouteButton.backgroundColor = .black
        endRouteButton.setTitleColor(.label, for: .normal)
        endRouteButton.addTarget(self, action: #selector(endCurrentRoute), for: .touchUpInside)
        endRouteButton.isHidden = true
        
        view.addSubview(searchBar)
        view.addSubview(distanceLabel)
        view.addSubview(estimatedTimeLabel)
        view.addSubview(endRouteButton)
        

        
        NSLayoutConstraint.activate([
            
            
            searchBar.leadingAnchor.constraint(equalTo: guide.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: guide.trailingAnchor),
            searchBarBottomConstraint,
            searchBar.heightAnchor.constraint(equalToConstant: 50),
            
            
            distanceLabel.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 2),
            distanceLabel.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 12),
            distanceLabel.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -12),
            
            estimatedTimeLabel.topAnchor.constraint(equalTo: distanceLabel.bottomAnchor, constant: 0),
            estimatedTimeLabel.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 12),
            estimatedTimeLabel.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -12),
            
            endRouteButton.topAnchor.constraint(equalTo: estimatedTimeLabel.bottomAnchor, constant: 2),
            endRouteButton.centerXAnchor.constraint(equalTo: guide.centerXAnchor),
            endRouteButton.heightAnchor.constraint(equalToConstant: 44),
            endRouteButton.widthAnchor.constraint(equalToConstant: 100)
        ])
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
            let safeAreaBottomInset = view.safeAreaInsets.bottom
            let offset = keyboardHeight - safeAreaBottomInset
            
            UIView.animate(withDuration: 0.3) {
                self.searchBarBottomConstraint.constant = -offset
                self.view.layoutIfNeeded()
            }
        }
        
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        UIView.animate(withDuration: 0.3) {
            self.searchBarBottomConstraint.constant = -(self.tabBarController?.tabBar.frame.size.height ?? 0)
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

