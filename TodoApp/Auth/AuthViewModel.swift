//
//  AuthViewModel.swift
//  TodoApp
//
//  Created by Pratik on 25/09/25.
//

import Foundation
import Combine

/// View model for authentication: manages users and active session.
final class AuthViewModel: ObservableObject {
    private let service: AuthServiceProtocol

    // Published state for the view
    @Published private(set) var users: [User] = []
    @Published private(set) var currentUser: User?

    private var cancellables: Set<AnyCancellable> = []

    /// Creates the view model and binds to the provided service.
    init(service: AuthServiceProtocol = CoreDataAuthService.shared) {
        self.service = service
        bind()
        service.loadUsers()
    }

    /// Subscribes to service publishers and seeds current values.
    private func bind() {
        service.usersPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.users = $0 }
            .store(in: &cancellables)

        service.currentUserPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.currentUser = $0 }
            .store(in: &cancellables)

        // seed current values
        self.users = service.users
        self.currentUser = service.currentUser
    }

    /// Creates a user with password if provided.
    func createUser(username: String, avatarData: Data?, password: String?) {
        if let password, !password.isEmpty {
            service.createUser(username: username, avatarData: avatarData, password: password)
        }
    }

    @discardableResult
    /// Requests a user switch without password, returns true if the target differs.
    func requestSwitch(to id: UUID) -> Bool {
        let before = currentUser?.id
        service.switchUser(to: id)
        return before != service.currentUser?.id
    }

    /// Confirms a user switch with password.
    func confirmSwitch(to id: UUID, password: String) -> Bool {
        service.switchUser(to: id, password: password)
    }

    /// Deletes the given user from the service.
    func deleteUser(_ user: User) {
        service.deleteUser(user)
    }
}
