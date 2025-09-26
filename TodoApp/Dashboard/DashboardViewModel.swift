//
//  DashboardViewModel.swift
//  TodoApp
//
//  Created by Pratik on 25/09/25.
//

import Foundation
import Combine
import SwiftUI
import CoreLocation

/// View model for the dashboard screen. Coordinates todos, weather, and permissions.
final class DashboardViewModel: ObservableObject {
    @Published private(set) var todos: [ToDoItem] = []
    @Published var currentWeather: WeatherResponse?
    @Published var locationStatus: CLAuthorizationStatus = .notDetermined
    
    private let todoService: ToDoServiceProtocol
    private let currentUserId: UUID
    private let weatherService: WeatherAPIServiceProtocol
    private let permissionService: LocationPermissionServiceProtocol
    
    private var cancellables = Set<AnyCancellable>()
 
    /// Requests location permissions from the permission service.
    func requestLocationPermission() {
        permissionService.requestPermission()
    }
    
    /// Creates the view model and binds publishers for todos and location status.
    init(service: ToDoServiceProtocol, permissionService: LocationPermissionServiceProtocol, weatherService: WeatherAPIServiceProtocol, currentUserId: UUID) {
        self.permissionService = permissionService
        self.todoService = service
        self.currentUserId = currentUserId
        self.weatherService = weatherService
        
        permissionService.authorizationStatusPublisher
            .receive(on: DispatchQueue.main)
            .assign(to: &$locationStatus)
        
        todoService.todosPublisher
            .receive(on: DispatchQueue.main)
            .map { items in items.filter { $0.userId == self.currentUserId } }
            .assign(to: &$todos)
        Task {
            try? await todoService.fetchToDos()
        }
    }
    
    /// Adds a new todo via the service.
    func addNewTodo(todo: ToDoItem) async {
        try? await todoService.addToDo(todo)
    }
    /// Updates an existing todo via the service.
    func updateTodo(todo: ToDoItem) async {
        try? await todoService.updateToDo(todo)
    }
    /// Deletes a todo via the service.
    func deleteTodo(todo: ToDoItem) async {
        try? await todoService.deleteToDo(todo)
    }
    
    /// Fetches current weather for the provided coordinates and updates `currentWeather`.
    func loadWeather(latitude: Double, longitude: Double) {
        Task {
            do {
                let weather = try await weatherService.fetchCurrentWeather(latitude: latitude, longitude: longitude)
                await MainActor.run {
                    self.currentWeather = weather
                }
            } catch {
                print("Failed to fetch weather:", error)
            }
        }
    }
}

