//
//  MockLocationPermissionService.swift
//  TodoApp
//
//  Created by Pratik on 25/09/25.
//

import CoreLocation
import Combine

/// Mock permission service that simulates granting permission.
@MainActor
final class MockLocationPermissionService: LocationPermissionServiceProtocol {
    @Published private(set) var authorizationStatus: CLAuthorizationStatus
    var authorizationStatusPublisher: Published<CLAuthorizationStatus>.Publisher { $authorizationStatus }
    
    /// Creates a mock with an initial status.
    init(initialStatus: CLAuthorizationStatus = .notDetermined) {
        authorizationStatus = initialStatus
    }
    
    /// Simulates a delayed grant of `.authorizedWhenInUse`.
    func requestPermission() {
        // Simulate user granting permission after request with a delay
        Task {
            try await Task.sleep(nanoseconds: 500_000_000) // 0.5 sec delay
            authorizationStatus = .authorizedWhenInUse
        }
    }
}
