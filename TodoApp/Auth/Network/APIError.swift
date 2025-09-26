//
//  APIError.swift
//  TodoApp
//
//  Created by Pratik on 26/09/25.
//


enum APIError: Error {
    case invalidURL
    case networkError(Error)
    case decodingError(Error)
    case noData
}
