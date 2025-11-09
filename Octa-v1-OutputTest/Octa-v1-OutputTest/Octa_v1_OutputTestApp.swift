//
//  Octa_v1_OutputTestApp.swift
//  Octa-v1-OutputTest
//
//  Created by davidzhou on 2025/11/3.
//

import SwiftUI

@main
struct Octa_v1_OutputTestApp: App {
    var body: some Scene {
        WindowGroup {
            PhotoLibraryPermissionGate {
                ContentView()
            }
        }
    }
}
