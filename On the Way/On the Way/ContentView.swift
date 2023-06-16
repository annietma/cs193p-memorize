//  ContentView.swift
//  On the Way
//
//  Created by Annie Ma on 5/26/23.
//

import Foundation
import SwiftUI
import UIKit
import MapKit

struct ContentView: View {
    @ObservedObject var mapViewModel = MapViewModel()
    @State private var searchResults: [MKMapItem] = []
    @State private var showingSettings = false
    @State private var isMenuButtonPressed = false
    @State private var isMapButtonPressed = false
    @Environment(\.managedObjectContext) var managedObjectContext
    @FetchRequest(
        entity: Destination.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Destination.timestamp, ascending: false)],
        predicate: nil
    ) var recentDestinations: FetchedResults<Destination>
    @State var recentDestinationsMK: [MKMapItem] = []
    @AppStorage("showMapsButton") var showMapsButton: Bool = true
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            MapView(map: $mapViewModel.map, viewModel: mapViewModel)
                .ignoresSafeArea()
            
            VStack(spacing: 10) {
                Button(action: {
                    showingSettings.toggle()
                }) {
                    Image(systemName: "line.horizontal.3")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
                .modifier(MenuButton())
                .scaleEffect(isMenuButtonPressed ? 1.2 : 1.0)
                .animation(.default)
                .onLongPressGesture(minimumDuration: .infinity, maximumDistance: .infinity, pressing: { pressing in
                    isMenuButtonPressed = pressing
                }, perform: { })
                .padding(.horizontal)
                .sheet(isPresented: $showingSettings) {
                    SettingsView()
                }
                
                if showMapsButton {
                    Button(action: {
                        UIApplication.shared.open(URL(string: "maps://")!)
                    }) {
                        MapShape()
                            .fill(Color.black)
                        
                            .aspectRatio(contentMode: .fit)
                            .padding()
                            .frame(width: 50, height: 50)
                        
                    }
                    .modifier(MenuButton())
                    .scaleEffect(isMapButtonPressed ? 1.2 : 1.0)
                    .animation(.default)
                    .onLongPressGesture(minimumDuration: .infinity, maximumDistance: .infinity, pressing: { pressing in
                        isMapButtonPressed = pressing
                    }, perform: { })
                    .padding(.horizontal)
                }
            }
            .padding(.top)
            
            GeometryReader { geometry in
                SearchOverlay(searchResults: $mapViewModel.searchResults, recentDestinationsMK: $recentDestinationsMK) { destination in
                    mapViewModel.generateRoute(to: destination)
                }
            }
        }
        .onReceive(mapViewModel.$destinationToBeSaved) { destination in
            if let destination = destination {
                saveDestinationToCoreData(destination: destination)
            }
        }
        .onAppear(perform: { getRecentDestinationsMK() })
    }
    
    func saveDestinationToCoreData(destination: MKMapItem) {
        
        if recentDestinations.count >= 5 {
            removeLeastRecentDestination()
        }
        
        let newDestination = Destination(context: managedObjectContext)
        newDestination.name = destination.name ?? ""
        newDestination.latitude = destination.placemark.coordinate.latitude
        newDestination.longitude = destination.placemark.coordinate.longitude
        newDestination.timestamp = Date()
        newDestination.subThoroughfare = destination.placemark.subThoroughfare
        newDestination.thoroughfare = destination.placemark.thoroughfare
        newDestination.locality = destination.placemark.locality
        newDestination.administrativeArea = destination.placemark.administrativeArea
        newDestination.postalCode = destination.placemark.postalCode
        newDestination.country = destination.placemark.country
        
        do {
            try managedObjectContext.save()
        } catch {
            print("Could not save to CoreData: \(error)")
        }
        
        getRecentDestinationsMK()
    }
    
    func getRecentDestinationsMK() -> Void {
        var temp: [MKMapItem] = []
        
        for dest in recentDestinations {
            let coordinate = CLLocationCoordinate2D(latitude: dest.latitude, longitude: dest.longitude)
            let placemark = MKPlacemark(coordinate: coordinate,
                                        addressDictionary: [
                                            "Street": dest.thoroughfare ?? "",
                                            "City": dest.locality ?? "",
                                            "State": dest.administrativeArea ?? "",
                                            "PostalCode": dest.postalCode ?? "",
                                            "Country": dest.country ?? ""
                                        ])
            
            
            let mapItem = MKMapItem(placemark: placemark)
            mapItem.name = dest.name
            temp.append(mapItem)
        }
        
        recentDestinationsMK = temp
    }
    
    func removeLeastRecentDestination() {
        guard let leastRecentDestination = recentDestinations.last else { return }
        
        managedObjectContext.delete(leastRecentDestination)
        
        do {
            try managedObjectContext.save()
        } catch {
            print("Could not remove from CoreData: \(error)")
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct MenuButton: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(width: 20, height: 20)
            .foregroundColor(.black)
            .padding()
            .background(Color.white)
            .cornerRadius(10)
            .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 10)
    }
}

struct MapShape: Shape {
    func path(in rect: CGRect) -> Path {
        Path { path in
            path.move(to: CGPoint(x: rect.midX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
            path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.midY))
            path.addLine(to: CGPoint(x: rect.midX, y: rect.minY))
        }
    }
}
