//
//  WeatherResponse.swift
//  TodoApp
//
//  Created by Pratik on 25/09/25.
//

import Foundation

struct WeatherResponse: Codable {
    let current_weather: CurrentWeather
    let hourly: HourlyData?
}

struct CurrentWeather: Codable {
    let temperature: Double?
    let windspeed: Double?
    let winddirection: Double?
    let weathercode: Int?
    let time: String?
}

struct HourlyData: Codable {
    let time: [String]?
    let temperature_2m: [Double]?
}
