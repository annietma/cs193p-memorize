//
//  On_the_WayApp.swift
//  On the Way
//
//  Created by Annie Ma on 5/26/23.
//

import SwiftUI

@main
struct On_the_WayApp: App {
    var mapViewModel = MapViewModel()
    @ObservedObject var settings = Settings()
    let persistenceController = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
            
                .environmentObject(mapViewModel)
                .environmentObject(settings)
            
        }
    }
}
