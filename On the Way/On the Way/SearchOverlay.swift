//
//  SearchOverlay.swift
//  On the Way
//
//  Created by Annie Ma on 5/27/23.
//

import SwiftUI
import MapKit

struct SearchOverlay: View {
    @Binding var searchResults: [MKMapItem]
    @Binding var recentDestinationsMK: [MKMapItem]
    var onSelectDestination: (MKMapItem) -> Void = { _ in }
    
    let offsetBottom: CGFloat = 650
    let offsetMiddle: CGFloat = 350
    let offsetTop: CGFloat = 20
    @State private var dragOffset: CGFloat = 650
    @State private var lastOffset: CGFloat = 650
    @State private var searchText: String = ""
    @State private var isEditing: Bool = false
    @State private var dropdownSelection: String = "gas station"
    let dropdownOptions = ["gas station", "drugstore"]
    @AppStorage("showRecent") var showRecent = true
    
    
    var body: some View {
        VStack(spacing: 0) {
            Rectangle()
                .frame(width: 50, height: 5)
                .foregroundColor(.gray)
                .cornerRadius(2.5)
                .padding(.top)
            
            HStack {
                Text("I want to stop by a gas station OTW to:")
                //                Picker(selection: $dropdownSelection, label: Text("Stop by")) {
                //                    ForEach(dropdownOptions, id: \.self) {
                //                        Text($0)
                //                    }
                //                }
                //                .pickerStyle(MenuPickerStyle())
                //Text("OTW to:")
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
            .padding(.vertical, 10)
            
            HStack {
                TextField("Search...", text: $searchText, onEditingChanged: { editing in
                    self.isEditing = editing
                    withAnimation {
                        self.dragOffset = self.offsetTop
                    }
                    self.lastOffset = self.offsetTop
                }, onCommit: {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    withAnimation {
                        self.dragOffset = self.offsetBottom
                    }
                    self.lastOffset = self.offsetBottom
                })
                .padding(.vertical, 6)
                .padding(.horizontal, 12)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                
                
                if isEditing {
                    Button(action: {
                        self.isEditing = false
                        self.searchText = ""
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        withAnimation {
                            self.dragOffset = self.offsetBottom
                        }
                    }) {
                        Text("Cancel")
                            .foregroundColor(.blue)
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.horizontal)
            
            Spacer()
            List {
                
                ForEach(searchText.isEmpty && showRecent ? recentDestinationsMK : searchResults, id: \.self) { (destination: MKMapItem) in
                    Button(action: {
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        withAnimation {
                            self.dragOffset = self.offsetBottom
                        }
                        self.lastOffset = self.offsetBottom
                        onSelectDestination(destination)
                    }) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(destination.name ?? "")
                                .font(.headline)
                            
                            Text(getAddress(destination: destination.placemark))
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .lineLimit(1)
                                .truncationMode(.tail)
                            
                        }
                        .padding(.vertical, 2)
                    }
                }
            }
            .frame(height: 400)
            .listStyle(PlainListStyle())
            .onChange(of: searchText) { _ in
                searchDestinations()
            }
            
            
            .frame(height: 400)
            .listStyle(PlainListStyle())
            .onChange(of: searchText) { _ in
                searchDestinations()
            }
            .padding(.horizontal)
            
            
            Spacer()
        }
        .frame(height: 500)
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.4), radius: 4, x: 0, y: 1)
        .offset(y: dragOffset)
        
        .gesture(DragGesture()
            .onChanged { value in
                if self.lastOffset == self.offsetBottom {
                    self.dragOffset = value.translation.height + self.offsetBottom
                }
                else if self.lastOffset == self.offsetMiddle {
                    self.dragOffset = value.translation.height + self.offsetMiddle
                } else {
                    self.dragOffset = max(value.translation.height + self.offsetTop, self.offsetTop)
                }
            }
            .onEnded { value in
                if self.dragOffset > self.offsetBottom - 100 {
                    if isEditing {
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    }
                    withAnimation {
                        self.dragOffset = self.offsetBottom
                    }
                } else if self.dragOffset > self.offsetMiddle - 100 {
                    withAnimation {
                        self.dragOffset = self.offsetMiddle
                    }
                } else {
                    withAnimation {
                        self.dragOffset = self.offsetTop
                    }
                }
                self.lastOffset = self.dragOffset
            }
        )
    }
    
    private func searchDestinations() {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchText
        
        let search = MKLocalSearch(request: request)
        search.start { (response, error) in
            guard let response = response else {
                return
            }
            
            searchResults = response.mapItems
        }
    }
    
    func getAddress(destination: AnyObject) -> String {
        var addressParts = [String]()
        if let subthoroughfare = destination.subThoroughfare as? String, !subthoroughfare.isEmpty {
            addressParts.append(subthoroughfare)
        }
        if let thoroughfare = destination.thoroughfare as? String, !thoroughfare.isEmpty {
            addressParts.append(thoroughfare)
        }
        if let locality = destination.locality as? String, !locality.isEmpty {
            addressParts.append(locality)
        }
        if let administrativeArea = destination.administrativeArea as? String, !administrativeArea.isEmpty {
            addressParts.append(administrativeArea)
        }
        if let postalCode = destination.postalCode as? String, !postalCode.isEmpty {
            addressParts.append(postalCode)
        }
        if let country = destination.country as? String, !country.isEmpty {
            addressParts.append(country)
        }
        return addressParts.joined(separator: ", ")
    }
    
}
