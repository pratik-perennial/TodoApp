//
//  DashboardView.swift
//  TodoApp
//
//  Created by Pratik on 25/09/25.
//


import SwiftUI

struct DashboardView: View {
    @StateObject var viewModel: DashboardViewModel
    let currentUser: User
    
    @State private var selectedFilter: ToDoFilter = .upcoming
    @State private var editingToDo: ToDoItem? = nil
    @State private var showingEditSheet = false
    
    private var filteredToDos: [ToDoItem] {
        let now = Date()
        switch selectedFilter {
        case .upcoming:
            return viewModel.todos.filter { !$0.isCompleted && $0.date >= now }
                .sorted { $0.date < $1.date }
        case .past:
            return viewModel.todos.filter { !$0.isCompleted && $0.date < now }
                .sorted { $0.date > $1.date }
        case .completed:
            return viewModel.todos.filter { $0.isCompleted }
                .sorted { $0.date > $1.date }
        }
    }
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            NavigationStack {
//            Picker("Filter", selection: $selectedFilter) {
//                ForEach(ToDoFilter.allCases) { filter in
//                    Text(filter.rawValue).tag(filter)
//                }
//            }
//            .pickerStyle(SegmentedPickerStyle())
//            .padding([.horizontal, .top])
                
                List {
                    ForEach(filteredToDos) { todo in
                        Button {
                            editingToDo = todo
                            showingEditSheet = true
                        } label: {
                            HStack {
                                Image(systemName: todo.isCompleted ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(todo.isCompleted ? .green : .secondary)
                                VStack(alignment: .leading) {
                                    Text(todo.title)
                                        .font(.headline)
                                        .strikethrough(todo.isCompleted)
                                    if let notes = todo.notes, !notes.isEmpty {
                                        Text(notes)
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                    Text(todo.date, style: .date)
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                    .onDelete(perform: deleteToDos)
                }
                .navigationTitle("To-Dos for \(currentUser.username)")
                .toolbar {
                    ToolbarItemGroup(placement: .navigationBarLeading) {
                        EditButton()
                    }
                    
                    ToolbarItemGroup(placement: .navigationBarTrailing) {
                        Menu {
                            ForEach(ToDoFilter.allCases) { filter in
                                Button(action: { selectedFilter = filter }) {
                                    Label(filter.rawValue, systemImage: selectedFilter == filter ? "checkmark" : "")
                                }
                            }
                        } label: {
                            Label("Filter", systemImage: "line.horizontal.3.decrease.circle")
                                .font(.title3)
                        }
                    }
                }
                .sheet(isPresented: $showingEditSheet) {
                    if let todo = self.editingToDo {
                        ToDoEditView(todo: todo,
                                     onSave: { todo in
                            Task {
                                if viewModel.todos.contains(where: { $0.id == todo.id }) {
                                    await viewModel.update(todo: todo)
                                } else {
                                    await viewModel.addNew(todo: todo)
                                }
                                showingEditSheet = false
                            }
                        }, onCancel: {
                            showingEditSheet = false
                        })
                    }
                }
            }
            // Floating Action Button
            Button {
                self.editingToDo = ToDoItem(title: "", date: Date())
                showingEditSheet = true
            } label: {
                Image(systemName: "plus")
                    .font(.system(size: 24))
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .clipShape(Circle())
                    .shadow(radius: 5)
            }
            .padding()
        }
    }
    
    private func deleteToDos(at offsets: IndexSet) {
        Task {
            for offset in offsets {
                await viewModel.delete(todo: filteredToDos[offset])
            }
        }
    }
    
}

enum ToDoFilter: String, CaseIterable, Identifiable {
    case upcoming = "Upcoming"
    case past = "Past"
    case completed = "Completed"
    
    var id: String { rawValue }
}
