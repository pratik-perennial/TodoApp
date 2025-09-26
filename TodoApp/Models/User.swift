//
//  User.swift
//  TodoApp
//
//  Created by Pratik on 25/09/25.
//

import Foundation

// User data model
struct User: Identifiable, Codable, Equatable {
    var id: UUID
    var username: String
    var avatarData: Data?
    var createdAt: Date
    
    init(id: UUID, username: String, avatarData: Data? = nil, createdAt: Date) {
        self.id = id
        self.username = username
        self.avatarData = avatarData
        self.createdAt = createdAt
    }

    init(username: String, avatarData: Data? = nil) {
        self.id = UUID()
        self.username = username
        self.avatarData = avatarData
        self.createdAt = Date()
    }
}
