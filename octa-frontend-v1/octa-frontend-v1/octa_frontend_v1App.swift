//
//  octa_frontend_v1App.swift
//  octa-frontend-v1
//
//  Created by davidzhou on 2025/11/5.
//

import SwiftUI
import CoreData

@main
struct octa_frontend_v1App: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
