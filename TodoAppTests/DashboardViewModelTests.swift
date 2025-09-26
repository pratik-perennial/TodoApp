//
//  DashboardViewModelTests.swift
//  TodoAppTests
//
//  Created by Pratik on 25/09/25.
//

import Combine
import CoreLocation
import XCTest

@testable import TodoApp

@MainActor
final class DashboardViewModelTests: XCTestCase {
    var viewModel: DashboardViewModel!
    var mockService: MockToDoService!
    var mockLocationPermissionService: LocationPermissionServiceProtocol!
    var mockWeatherService: MockWeatherAPIService!
    var cancellables: Set<AnyCancellable>!

    let sampleWeather = CurrentWeather(
        temperature: 29.0,
        windspeed: 20,
        winddirection: 1.0,
        weathercode: 1,
        time: "",
        hourly: HourlyData(
            time: [
                "2025-09-26T00:00", "2025-09-26T01:00", "2025-09-26T02:00",
                "2025-09-26T03:00", "2025-09-26T04:00", "2025-09-26T05:00",
                "2025-09-26T06:00", "2025-09-26T07:00", "2025-09-26T08:00",
                "2025-09-26T09:00", "2025-09-26T10:00", "2025-09-26T11:00",
                "2025-09-26T12:00", "2025-09-26T13:00", "2025-09-26T14:00",
                "2025-09-26T15:00", "2025-09-26T16:00", "2025-09-26T17:00",
                "2025-09-26T18:00", "2025-09-26T19:00", "2025-09-26T20:00",
                "2025-09-26T21:00", "2025-09-26T22:00", "2025-09-26T23:00",
            ],
            temperature_2m: [
                15.5, 15.2, 14.5, 14.0, 14.9, 15.0, 14.6, 13.9, 14.4, 16.0,
                17.3, 20.7, 23.9, 26.4, 26.3, 25.8, 24.4, 23.5, 22.0, 19.7,
                17.8, 16.7, 16.0, 15.8,
            ]
        )
    )

    override func setUp() {
        super.setUp()
        cancellables = []
        mockService = MockToDoService(initialTodos: [])
        mockLocationPermissionService = MockLocationPermissionService(
            initialStatus: .denied
        )
        mockWeatherService = MockWeatherAPIService(mockedWeather: sampleWeather)
        viewModel = DashboardViewModel(
            service: mockService,
            permissionService: mockLocationPermissionService,
            weatherService: mockWeatherService,
            currentUserId: UUID()
        )
    }

    func testInitialFetchPopulatesTodos() {
        // Given initial todos
        let u = UUID()
        let initialToDos = [
            ToDoItem(userId: u, title: "A", date: Date()),
            ToDoItem(userId: u, title: "B", date: Date()),
        ]
        mockService = MockToDoService(initialTodos: initialToDos)

        // When viewModel is created
        viewModel = DashboardViewModel(
            service: mockService,
            permissionService: mockLocationPermissionService,
            weatherService: mockWeatherService,
            currentUserId: u
        )

        // Then todos should be populated
        let expectation = XCTestExpectation(
            description: "Todos updated from service"
        )
        viewModel.$todos
            .dropFirst()
            .sink { todos in
                if todos.count == 2 {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        wait(for: [expectation], timeout: 1)
        XCTAssertEqual(viewModel.todos.count, 2)
    }

    func testAddNewTodoAddsItem() {
        let newToDo = ToDoItem(userId: UUID(), title: "New Task", date: Date())
        let expectation = XCTestExpectation(description: "Todo added")

        viewModel.$todos
            .dropFirst()
            .sink { todos in
                if todos.contains(where: { $0.title == "New Task" }) {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        Task {
            await viewModel.addNewTodo(todo: newToDo)
        }
        wait(for: [expectation], timeout: 1)
    }

    func testUpdateTodoUpdatesItem() {
        let initialToDo = ToDoItem(userId: UUID(), title: "Old Task", date: Date())
        mockService = MockToDoService(initialTodos: [initialToDo])
        viewModel = DashboardViewModel(
            service: mockService,
            permissionService: mockLocationPermissionService,
            weatherService: mockWeatherService,
            currentUserId: initialToDo.userId
        )

        let updatedToDo = ToDoItem(
            id: initialToDo.id,
            userId: initialToDo.userId,
            title: "Updated Task",
            date: initialToDo.date
        )

        let expectation = XCTestExpectation(description: "Todo updated")
        viewModel.$todos
            .dropFirst()
            .sink { todos in
                if todos.contains(where: { $0.title == "Updated Task" }) {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        Task {
            await viewModel.updateTodo(todo: updatedToDo)
        }
        wait(for: [expectation], timeout: 1)
    }

    func testDeleteTodoRemovesItem() {
        let todo = ToDoItem(userId: UUID(), title: "Delete Me", date: Date())
        mockService = MockToDoService(initialTodos: [todo])
        viewModel = DashboardViewModel(
            service: mockService,
            permissionService: mockLocationPermissionService,
            weatherService: mockWeatherService,
            currentUserId: todo.userId
        )

        let expectation = XCTestExpectation(description: "Todo deleted")
        viewModel.$todos
            .dropFirst()
            .sink { todos in
                if !todos.contains(where: { $0.id == todo.id }) {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        Task {
            await viewModel.deleteTodo(todo: todo)
        }
        wait(for: [expectation], timeout: 1)
    }

    func testInitialAuthorizationStatus() {
        XCTAssertEqual(viewModel.locationStatus, .notDetermined)
    }

    func testRequestPermissionUpdatesStatus() {
        let expectation = XCTestExpectation(
            description:
                "Authorization status should change to authorizedWhenInUse"
        )

        viewModel.$locationStatus
            .dropFirst()
            .sink { newStatus in
                if newStatus == .authorizedWhenInUse {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        viewModel.requestLocationPermission()
        wait(for: [expectation], timeout: 2)
    }
}

extension DashboardViewModelTests {

    func testFetchCurrentWeatherSuccess() async throws {
        // Given
        mockWeatherService = MockWeatherAPIService(
            mockedWeather: sampleWeather
        )

        // When
        let weather = try await mockWeatherService.fetchCurrentWeather(
            latitude: 18.5,
            longitude: 73.8
        )

        // Then
        XCTAssertEqual(weather.temperature, sampleWeather.temperature)
        XCTAssertEqual(weather.windspeed, sampleWeather.windspeed)
        XCTAssertEqual(weather.winddirection, sampleWeather.winddirection)
        XCTAssertEqual(weather.weathercode, sampleWeather.weathercode)
        XCTAssertEqual(weather.time, sampleWeather.time)
    }

    func testFetchCurrentWeatherNetworkError() async {
        // Given
        let networkError = URLError(.notConnectedToInternet)
        mockWeatherService = MockWeatherAPIService(error: networkError)

        // When/Then
        do {
            let _ = try await mockWeatherService.fetchCurrentWeather(
                latitude: 18.5,
                longitude: 73.8
            )
            XCTFail("Expected error was not thrown")
        } catch let error as URLError {
            XCTAssertEqual(error.code, .notConnectedToInternet)
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }

    func testFetchCurrentWeatherDecodingError() async {
        // Given
        let decodingError = DecodingError.dataCorrupted(
            .init(codingPath: [], debugDescription: "Fake decoding error")
        )
        mockWeatherService = MockWeatherAPIService(error: decodingError)

        // When/Then
        do {
            let _ = try await mockWeatherService.fetchCurrentWeather(
                latitude: 18.5,
                longitude: 73.8
            )
            XCTFail("Expected decoding error was not thrown")
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }

    func testFetchCurrentWeatherGenericError() async {
        // Given
        struct SomeError: Error, Equatable {}
        let genericError = SomeError()
        mockWeatherService = MockWeatherAPIService(error: genericError)

        // When/Then
        do {
            let _ = try await mockWeatherService.fetchCurrentWeather(
                latitude: 18.5,
                longitude: 73.8
            )
            XCTFail("Expected generic error was not thrown")
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }
}
