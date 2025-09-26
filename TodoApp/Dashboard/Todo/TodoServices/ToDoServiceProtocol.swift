//
//  ToDoServiceProtocol.swift
//  TodoApp
//
//  Created by Pratik on 25/09/25.
//

import Combine

protocol ToDoServiceProtocol {
    var todosPublisher: AnyPublisher<[ToDoItem], Never> { get }

    func fetchToDos() async throws
    func addToDo(_ todo: ToDoItem) async throws
    func updateToDo(_ todo: ToDoItem) async throws
    func deleteToDo(_ todo: ToDoItem) async throws
}
