//
//  ToDoItem.swift
//  TodoApp
//
//  Created by Pratik on 25/09/25.
//

import Foundation

/// Value type representing a single to-do item belonging to a specific user.
struct ToDoItem: Identifiable, Equatable {
    let id: UUID
    let userId: UUID
    var title: String
    var notes: String?
    var date: Date
    var isCompleted: Bool

    /// Creates a new `ToDoItem`.
    /// - Parameters:
    ///   - id: Stable identifier. Defaults to a new UUID.
    ///   - userId: Owner user identifier.
    ///   - title: Short title for the task.
    ///   - notes: Optional additional notes.
    ///   - date: Due date/time.
    ///   - isCompleted: Whether the task is completed. Defaults to false.
    init(id: UUID = UUID(), userId: UUID, title: String, notes: String? = nil, date: Date, isCompleted: Bool = false) {
        self.id = id
        self.userId = userId
        self.title = title
        self.notes = notes
        self.date = date
        self.isCompleted = isCompleted
    }
}
