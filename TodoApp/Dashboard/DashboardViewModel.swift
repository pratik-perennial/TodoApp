//
//  DashboardViewModel.swift
//  TodoApp
//
//  Created by Pratik on 25/09/25.
//

import Foundation
import Combine
import SwiftUI

final class DashboardViewModel: ObservableObject {
    @Published private(set) var todos: [ToDoItem] = []
    private let todoService: ToDoServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(service: ToDoServiceProtocol) {
        todoService = service
        todoService.todosPublisher
            .receive(on: DispatchQueue.main)
            .assign(to: &$todos)
        Task {
            try? await todoService.fetchToDos()
        }
    }
    
    func addNew(todo: ToDoItem) async {
        try? await todoService.addToDo(todo)
    }
    func update(todo: ToDoItem) async {
        try? await todoService.updateToDo(todo)
    }
    func delete(todo: ToDoItem) async {
        try? await todoService.deleteToDo(todo)
    }
}

