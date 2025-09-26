//
//  MockWeatherAPIService.swift
//  TodoApp
//
//  Created by Pratik on 26/09/25.
//

import Foundation

/// Mock weather service that returns a pre-configured result.
final class MockWeatherAPIService: WeatherAPIServiceProtocol {
    var mockedResult: Result<WeatherResponse, Error>

    /// Creates a success-result mock.
    init(mockedWeather: WeatherResponse) {
        self.mockedResult = .success(mockedWeather)
    }

    /// Creates a failure-result mock.
    init(error: Error) {
        self.mockedResult = .failure(error)
    }

    /// Returns either the mocked success or throws the mocked error.
    func fetchCurrentWeather(latitude: Double, longitude: Double) async throws -> WeatherResponse {
        switch mockedResult {
        case .success(let weather):
            return weather
        case .failure(let error):
            throw error
        }
    }
}
