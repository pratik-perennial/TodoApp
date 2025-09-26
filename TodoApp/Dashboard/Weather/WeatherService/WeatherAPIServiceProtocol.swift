//
//  WeatherAPIServiceProtocol.swift
//  TodoApp
//
//  Created by Pratik on 26/09/25.
//

import Foundation

/// Abstraction for fetching weather data.
protocol WeatherAPIServiceProtocol {
    /// Fetches current weather for the given coordinates.
    /// - Parameters:
    ///   - latitude: Latitude in degrees.
    ///   - longitude: Longitude in degrees.
    func fetchCurrentWeather(latitude: Double, longitude: Double) async throws -> WeatherResponse
}
