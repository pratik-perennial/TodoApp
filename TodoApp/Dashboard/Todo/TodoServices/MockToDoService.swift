//
//  MockToDoService.swift
//  TodoApp
//
//  Created by Pratik on 25/09/25.
//
import SwiftUI
import Combine

/// In-memory mock todo service for previews and tests.
final class MockToDoService: ToDoServiceProtocol {
    @Published private(set) var todos: [ToDoItem]
    var todosPublisher: AnyPublisher<[ToDoItem], Never> { $todos.eraseToAnyPublisher() }
    
    /// Creates a mock service seeded with optional initial todos.
    init(initialTodos: [ToDoItem] = []) {
        todos = initialTodos
    }
    
    /// No-op for mock; todos are already in memory.
    func fetchToDos() async throws {
        // No-op, todos already set
    }
    
    /// Appends a new todo to the in-memory list.
    func addToDo(_ todo: ToDoItem) async throws {
        todos.append(todo)
    }
    
    /// Replaces an existing todo by id.
    func updateToDo(_ todo: ToDoItem) async throws {
        if let idx = todos.firstIndex(where: { $0.id == todo.id }) {
            todos[idx] = todo
        }
    }
    
    /// Removes a todo by id.
    func deleteToDo(_ todo: ToDoItem) async throws {
        todos.removeAll { $0.id == todo.id }
    }
    
}
