//
//  reactiontestApp.swift
//  reactiontest
//
//  Created by Fabian on 27.12.24.
//

import CoreData
import SwiftUI

@main
struct ReactionTestApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                ContentView()
            }
            .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
