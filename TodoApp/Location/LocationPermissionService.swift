//
//  LocationPermissionService.swift
//  TodoApp
//
//  Created by Pratik on 25/09/25.
//


import Foundation
import CoreLocation
import Combine

/// Real CoreLocation-backed permission service.
@MainActor
final class LocationPermissionService: NSObject, ObservableObject, LocationPermissionServiceProtocol {
    var authorizationStatusPublisher: Published<CLAuthorizationStatus>.Publisher { $authorizationStatus }
    
    private let locationManager = CLLocationManager()

    @Published private(set) var authorizationStatus: CLAuthorizationStatus

    /// Initializes with current system authorization and sets up delegate callbacks.
    override init() {
        authorizationStatus = locationManager.authorizationStatus
        super.init()
        locationManager.delegate = self
    }

    /// Requests `.whenInUse` authorization when status is `.notDetermined`.
    func requestPermission() {
        switch authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        default:
            break
        }
    }
}

extension LocationPermissionService: CLLocationManagerDelegate {
    /// Propagates changes from CoreLocation to the published status.
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
    }
}
