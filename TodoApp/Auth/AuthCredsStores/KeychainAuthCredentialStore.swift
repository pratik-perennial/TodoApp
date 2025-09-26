//
//  KeychainAuthCredentialStore.swift
//  TodoApp
//
//  Created by Pratik on 25/09/25.
//

import Foundation
import Security

/// Keychain-backed implementation of AuthCredentialStore
struct KeychainAuthCredentialStore: AuthCredentialStore {
    private func service() -> String { Bundle.main.bundleIdentifier ?? "TodoApp" }

    func setPassword(_ password: String, for userID: UUID) throws {
        let account = userID.uuidString
        let data = Data(password.utf8)

        // Delete any existing item first
        try? deletePassword(for: userID)

        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service(),
            kSecAttrAccount: account,
            kSecValueData: data,
            kSecAttrAccessible: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        ]

        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else { throw AuthCredentialError.underlying(status) }
    }

    func validatePassword(_ password: String, for userID: UUID) throws -> Bool {
        let account = userID.uuidString
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service(),
            kSecAttrAccount: account,
            kSecReturnData: true,
            kSecMatchLimit: kSecMatchLimitOne
        ]

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        if status == errSecItemNotFound { return false }
        guard status == errSecSuccess else { throw AuthCredentialError.underlying(status) }
        guard let data = item as? Data else { throw AuthCredentialError.unexpectedData }
        let stored = String(decoding: data, as: UTF8.self)
        return stored == password
    }

    func hasPassword(for userID: UUID) throws -> Bool {
        let account = userID.uuidString
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service(),
            kSecAttrAccount: account,
            kSecReturnAttributes: true,
            kSecMatchLimit: kSecMatchLimitOne
        ]

        let status = SecItemCopyMatching(query as CFDictionary, nil)
        if status == errSecItemNotFound { return false }
        guard status == errSecSuccess else { throw AuthCredentialError.underlying(status) }
        return true
    }

    func deletePassword(for userID: UUID) throws {
        let account = userID.uuidString
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service(),
            kSecAttrAccount: account
        ]
        let status = SecItemDelete(query as CFDictionary)
        if status == errSecItemNotFound { return }
        guard status == errSecSuccess else { throw AuthCredentialError.underlying(status) }
    }
}
