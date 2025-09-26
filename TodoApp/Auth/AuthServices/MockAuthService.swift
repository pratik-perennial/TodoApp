//
//  MockAuthService.swift
//  TodoApp
//
//  Created by Pratik on 25/09/25.
//

import Foundation
import Combine

// Mock version for tests and previews
final class MockAuthService: AuthServiceProtocol {
    // Backing storage
    @Published private(set) var users: [User] = []
    @Published private(set) var currentUser: User?

    // Publishers required by protocol
    var usersPublisher: AnyPublisher<[User], Never> { $users.eraseToAnyPublisher() }
    var currentUserPublisher: AnyPublisher<User?, Never> { $currentUser.eraseToAnyPublisher() }

    init(users: [User] = [], currentUser: User? = nil) {
        self.users = users
        self.currentUser = currentUser
        loadUsers()
    }

    func loadUsers() {
        // Populate with sample users for testing when none are present
        if users.isEmpty {
            let samples: [User] = [
                User(username: "Alice", avatarData: nil),
                User(username: "Bob", avatarData: nil),
                User(username: "Charlie", avatarData: nil)
            ]
            users = samples
            currentUser = samples.first
        }
    }

    func createUser(username: String, avatarData: Data?, password: String) {
        let user = User(username: username, avatarData: avatarData)
        users.append(user)
        currentUser = user
    }

    func switchUser(to id: UUID) {
        currentUser = users.first { $0.id == id }
    }
    
    func switchUser(to id: UUID, password: String) -> Bool {
        currentUser = users.first { $0.id == id }
        return true
    }

    func deleteUser(_ user: User) {
        users.removeAll { $0.id == user.id }
        currentUser = users.first
    }
}
