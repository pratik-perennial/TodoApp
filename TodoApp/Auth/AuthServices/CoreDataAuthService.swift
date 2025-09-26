//
//  AuthService.swift
//  TodoApp
//
//  Created by Pratik on 25/09/25.
//

import Foundation
import Combine
import CoreData

final class CoreDataAuthService: AuthServiceProtocol {
    private let credentialStore: AuthCredentialStore

    // Shared instance using UserDefaults by default
    static let shared = CoreDataAuthService(credentials: KeychainAuthCredentialStore())

    @Published var users: [User] = []
    @Published var currentUser: User?

    var usersPublisher: AnyPublisher<[User], Never> { $users.eraseToAnyPublisher() }
    var currentUserPublisher: AnyPublisher<User?, Never> { $currentUser.eraseToAnyPublisher() }

    init(credentials: AuthCredentialStore = KeychainAuthCredentialStore()) {
        self.credentialStore = credentials
        loadUsers()
    }
    

    func loadUsers() {
        Task {
            do {
                let loaded = try await loadUsers()
                let currentID = try await loadCurrentUserID()
                self.users = loaded
                if let id = currentID, let user = loaded.first(where: { $0.id == id }) {
                    self.currentUser = user
                } else {
                    self.currentUser = loaded.first
                }
            } catch {
                // In case of failure, keep in-memory state empty
                self.users = []
                self.currentUser = nil
            }
        }
    }
    
    func loadCurrentUserID() async throws -> UUID? {
        let defaultsKey = "AuthUsers.currentUserID"
        if let str = UserDefaults.standard.string(forKey: defaultsKey) { return UUID(uuidString: str) }
        return nil
    }
    
    func loadUsers() async throws -> [User] {
        let context = AuthUsersStack.shared.container.viewContext
        return try context.performAndWait { () -> [User] in
            let request = NSFetchRequest<UserEntity>(entityName: "UserEntity")
            request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: true)]
            let results = try context.fetch(request)
            return results.map { User(id: $0.id, username: $0.username, avatarData: $0.avatarData, createdAt: $0.createdAt) }
        }
    }

    func createUser(username: String, avatarData: Data?) {
        // Backward compatible path: creates a user without setting a password
        let newUser = User(username: username, avatarData: avatarData)
        users.append(newUser)
        currentUser = newUser
        persistAll()
    }

    /// Create a user and set a password for local login
    func createUser(username: String, avatarData: Data?, password: String) {
        let newUser = User(username: username, avatarData: avatarData)
        users.append(newUser)
        currentUser = newUser
        do { try credentialStore.setPassword(password, for: newUser.id) } catch { /* handle/log as needed */ }
        persistAll()
    }

    /// Attempt to switch the current user by id without a password.
    /// If the target user has a password set, this method will not switch.
    func switchUser(to id: UUID) {
        guard let user = users.first(where: { $0.id == id }) else { return }
        let requiresPassword = (try? credentialStore.hasPassword(for: id)) ?? false
        if requiresPassword {
            // Do nothing; UI should call the passworded variant
            return
        }
        currentUser = user
        Task { try? await saveCurrentUserID(id) }
    }

    /// Switch user, validating the provided password if one is set.
    /// Returns true on success, false if password validation fails or user not found.
    @discardableResult
    func switchUser(to id: UUID, password: String) -> Bool {
        guard let user = users.first(where: { $0.id == id }) else { return false }
        let requiresPassword = (try? credentialStore.hasPassword(for: id)) ?? false
        if requiresPassword {
            let ok = (try? credentialStore.validatePassword(password, for: id)) ?? false
            guard ok else { return false }
        }
        currentUser = user
        Task { try? await saveCurrentUserID(id) }
        return true
    }

    func deleteUser(_ user: User) {
        users.removeAll { $0.id == user.id }
        currentUser = users.first
        try? credentialStore.deletePassword(for: user.id)
        persistAll()
    }

    private func persistAll() {
        let snapshotUsers = self.users
        let currentID = self.currentUser?.id
        Task {
            try? await saveUsers(snapshotUsers)
            try? await saveCurrentUserID(currentID)
        }
    }
    
    func saveUsers(_ users: [User]) async throws {
        let context = AuthUsersStack.shared.container.viewContext
        try context.performAndWait {
            // Fetch existing
            let request = NSFetchRequest<UserEntity>(entityName: "UserEntity")
            let existing = try context.fetch(request)
            // Build an index for existing by id
            var existingByID: [UUID: UserEntity] = [:]
            existing.forEach { existingByID[$0.id] = $0 }
            
            // Upsert incoming users
            for user in users {
                if let entity = existingByID.removeValue(forKey: user.id) {
                    entity.apply(from: user)
                } else {
                    let entityDesc = NSEntityDescription.entity(forEntityName: "UserEntity", in: context)!
                    let newEntity = UserEntity(entity: entityDesc, insertInto: context)
                    newEntity.apply(from: user)
                }
            }
            
            // Delete entities not present in the incoming list
            for (_, entity) in existingByID { context.delete(entity) }
            
            if context.hasChanges { try context.save() }
        }
    }
    
    func saveCurrentUserID(_ id: UUID?) async throws {
        let defaultsKey = "AuthUsers.currentUserID"
        if let id { UserDefaults.standard.set(id.uuidString, forKey: defaultsKey) }
        else { UserDefaults.standard.removeObject(forKey: defaultsKey) }
    }
}

