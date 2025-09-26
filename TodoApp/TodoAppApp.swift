//
//  TodoAppApp.swift
//  TodoApp
//
//  Created by Pratik on 25/09/25.
//

import SwiftUI
import CoreData
import Combine
import Firebase

@main
struct TodoAppApp: App {
    @State private var showSplash: Bool = true
    
    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            ZStack {
                if showSplash {
                    SplashView()
                        .transition(.opacity)
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    showSplash = false
                                }
                            }
                        }
                } else {
                    let service = CoreDataAuthService()
                    let authViewModel = AuthViewModel(service: service)
                    AuthView(viewModel: authViewModel)
                        .transition(.opacity)
                }
            }
        }
    }
}
