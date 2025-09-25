//
//  UserDefaults.swift
//  TodoApp
//
//  Created by Pratik on 25/09/25.
//

import Foundation

extension UserDefaults {
    func setObject<Element: Codable>(_ object: Element, forKey key: String) {
        let data = try? JSONEncoder().encode(object)
        set(data, forKey: key)
    }

    func getObject<Element: Codable>(forKey key: String, castTo type: Element.Type) -> Element? {
        guard let data = data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(type, from: data)
    }
}
