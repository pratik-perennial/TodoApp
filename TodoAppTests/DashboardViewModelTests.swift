//
//  DashboardViewModelTests.swift
//  TodoAppTests
//
//  Created by Pratik on 25/09/25.
//

import XCTest
import Combine
@testable import TodoApp

@MainActor
final class DashboardViewModelTests: XCTestCase {
    var viewModel: DashboardViewModel!
    var mockService: MockToDoService!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        cancellables = []
    }
    
    func testInitialFetchPopulatesTodos() {
        // Given initial todos
        let initialToDos = [
            ToDoItem(title: "A", date: Date()),
            ToDoItem(title: "B", date: Date())
        ]
        mockService = MockToDoService(initialTodos: initialToDos)
        
        // When viewModel is created
        viewModel = DashboardViewModel(service: mockService)
        
        // Then todos should be populated
        let expectation = XCTestExpectation(description: "Todos updated from service")
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
        mockService = MockToDoService()
        viewModel = DashboardViewModel(service: mockService)
        
        let newToDo = ToDoItem(title: "New Task", date: Date())
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
            await viewModel.addNew(todo: newToDo)
        }
        wait(for: [expectation], timeout: 1)
    }
    
    func testUpdateTodoUpdatesItem() {
        let initialToDo = ToDoItem(title: "Old Task", date: Date())
        mockService = MockToDoService(initialTodos: [initialToDo])
        viewModel = DashboardViewModel(service: mockService)
        
        let updatedToDo = ToDoItem(id: initialToDo.id, title: "Updated Task", date: initialToDo.date)
        
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
            await viewModel.update(todo: updatedToDo)
        }
        wait(for: [expectation], timeout: 1)
    }
    
    func testDeleteTodoRemovesItem() {
        let todo = ToDoItem(title: "Delete Me", date: Date())
        mockService = MockToDoService(initialTodos: [todo])
        viewModel = DashboardViewModel(service: mockService)
        
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
            await viewModel.delete(todo: todo)
        }
        wait(for: [expectation], timeout: 1)
    }
}
