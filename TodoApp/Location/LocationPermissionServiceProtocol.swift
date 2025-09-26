//
//  LocationPermissionServiceProtocol.swift
//  TodoApp
//
//  Created by Pratik on 25/09/25.
//


import Combine
import CoreLocation

protocol LocationPermissionServiceProtocol {
    var authorizationStatus: CLAuthorizationStatus { get }
    var authorizationStatusPublisher: Published<CLAuthorizationStatus>.Publisher { get }
    func requestPermission()
}
