//
//  TodoAppApp.swift
//  TodoApp
//
//  Created by Pratik on 25/09/25.
//

import SwiftUI
import CoreData

@main
struct TodoAppApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
