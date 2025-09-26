//
//  WeatherAPIServiceProtocol.swift
//  TodoApp
//
//  Created by Pratik on 26/09/25.
//

import Foundation

protocol WeatherAPIServiceProtocol {
    func fetchCurrentWeather(latitude: Double, longitude: Double) async throws -> WeatherResponse
}
