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
            let service = CoreDataAuthService()
            let authViewModel = AuthViewModel(service: service)
            AuthView(viewModel: authViewModel)
//            ContentView()
//                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
