//
//  AuthServiceProtocol.swift
//  TodoApp
//
//  Created by Pratik on 25/09/25.
//

import Foundation
import Combine

/// Abstraction for authentication data flow and operations. Both concrete and mock services should conform to this protocol.
protocol AuthServiceProtocol: AnyObject {
    // Current list of users
    var users: [User] { get }
    // The currently selected user
    var currentUser: User? { get }

    // Combine publishers for observing changes
    var usersPublisher: AnyPublisher<[User], Never> { get }
    var currentUserPublisher: AnyPublisher<User?, Never> { get }

    // Lifecycle / actions
    func loadUsers()
    func createUser(username: String, avatarData: Data?, password: String)
    func switchUser(to id: UUID)
    @discardableResult func switchUser(to id: UUID, password: String) -> Bool
    func deleteUser(_ user: User)
}
