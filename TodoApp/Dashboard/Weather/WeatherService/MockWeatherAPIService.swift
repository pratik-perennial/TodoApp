//
//  MockWeatherAPIService.swift
//  TodoApp
//
//  Created by Pratik on 26/09/25.
//

import Foundation

final class MockWeatherAPIService: WeatherAPIServiceProtocol {
    var mockedResult: Result<WeatherResponse, Error>

    init(mockedWeather: WeatherResponse) {
        self.mockedResult = .success(mockedWeather)
    }

    init(error: Error) {
        self.mockedResult = .failure(error)
    }

    func fetchCurrentWeather(latitude: Double, longitude: Double) async throws -> WeatherResponse {
        switch mockedResult {
        case .success(let weather):
            return weather
        case .failure(let error):
            throw error
        }
    }
}
