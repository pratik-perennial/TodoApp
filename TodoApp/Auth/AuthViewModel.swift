//
//  AuthViewModel.swift
//  TodoApp
//
//  Created by Pratik on 25/09/25.
//

import Foundation
import Combine

final class AuthViewModel: ObservableObject {
    private let service: AuthServiceProtocol

    // Published state for the view
    @Published private(set) var users: [User] = []
    @Published private(set) var currentUser: User?

    private var cancellables: Set<AnyCancellable> = []

    init(service: AuthServiceProtocol = CoreDataAuthService.shared) {
        self.service = service
        bind()
        service.loadUsers()
    }

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

    func createUser(username: String, avatarData: Data?, password: String?) {
        if let password, !password.isEmpty {
            service.createUser(username: username, avatarData: avatarData, password: password)
        } else {
            // TODO:  Handle else 
            //manager.createUser(username: username, avatarData: avatarData)
        }
    }

    @discardableResult
    func requestSwitch(to id: UUID) -> Bool {
        let before = currentUser?.id
        service.switchUser(to: id)
        return before != service.currentUser?.id
    }

    func confirmSwitch(to id: UUID, password: String) -> Bool {
        service.switchUser(to: id, password: password)
    }

    func deleteUser(_ user: User) {
        service.deleteUser(user)
    }
}
