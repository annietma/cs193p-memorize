//
//  SetApp.swift
//  Set
//
//  Created by Annie Ma on 4/24/23.
//

import SwiftUI

@main
struct SetApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: SetGameViewModel())
        }
    }
}
