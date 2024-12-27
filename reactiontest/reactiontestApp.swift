//
//  reactiontestApp.swift
//  reactiontest
//
//  Created by Fabian Weighold on 27.12.24.
//

import SwiftUI

@main
struct reactiontestApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
