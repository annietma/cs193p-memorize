//
//  MapViewModel.swift
//  On the Way
//
//  Created by Annie Ma on 5/27/23.
//
// MapViewModel.swift
import SwiftUI
import Combine
import CoreLocation
import MapKit
import CoreData


class MapViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var map = MapModel()
    @Published var userLocation: CLLocation?
    @Published var destination = ""
    @Published var directions: MKDirections?
    @Published var route: MKRoute?
    @Published var searchResults = [MKMapItem]()
    private let locationManager = CLLocationManager()
    @EnvironmentObject var settings: Settings
    
    override init() {
        super.init()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        if userLocation == nil {
            userLocation = location
            map.region = MKCoordinateRegion(center: location.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2))
            locationManager.stopUpdatingLocation()
        }
    }
    @Published var gasStations = [MKMapItem]()
    
    func searchGasStations(region: MKCoordinateRegion) {
        gasStations = []
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = "Gas Station"
        request.region = region
        
        let search = MKLocalSearch(request: request)
        search.start { (response, error) in
            guard let response = response else {
                print("Error: \(error?.localizedDescription ?? "Unknown error").")
                return
            }
            
            DispatchQueue.main.async {
                self.gasStations.append(contentsOf: response.mapItems)
            }
        }
        
    }
    
    @Published var destinationToBeSaved: MKMapItem?
    
    func generateRoute(to destination: MKMapItem) {
        self.destinationToBeSaved = destination
        
        guard let userLocation = userLocation else {
            print("User location is not available")
            return
        }
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: userLocation.coordinate, addressDictionary: nil))
        request.destination = destination
        request.transportType = .automobile
        
        directions?.cancel()
        
        directions = MKDirections(request: request)
        directions?.calculate { [weak self] (response, error) in
            if let error = error {
                print("Error calculating directions: \(error)")
                return
            }
            
            guard let route = response?.routes.first else {
                print("No routes found")
                return
            }
            
            DispatchQueue.main.async {
                self?.route = route
                
                let currentRegion = MKCoordinateRegion(center: userLocation.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2))
                self?.searchGasStations(region: currentRegion)
                
                let destinationRegion = MKCoordinateRegion(center: destination.placemark.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2))
                self?.searchGasStations(region: destinationRegion)
                
                let midPoint = CLLocationCoordinate2D(
                    latitude: (userLocation.coordinate.latitude + destination.placemark.coordinate.latitude) / 2,
                    longitude: (userLocation.coordinate.longitude + destination.placemark.coordinate.longitude) / 2
                )
                let span = MKCoordinateSpan(
                    latitudeDelta: abs(userLocation.coordinate.latitude - destination.placemark.coordinate.latitude),
                    longitudeDelta: abs(userLocation.coordinate.longitude - destination.placemark.coordinate.longitude)
                )
                let midRegion = MKCoordinateRegion(center: midPoint, span: span)
                self?.searchGasStations(region: midRegion)
                
                DispatchQueue.global().async {
                    while self?.gasStations.isEmpty ?? true {
                        sleep(1)
                    }
                    DispatchQueue.main.async {
                        self?.removeDuplicateGasStations()
                        self?.findClosestGasStation()
                    }
                }
            }
        }
    }
    
    func removeDuplicateGasStations() {
        var uniqueGasStations = [MKMapItem]()
        for station in gasStations {
            if !uniqueGasStations.contains(where: { $0.placemark.coordinate.latitude == station.placemark.coordinate.latitude && $0.placemark.coordinate.longitude == station.placemark.coordinate.longitude }) {
                uniqueGasStations.append(station)
            }
        }
        gasStations = uniqueGasStations
    }
    
    @Published var closestGasStation: MKMapItem?
    
    func findClosestGasStation() {
        guard let route = route else { return }
        
        var closestDistance = Double.infinity
        var closestStation: MKMapItem?
        
        let points = route.polyline.points()
        for station in gasStations {
            let stationLocation = CLLocation(latitude: station.placemark.coordinate.latitude, longitude: station.placemark.coordinate.longitude)
            for i in 0..<route.polyline.pointCount {
                let pointLocation = CLLocation(latitude: points[i].coordinate.latitude, longitude: points[i].coordinate.longitude)
                let distance = stationLocation.distance(from: pointLocation)
                if distance < closestDistance {
                    closestDistance = distance
                    closestStation = station
                }
            }
        }
        
        if let closest = closestStation {
            gasStations.removeAll(where: { $0.placemark.coordinate.latitude == closest.placemark.coordinate.latitude && $0.placemark.coordinate.longitude == closest.placemark.coordinate.longitude })
            closestGasStation = closest
        }
    }
    
    
    
}
