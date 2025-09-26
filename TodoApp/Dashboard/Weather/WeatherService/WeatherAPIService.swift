//
//  WeatherAPIService.swift
//  TodoApp
//
//  Created by Pratik on 25/09/25.
//


import Foundation

/// Live implementation of `WeatherAPIServiceProtocol` using the app's `NetworkManager`.
final class WeatherAPIService: WeatherAPIServiceProtocol {
    /// Fetches and decodes current weather for the given coordinates.
    func fetchCurrentWeather(latitude: Double, longitude: Double) async throws -> WeatherResponse {
        do {
            let weatherResponse = try await NetworkManager().fetchWeather(lat: latitude, long: longitude)
            return weatherResponse
        } catch {
            if let urlError = error as? URLError {
                throw APIError.networkError(urlError)
            } else if let decodingError = error as? DecodingError {
                throw APIError.decodingError(decodingError)
            } else {
                throw error
            }
        }
    }
}
