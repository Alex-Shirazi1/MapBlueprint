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
    
    var startRouteButton = UIButton()
    var endRouteButton = UIButton()
    var currentLocationButton = UIButton()
    
    
    
    var startingLocation: CLLocation?
    var destinationLocation: CLLocation?
    
    var waypoints: [CLLocation] = []
    var currentWaypointIndex: Int = 0

    
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
    
        centerOnCurrentLocation()
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
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
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
        
        startRouteButton.setTitle("Start", for: .normal)
        startRouteButton.translatesAutoresizingMaskIntoConstraints = false
        startRouteButton.addTarget(self, action: #selector(startRoute), for: .touchUpInside)
        startRouteButton.backgroundColor = .systemBlue
        startRouteButton.isHidden = true
        routeInfoContainerView.addSubview(startRouteButton)
        
        endRouteButton.translatesAutoresizingMaskIntoConstraints = false
        endRouteButton.setTitle("End Route", for: .normal)
        endRouteButton.backgroundColor = .red
        endRouteButton.setTitleColor(.label, for: .normal)
        endRouteButton.addTarget(self, action: #selector(endCurrentRoute), for: .touchUpInside)
        endRouteButton.isHidden = true
        routeInfoContainerView.addSubview(endRouteButton)
        
        currentLocationButton.setImage(UIImage(systemName: "location.fill"), for: .normal)
        currentLocationButton.backgroundColor = .systemBackground
        currentLocationButton.layer.cornerRadius = 25
        currentLocationButton.clipsToBounds = true
        currentLocationButton.addTarget(self, action: #selector(centerOnCurrentLocation), for: .touchUpInside)

        mapView.addSubview(currentLocationButton)
        currentLocationButton.translatesAutoresizingMaskIntoConstraints = false
        
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
            
            startRouteButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
             startRouteButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
             startRouteButton.widthAnchor.constraint(equalToConstant: 100),
             startRouteButton.heightAnchor.constraint(equalToConstant: 50),
            
            endRouteButton.topAnchor.constraint(equalTo: estimatedTimeLabel.bottomAnchor, constant: 8),
            endRouteButton.centerXAnchor.constraint(equalTo: routeInfoContainerView.centerXAnchor),
            endRouteButton.heightAnchor.constraint(equalToConstant: 44),
            endRouteButton.widthAnchor.constraint(equalToConstant: 100),
            endRouteButton.bottomAnchor.constraint(equalTo: routeInfoContainerView.bottomAnchor, constant: -20),
            
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: routeInfoContainerView.topAnchor),
            
            currentLocationButton.leftAnchor.constraint(equalTo: mapView.leftAnchor, constant: 20),
            currentLocationButton.bottomAnchor.constraint(equalTo: mapView.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            currentLocationButton.widthAnchor.constraint(equalToConstant: 50),
            currentLocationButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
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

    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolyline {
            let renderer = MKPolylineRenderer(overlay: overlay)
            renderer.strokeColor = UIColor.blue
            renderer.lineWidth = 4.0
            return renderer
        }
        return MKOverlayRenderer()
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "UserLocation")
            if annotationView == nil {
                annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "UserLocation")
                annotationView?.canShowCallout = false
            }
            
            annotationView?.image = UIImage(systemName: "location.fill")
            return annotationView
        }
        
        return nil
    }

    
    func getCoordinateFrom(address: String, completion: @escaping (_ coordinate: CLLocationCoordinate2D?, _ error: Error?) -> ()) {
        CLGeocoder().geocodeAddressString(address) { placemarks, error in
            completion(placemarks?.first?.location?.coordinate, error)
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
        guard let currentLocation = locations.first else {
            return
        }
        
        print("DEBUG Locations \(locations)")
        if let nextRoutePoint = findNextRoutePoint(after: currentLocation) {
            let bearing = calculateBearing(to: nextRoutePoint, from: currentLocation)
            rotateArrow(to: bearing)
        }
    }

    func rotateArrow(to bearing: CLLocationDirection) {
        if let arrowView = mapView.view(for: mapView.userLocation) {
            let rotationRadians = degreesToRadians(degrees: bearing)
            UIView.animate(withDuration: 0.5) {
                arrowView.transform = CGAffineTransform(rotationAngle: CGFloat(rotationRadians))
            }
        }
    }

    func findNextRoutePoint(after currentLocation: CLLocation) -> CLLocation? {
        guard !waypoints.isEmpty else { return nil }

        let sortedWaypoints = waypoints.enumerated().min(by: { (first, second) -> Bool in
            let firstDistance = currentLocation.distance(from: first.element)
            let secondDistance = currentLocation.distance(from: second.element)
            return firstDistance < secondDistance
        })

        guard let nextIndex = sortedWaypoints?.offset, nextIndex + 1 < waypoints.count else { return nil }
        currentWaypointIndex = nextIndex
        return waypoints[nextIndex + 1]
    }

    func calculateBearing(to destination: CLLocation, from origin: CLLocation) -> CLLocationDirection {
        let lat1 = degreesToRadians(degrees: origin.coordinate.latitude)
        let lon1 = degreesToRadians(degrees: origin.coordinate.longitude)
        let lat2 = degreesToRadians(degrees: destination.coordinate.latitude)
        let lon2 = degreesToRadians(degrees: destination.coordinate.longitude)
        let deltaLon = lon2 - lon1
        let y = sin(deltaLon) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(deltaLon)
        let radiansBearing = atan2(y, x)
        return radiansToDegrees(radians: radiansBearing)
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
        
        startingLocation = CLLocation(latitude: pickupCoordinate.latitude, longitude: pickupCoordinate.longitude)
        destinationLocation = CLLocation(latitude: destinationCoordinate.latitude, longitude: destinationCoordinate.longitude)
        
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
            if let route = response.routes.first {
                var coordinates = [CLLocationCoordinate2D]()
                let points = route.polyline.points()
                for i in 0..<route.polyline.pointCount {
                    coordinates.append(points[i].coordinate)
                }
                
                self.waypoints = coordinates.map { CLLocation(latitude: $0.latitude, longitude: $0.longitude) }
            }

            self.mapView.setRegion(MKCoordinateRegion(rect), animated: true)

            // Update UI with route details
            let distance = route.distance / 1609.34 // Convert meters to miles
            let estimatedTravelTime = route.expectedTravelTime / 60 // Convert seconds to minutes

            self.distanceLabel.text = String(format: "%.2f miles", distance)
            self.estimatedTimeLabel.text = String(format: "%.0f minutes", estimatedTravelTime)
            self.distanceLabel.isHidden = false
            self.estimatedTimeLabel.isHidden = false
            self.startRouteButton.isHidden = false
            self.endRouteButton.isHidden = true
            
        }

    }

    @objc private func startRoute() {
        print("DEBUG WAYPOINTS \(waypoints)")
        guard let startingPoint = startingLocation?.coordinate else { return }
        
        let zoomRegion = MKCoordinateRegion(center: startingPoint, latitudinalMeters: 500, longitudinalMeters: 500)
        mapView.setRegion(zoomRegion, animated: true)
        
        startRouteButton.isHidden = true
        endRouteButton.isHidden = false
        distanceLabel.isHidden = false
        estimatedTimeLabel.isHidden = false
    }

    func calculateInitialRouteHeading() -> CLLocationDirection? {
        guard let startingLocation = self.startingLocation,
              let destinationLocation = self.destinationLocation else {
            return nil
        }

        return calculateBearing(to: destinationLocation, from: startingLocation)
    }
    
    @objc private func endCurrentRoute() {
        mapView.overlays.forEach { if $0 is MKPolyline { mapView.removeOverlay($0) } }
        if let userLocation = locationManager.location {
            let region = MKCoordinateRegion(center: userLocation.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
            mapView.setRegion(region, animated: true)
            endRouteButton.isHidden = true
            distanceLabel.isHidden = true
            estimatedTimeLabel.isHidden = true
            searchBar.isHidden = false
        }
    }
    @objc private func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let keyboardHeight = keyboardSize.height
            UIView.animate(withDuration: 0.3) {
                self.routeInfoContainerViewBottomConstraint.constant = -keyboardHeight + self.view.safeAreaInsets.bottom
                self.view.layoutIfNeeded()
            }
        }
    }
    @objc private func keyboardWillHide(notification: NSNotification) {
        UIView.animate(withDuration: 0.3) {
            self.routeInfoContainerViewBottomConstraint.constant = 0
            self.view.layoutIfNeeded()
        }
    }
    @objc private func centerOnCurrentLocation() {
        if let currentLocation = locationManager.location {
            let region = MKCoordinateRegion(center: currentLocation.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
            mapView.setRegion(region, animated: true)
        }
    }
    private func degreesToRadians(degrees: Double) -> Double {
        return degrees * .pi / 180
    }
    private func radiansToDegrees(radians: Double) -> Double {
        return radians * 180 / .pi
    }
}

