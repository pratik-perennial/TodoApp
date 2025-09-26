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

final class DashboardViewModel: ObservableObject {
    @Published private(set) var todos: [ToDoItem] = []
    @Published var currentWeather: WeatherResponse?
    @Published var locationStatus: CLAuthorizationStatus = .notDetermined
    
    private let todoService: ToDoServiceProtocol
    private let weatherService: WeatherAPIServiceProtocol
    private let permissionService: LocationPermissionServiceProtocol
    
    private var cancellables = Set<AnyCancellable>()
 
    func requestLocationPermission() {
        permissionService.requestPermission()
    }
    
    init(service: ToDoServiceProtocol, permissionService: LocationPermissionServiceProtocol, weatherService: WeatherAPIServiceProtocol) {
        self.permissionService = permissionService
        self.todoService = service
        self.weatherService = weatherService
        
        permissionService.authorizationStatusPublisher
            .receive(on: DispatchQueue.main)
            .assign(to: &$locationStatus)
        
        todoService.todosPublisher
            .receive(on: DispatchQueue.main)
            .assign(to: &$todos)
        Task {
            try? await todoService.fetchToDos()
        }
    }
    
    func addNewTodo(todo: ToDoItem) async {
        try? await todoService.addToDo(todo)
    }
    func updateTodo(todo: ToDoItem) async {
        try? await todoService.updateToDo(todo)
    }
    func deleteTodo(todo: ToDoItem) async {
        try? await todoService.deleteToDo(todo)
    }
    
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

