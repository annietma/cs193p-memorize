//  SettingsView.swift
//  On the Way
//
//  Created by Annie Ma on 6/2/23.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    @AppStorage("showMapsButton") var showMapsButton = true
    @AppStorage("showRecent") var showRecent = true
    
    var body: some View {
        NavigationView {
            List {
                Toggle("Show Maps button", isOn: $showMapsButton)
                Toggle("Show recently searched destinations", isOn: $showRecent)
            }
            .navigationTitle("Settings")
            .toolbar {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "xmark")
                }
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
