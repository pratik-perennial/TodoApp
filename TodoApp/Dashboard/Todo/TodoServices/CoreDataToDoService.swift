//
//  CoreDataToDoService.swift
//  TodoApp
//
//  Created by Pratik on 25/09/25.
//


import CoreData
import Combine

final class CoreDataToDoService: ToDoServiceProtocol {
    private let persistentContainer: NSPersistentContainer
    private let context: NSManagedObjectContext

    @Published private var todos: [ToDoItem] = []
    var todosPublisher: AnyPublisher<[ToDoItem], Never> { $todos.eraseToAnyPublisher() }
        
    init() {
        let model = NSManagedObjectModel()
        
        // Entity description
        let entity = NSEntityDescription()
        entity.name = "ToDoEntity"
        entity.managedObjectClassName = NSStringFromClass(ToDoEntity.self)
        
        // Attributes
        let idAttr = NSAttributeDescription()
        idAttr.name = "id"
        idAttr.attributeType = .stringAttributeType
        idAttr.isOptional = false

        let userIdAttr = NSAttributeDescription()
        userIdAttr.name = "userId"
        userIdAttr.attributeType = .stringAttributeType
        userIdAttr.isOptional = false
        
        let titleAttr = NSAttributeDescription()
        titleAttr.name = "title"
        titleAttr.attributeType = .stringAttributeType
        titleAttr.isOptional = false
        
        let notesAttr = NSAttributeDescription()
        notesAttr.name = "notes"
        notesAttr.attributeType = .stringAttributeType
        notesAttr.isOptional = true
        
        let dateAttr = NSAttributeDescription()
        dateAttr.name = "date"
        dateAttr.attributeType = .dateAttributeType
        dateAttr.isOptional = false
        
        let completedAttr = NSAttributeDescription()
        completedAttr.name = "isCompleted"
        completedAttr.attributeType = .booleanAttributeType
        completedAttr.isOptional = false
        completedAttr.defaultValue = false
        
        let orderAttr = NSAttributeDescription()
        orderAttr.name = "order"
        orderAttr.attributeType = .integer64AttributeType
        orderAttr.isOptional = true
        
        entity.properties = [idAttr, userIdAttr, titleAttr, notesAttr, dateAttr, completedAttr, orderAttr]
        
        model.entities = [entity]
        
        persistentContainer = NSPersistentContainer(name: "ToDos", managedObjectModel: model)
        persistentContainer.loadPersistentStores { _, error in
            if let error = error { fatalError("ToDoStack failed: \(error)") }
        }
        persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
        
        context = persistentContainer.viewContext
    }

    func fetchToDos() async throws {
        let request = NSFetchRequest<ToDoEntity>(entityName: "ToDoEntity")
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        let results = try context.fetch(request)
        todos = results.map { $0.toDoItem() }
    }

    func addToDo(_ todo: ToDoItem) async throws {
        let entity = ToDoEntity(context: context)
        entity.update(from: todo)
        try context.save()
        try await fetchToDos()
    }

    func updateToDo(_ todo: ToDoItem) async throws {
        let request = NSFetchRequest<ToDoEntity>(entityName: "ToDoEntity")
        request.predicate = NSPredicate(format: "id == %@", todo.id.uuidString)
        if let entity = try context.fetch(request).first {
            entity.update(from: todo)
            try context.save()
            try await fetchToDos()
        }
    }

    func deleteToDo(_ todo: ToDoItem) async throws {
        let request = NSFetchRequest<ToDoEntity>(entityName: "ToDoEntity")
        request.predicate = NSPredicate(format: "id == %@", todo.id.uuidString)
        if let entity = try context.fetch(request).first {
            context.delete(entity)
            try context.save()
            try await fetchToDos()
        }
    }
}
