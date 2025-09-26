//
//  MockLocationPermissionService.swift
//  TodoApp
//
//  Created by Pratik on 25/09/25.
//

import CoreLocation
import Combine

@MainActor
final class MockLocationPermissionService: LocationPermissionServiceProtocol {
    @Published private(set) var authorizationStatus: CLAuthorizationStatus
    var authorizationStatusPublisher: Published<CLAuthorizationStatus>.Publisher { $authorizationStatus }
    
    init(initialStatus: CLAuthorizationStatus = .notDetermined) {
        authorizationStatus = initialStatus
    }
    
    func requestPermission() {
        // Simulate user granting permission after request with a delay
        Task {
            try await Task.sleep(nanoseconds: 500_000_000) // 0.5 sec delay
            authorizationStatus = .authorizedWhenInUse
        }
    }
}
