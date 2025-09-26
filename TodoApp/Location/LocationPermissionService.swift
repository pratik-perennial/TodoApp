//
//  LocationPermissionService.swift
//  TodoApp
//
//  Created by Pratik on 25/09/25.
//


import Foundation
import CoreLocation
import Combine

@MainActor
final class LocationPermissionService: NSObject, ObservableObject, LocationPermissionServiceProtocol {
    var authorizationStatusPublisher: Published<CLAuthorizationStatus>.Publisher { $authorizationStatus }
    
    private let locationManager = CLLocationManager()

    @Published private(set) var authorizationStatus: CLAuthorizationStatus

    override init() {
        authorizationStatus = locationManager.authorizationStatus
        super.init()
        locationManager.delegate = self
    }

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
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
    }
}
