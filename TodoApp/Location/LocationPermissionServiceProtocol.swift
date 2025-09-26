//
//  LocationPermissionServiceProtocol.swift
//  TodoApp
//
//  Created by Pratik on 25/09/25.
//


import Combine
import CoreLocation

/// Abstraction around CoreLocation permission state and requests.
protocol LocationPermissionServiceProtocol {
    /// Current authorization status.
    var authorizationStatus: CLAuthorizationStatus { get }
    /// Publisher emitting changes to authorization status.
    var authorizationStatusPublisher: Published<CLAuthorizationStatus>.Publisher { get }
    /// Triggers a permission request flow when appropriate.
    func requestPermission()
}
