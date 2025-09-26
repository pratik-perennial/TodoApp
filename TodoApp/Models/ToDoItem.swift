//
//  ToDoItem.swift
//  TodoApp
//
//  Created by Pratik on 25/09/25.
//

import Foundation

struct ToDoItem: Identifiable, Equatable {
    let id: UUID
    let userId: UUID
    var title: String
    var notes: String?
    var date: Date
    var isCompleted: Bool

    init(id: UUID = UUID(), userId: UUID, title: String, notes: String? = nil, date: Date, isCompleted: Bool = false) {
        self.id = id
        self.userId = userId
        self.title = title
        self.notes = notes
        self.date = date
        self.isCompleted = isCompleted
    }
}
