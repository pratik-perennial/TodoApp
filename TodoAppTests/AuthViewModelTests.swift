//
//  AuthViewModelTests.swift
//  TodoAppTests
//
//  Created by Pratik on 25/09/25.
//

import XCTest
import Combine
@testable import TodoApp

@MainActor
final class AuthViewModelTests: XCTestCase {
    var viewModel: AuthViewModel!
    var mockService: MockAuthService!
    var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        mockService = MockAuthService()
        cancellables = []
        viewModel = AuthViewModel(service: mockService)
    }

    func testLoadUsersPopulatesInitialUsersAndCurrentUser() {
        // Initially, mockService populates with sample users and first selected user
        let expectationUsers = expectation(description: "Users populated")
        let expectationCurrentUser = expectation(description: "Current user set")

        viewModel.$users
            .dropFirst() // Ignore initial empty array
            .sink { users in
                if users.count == 3 {
                    expectationUsers.fulfill()
                }
            }
            .store(in: &cancellables)

        viewModel.$currentUser
            .dropFirst() // Ignore initial nil
            .sink { currentUser in
                if currentUser?.username == "Alice" {
                    expectationCurrentUser.fulfill()
                }
            }
            .store(in: &cancellables)

        mockService.loadUsers() // explicitly call to load sample users

        wait(for: [expectationUsers, expectationCurrentUser], timeout: 1)
    }

    func testCreateUserAddsAndSelectsUser() {
        let expUsers = expectation(description: "Users updated")
        let expCurrentUser = expectation(description: "Current user updated")

        viewModel.$users.dropFirst().sink { users in
            if users.contains(where: { $0.username == "Test User" }) {
                expUsers.fulfill()
            }
        }
        .store(in: &cancellables)

        viewModel.$currentUser.dropFirst().sink { currentUser in
            if currentUser?.username == "Test User" {
                expCurrentUser.fulfill()
            }
        }
        .store(in: &cancellables)

        viewModel.createUser(username: "Test User", avatarData: nil, password: "password")

        wait(for: [expUsers, expCurrentUser], timeout: 1)
        XCTAssertTrue(viewModel.users.contains(where: { $0.username == "Test User" }))
        XCTAssertEqual(viewModel.currentUser?.username, "Test User")
    }

    func testRequestSwitchReturnsTrueWhenSwitchingUser() {
        // Setup with sample users loaded by mockService automatically
        mockService.loadUsers()
        //viewModel = AuthViewModel(service: mockService)

        let userToSwitch = viewModel.users.last!
        let originalCurrentUser = viewModel.currentUser

        let result = viewModel.requestSwitch(to: userToSwitch.id)
        XCTAssertTrue(result)
        XCTAssertNotEqual(originalCurrentUser?.id, viewModel.currentUser?.id)
        XCTAssertEqual(viewModel.currentUser, userToSwitch)
    }

    func testRequestSwitchReturnsFalseWhenNoChange() {
        mockService.loadUsers()
        //viewModel = AuthViewModel(service: mockService)

        let currentUser = viewModel.currentUser!

        let result = viewModel.requestSwitch(to: currentUser.id)
        XCTAssertFalse(result)
        XCTAssertEqual(viewModel.currentUser, currentUser)
    }

    func testConfirmSwitchAlwaysReturnsTrue() {
        mockService.loadUsers()
        //viewModel = AuthViewModel(service: mockService)

        let userToSwitch = viewModel.users.last!
        let result = viewModel.confirmSwitch(to: userToSwitch.id, password: "any_password")
        XCTAssertTrue(result)
        XCTAssertEqual(viewModel.currentUser, userToSwitch)
    }

    func testDeleteUserRemovesUserAndUpdatesCurrentUser() {
        mockService.loadUsers()
        //viewModel = AuthViewModel(service: mockService)

        let userToDelete = viewModel.users.first!
        viewModel.deleteUser(userToDelete)

        XCTAssertFalse(viewModel.users.contains(where: { $0.id == userToDelete.id }))
        XCTAssertNotEqual(viewModel.currentUser?.id, userToDelete.id)
        XCTAssertEqual(viewModel.currentUser, viewModel.users.first)
    }
}

