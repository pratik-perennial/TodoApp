//
//  ToDoEntity.swift
//  TodoApp
//
//  Created by Pratik on 25/09/25.
//


import CoreData

@objc(ToDoEntity)
public class ToDoEntity: NSManagedObject {

}

extension ToDoEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<ToDoEntity> {
        return NSFetchRequest<ToDoEntity>(entityName: "ToDoEntity")
    }

    @NSManaged public var id: String?
    @NSManaged public var userId: String?
    @NSManaged public var title: String?
    @NSManaged public var notes: String?
    @NSManaged public var date: Date?
    @NSManaged public var isCompleted: Bool
    @NSManaged public var order: Int64  // Optional for manual ordering
}

extension ToDoEntity {
    func toDoItem() -> ToDoItem {
        ToDoItem(
            id: UUID(uuidString: id ?? "") ?? UUID(),
            userId: UUID(uuidString: userId ?? "") ?? UUID(),
            title: title ?? "",
            notes: notes,
            date: date ?? Date(),
            isCompleted: isCompleted
        )
    }
    
    func update(from todo: ToDoItem) {
        id = todo.id.uuidString
        userId = todo.userId.uuidString
        title = todo.title
        notes = todo.notes
        date = todo.date
        isCompleted = todo.isCompleted
        // For order if implemented
        // order = Int64(todo.order)
    }
}
