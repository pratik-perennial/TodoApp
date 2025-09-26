//
//  ToDoServiceProtocol.swift
//  TodoApp
//
//  Created by Pratik on 25/09/25.
//

import Combine

/// Abstraction for persistence and observation of to-do items.
protocol ToDoServiceProtocol {
    /// Publisher emitting the current list of todos whenever it changes.
    var todosPublisher: AnyPublisher<[ToDoItem], Never> { get }

    /// Loads or refreshes todos from the underlying store.
    func fetchToDos() async throws
    /// Persists a new todo.
    func addToDo(_ todo: ToDoItem) async throws
    /// Persists updates to an existing todo.
    func updateToDo(_ todo: ToDoItem) async throws
    /// Deletes a todo.
    func deleteToDo(_ todo: ToDoItem) async throws
}
