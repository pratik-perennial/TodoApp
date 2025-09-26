//
//  TodoAppApp.swift
//  TodoApp
//
//  Created by Pratik on 25/09/25.
//

import SwiftUI
import CoreData
import Firebase

@main
struct TodoAppApp: App {
    
    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            let service = CoreDataAuthService()
            let authViewModel = AuthViewModel(service: service)
            AuthView(viewModel: authViewModel)
        }
    }
}
