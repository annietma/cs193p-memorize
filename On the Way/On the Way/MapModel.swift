//
//  Model.swift
//  On the Way
//
//  Created by Annie Ma on 5/27/23.
//

import SwiftUI
import MapKit

struct MapModel {
    var region: MKCoordinateRegion
    
    init() {
        self.region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 34.011_286, longitude: -116.166_868),
            span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
        )
    }
}
