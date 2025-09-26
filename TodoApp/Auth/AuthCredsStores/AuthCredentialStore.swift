//
//  AuthCredentialStore.swift
//  TodoApp
//
//  Created by Pratik on 25/09/25.
//

import Foundation

/// Abstraction for securely storing and validating user credentials
protocol AuthCredentialStore {
    func setPassword(_ password: String, for userID: UUID) throws
    func validatePassword(_ password: String, for userID: UUID) throws -> Bool
    func hasPassword(for userID: UUID) throws -> Bool
    func deletePassword(for userID: UUID) throws
}

enum AuthCredentialError: Error, LocalizedError {
    case notFound
    case unexpectedData
    case underlying(OSStatus)

    var errorDescription: String? {
        switch self {
        case .notFound: return "Credential not found"
        case .unexpectedData: return "Unexpected credential data"
        case .underlying(let status): return "Keychain error: \(status)"
        }
    }
}
