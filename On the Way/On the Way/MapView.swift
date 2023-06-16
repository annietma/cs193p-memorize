//
//  MapView.swift
//  On the Way
//
//  Created by Annie Ma on 5/27/23.
//

// MapView.swift
import SwiftUI
import MapKit

struct MapView: UIViewRepresentable {
    @Binding var map: MapModel
    var viewModel: MapViewModel
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.showsUserLocation = true
        mapView.delegate = context.coordinator
        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        uiView.removeOverlays(uiView.overlays)
        uiView.removeAnnotations(uiView.annotations)
        uiView.setRegion(map.region, animated: true)
        if let route = viewModel.route {
            uiView.addOverlay(route.polyline)
            // Add a destination annotation
            let destinationAnnotation = MKPointAnnotation()
            destinationAnnotation.coordinate = route.polyline.points()[route.polyline.pointCount - 1].coordinate
            uiView.addAnnotation(destinationAnnotation)
        }
        for gasStation in viewModel.gasStations {
            let gasStationAnnotation = MKPointAnnotation()
            gasStationAnnotation.coordinate = gasStation.placemark.coordinate
            uiView.addAnnotation(gasStationAnnotation)
        }
        // Add the closest gas station as an annotation
        if let closestGasStation = viewModel.closestGasStation {
            let closestAnnotation = MKPointAnnotation()
            closestAnnotation.coordinate = closestGasStation.placemark.coordinate
            uiView.addAnnotation(closestAnnotation)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapView
        init(_ parent: MapView) {
            self.parent = parent
        }
        
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let route = parent.viewModel.route, overlay is MKPolyline {
                let lineRenderer = MKPolylineRenderer(polyline: route.polyline)
                lineRenderer.strokeColor = UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1)
                lineRenderer.lineWidth = 5
                return lineRenderer
            }
            return MKOverlayRenderer(overlay: overlay)
        }
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            if annotation is MKPointAnnotation {
                var annotationView: MKAnnotationView!
                if let closestGasStation = parent.viewModel.closestGasStation,
                   closestGasStation.placemark.coordinate.latitude == annotation.coordinate.latitude &&
                    closestGasStation.placemark.coordinate.longitude == annotation.coordinate.longitude {
                    let identifier = "ClosestGasStationAnnotationView"
                    annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
                    if annotationView == nil {
                        annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                        annotationView.image = UIImage(named: "fuelpump.circle.fill")
                    } else {
                        annotationView.annotation = annotation
                    }
                }
                
                else if let _ = parent.viewModel.gasStations.first(where: {
                    $0.placemark.coordinate.latitude == annotation.coordinate.latitude &&
                    $0.placemark.coordinate.longitude == annotation.coordinate.longitude }) {
                    // This is a gas station
                    let identifier = "GasStationAnnotationView"
                    annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
                    if annotationView == nil {
                        annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                        annotationView.image = UIImage(systemName: "fuelpump.circle.fill")
                    } else {
                        annotationView.annotation = annotation
                    }
                } else {
                    // This is the destination
                    let identifier = "DestinationAnnotationView"
                    annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
                    if annotationView == nil {
                        annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                        annotationView.image = UIImage(named: "mappin.circle.fill")
                    } else {
                        annotationView.annotation = annotation
                    }
                }
                return annotationView
            }
            return nil
        }
        
    }
}
