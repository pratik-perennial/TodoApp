//
//  ToDoEditView.swift
//  TodoApp
//
//  Created by Pratik on 25/09/25.
//

import SwiftUI

struct ToDoEditView: View {
    let todo: ToDoItem
    var onSave: (ToDoItem) -> Void
    var onCancel: () -> Void

    @State private var title: String
    @State private var notes: String
    @State private var date: Date
    @State private var isCompleted: Bool

    // Custom initializer to set @State initial values from todo
    init(
        todo: ToDoItem,
        onSave: @escaping (ToDoItem) -> Void,
        onCancel: @escaping () -> Void
    ) {
        self.todo = todo
        self.onSave = onSave
        self.onCancel = onCancel
        _title = State(initialValue: todo.title)
        _notes = State(initialValue: todo.notes ?? "")
        _date = State(initialValue: todo.date)
        _isCompleted = State(initialValue: todo.isCompleted)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Title")) {
                    TextField("Title", text: $title)
                }
                Section(header: Text("Notes")) {
                    TextField("Notes", text: $notes)
                }
                Section {
                    DatePicker(
                        "Due date",
                        selection: $date,
                        displayedComponents: [.date, .hourAndMinute]
                    )
                    Toggle("Completed", isOn: $isCompleted)
                }
            }
            .navigationTitle(todo.title.isEmpty ? "New To-Do" : "Edit To-Do")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { onCancel() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave(
                            ToDoItem(
                                id: todo.id,
                                title: title,
                                notes: notes.isEmpty ? nil : notes,
                                date: date,
                                isCompleted: isCompleted
                            )
                        )
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
    }
}
#Preview {
    ToDoEditView(
        todo: ToDoItem.init(
            id: UUID(),
            title: "New Note",
            notes: nil,
            date: .init(),
            isCompleted: false
        ),
        onSave: { _ in },
        onCancel: {}
    )
}
