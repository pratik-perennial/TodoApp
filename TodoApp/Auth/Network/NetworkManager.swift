//
//  APIService.swift
//  TodoApp
//
//  Created by Pratik on 26/09/25.
//

import Moya
import Foundation

class NetworkManager {
    var provider = MoyaProvider<API>(plugins: [NetworkLoggerPlugin()])
    
    func fetchWeather(lat: Double, long: Double) async throws -> WeatherResponse {
        try await request(target: .weather(lat: lat, long: long))
    }
}

private extension NetworkManager {
    func request<T: Decodable>(target: API) async throws -> T {
        try await withCheckedThrowingContinuation { continuation in
            provider.request(target) { result in
                switch result {
                case .success(let response):
                    do {
                        let value = try JSONDecoder().decode(T.self, from: response.data)
                        continuation.resume(returning: value)
                    } catch {
                        continuation.resume(throwing: error)
                    }
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}
