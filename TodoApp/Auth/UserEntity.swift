//
//  UserEntity.swift
//  TodoApp
//
//  Created by Pratik on 25/09/25.
//

import Foundation
import CoreData

@objc(UserEntity)
class UserEntity: NSManagedObject {
    @NSManaged var id: UUID
    @NSManaged var username: String
    @NSManaged var avatarData: Data?
    @NSManaged var createdAt: Date
}

extension User {
    init(entity: UserEntity) {
        self.id = entity.id
        self.username = entity.username
        self.avatarData = entity.avatarData
        self.createdAt = entity.createdAt
    }
}

extension UserEntity {
    func apply(from user: User) {
        self.id = user.id
        self.username = user.username
        self.avatarData = user.avatarData
        self.createdAt = user.createdAt
    }
}


final class AuthUsersStack {
    static let shared = AuthUsersStack()

    let container: NSPersistentContainer

    init() {
        let model = NSManagedObjectModel()

        // Entity description
        let entity = NSEntityDescription()
        entity.name = "UserEntity"
        entity.managedObjectClassName = NSStringFromClass(UserEntity.self)

        // Attributes
        let idAttr = NSAttributeDescription()
        idAttr.name = "id"
        idAttr.attributeType = .UUIDAttributeType
        idAttr.isOptional = false

        let usernameAttr = NSAttributeDescription()
        usernameAttr.name = "username"
        usernameAttr.attributeType = .stringAttributeType
        usernameAttr.isOptional = false

        let avatarAttr = NSAttributeDescription()
        avatarAttr.name = "avatarData"
        avatarAttr.attributeType = .binaryDataAttributeType
        avatarAttr.allowsExternalBinaryDataStorage = true
        avatarAttr.isOptional = true

        let createdAtAttr = NSAttributeDescription()
        createdAtAttr.name = "createdAt"
        createdAtAttr.attributeType = .dateAttributeType
        createdAtAttr.isOptional = false

        entity.properties = [idAttr, usernameAttr, avatarAttr, createdAtAttr]

        model.entities = [entity]

        container = NSPersistentContainer(name: "AuthUsers", managedObjectModel: model)
        container.loadPersistentStores { _, error in
            if let error = error { fatalError("AuthUsersStack failed: \(error)") }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
