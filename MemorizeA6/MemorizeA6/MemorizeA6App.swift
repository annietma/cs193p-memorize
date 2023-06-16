//
//  MemorizeA6App.swift
//  MemorizeA6
//
//  Created by Annie Ma on 5/22/23.
//

import SwiftUI

@main
struct MemorizeApp: App {
    var body: some Scene {
        WindowGroup {
            ThemeChooserView(viewModel: ThemeChooserViewModel())
        }
    }
}
