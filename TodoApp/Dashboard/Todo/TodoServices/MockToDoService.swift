//
//  MockToDoService.swift
//  TodoApp
//
//  Created by Pratik on 25/09/25.
//
import SwiftUI
import Combine

final class MockToDoService: ToDoServiceProtocol {
    @Published private(set) var todos: [ToDoItem]
    var todosPublisher: AnyPublisher<[ToDoItem], Never> { $todos.eraseToAnyPublisher() }
    
    init(initialTodos: [ToDoItem] = []) {
        todos = initialTodos
    }
    
    func fetchToDos() async throws {
        // No-op, todos already set
    }
    
    func addToDo(_ todo: ToDoItem) async throws {
        todos.append(todo)
    }
    
    func updateToDo(_ todo: ToDoItem) async throws {
        if let idx = todos.firstIndex(where: { $0.id == todo.id }) {
            todos[idx] = todo
        }
    }
    
    func deleteToDo(_ todo: ToDoItem) async throws {
        todos.removeAll { $0.id == todo.id }
    }
    
}
