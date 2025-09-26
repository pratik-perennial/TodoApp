//
//  CurrentWeatherView.swift
//  TodoApp
//
//  Created by Pratik on 25/09/25.
//

import SwiftUI

struct CurrentWeatherView: View {
    let weather: WeatherResponse
    
    private var currentWeather: CurrentWeather {
        weather.current_weather
    }
    
    var body: some View {
        VStack(spacing: 12) {
            HStack(alignment: .center, spacing: 16) {
                VStack(alignment: .leading, spacing: 6) {
                    weatherIcon
                        .font(.system(size: 48))
                        .foregroundColor(.blue)
                    
                    windView
                }
                Spacer()
                VStack(alignment: .leading, spacing: 6) {
                    Text("\(Int(currentWeather.temperature ?? 23))°C")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text(weatherConditionDescription)
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
                
            }
            
            if let times = weather.hourly?.time,
               let temps = weather.hourly?.temperature_2m,
               times.count == temps.count, temps.count > 0 {
                
                // Find current hour index (using ISO8601DateFormatter)
                let currentHourIndex: Int? = {
                    let now = Date()
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm"
                    formatter.locale = Locale(identifier: "en_US_POSIX")
                    return times.firstIndex(where: { timeStr in
                        if let date = formatter.date(from: timeStr) {
                            // Compare only hour components ignoring minutes/seconds
                            let calendar = Calendar.current
                            return calendar.component(.hour, from: date) == calendar.component(.hour, from: now)
                            && calendar.component(.day, from: date) == calendar.component(.day, from: now)
                            && calendar.component(.month, from: date) == calendar.component(.month, from: now)
                            && calendar.component(.year, from: date) == calendar.component(.year, from: now)
                        }
                        return false
                    })
                }()
                
                ScrollViewReader { proxy in
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(0..<temps.count, id: \.self) { i in
                                VStack(spacing: 6) {
                                    Text("\(Int(temps[i]))°")
                                        .font(.title2.bold())
                                        .foregroundColor(i == currentHourIndex ? .yellow : .white) // highlight text color
                                    
                                    Text(formattedHour(times[i]))
                                        .font(.caption)
                                        .foregroundColor(i == currentHourIndex ? .yellow.opacity(0.9) : .white.opacity(0.8))
                                }
                                .padding(.vertical, 6)
                                .frame(width: 40)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(i == currentHourIndex ? Color.black.opacity(0.4) : Color.blue.opacity(0.3))
                                )
                                .id(i) // named id for scroll target
                            }
                        }
                    }
                    .onAppear {
                        if let index = currentHourIndex {
                            withAnimation {
                                proxy.scrollTo(index, anchor: .center)
                            }
                        }
                    }
                }
            }
            
            
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.blue)
        )
        .padding(.horizontal)
    }
    
    
    private func formattedHour(_ isoString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        if let date = formatter.date(from: isoString) {
            let hourFmt = DateFormatter()
            hourFmt.dateFormat = "h a"
            hourFmt.amSymbol = "AM"
            hourFmt.pmSymbol = "PM"
            return hourFmt.string(from: date)
        }
        // fallback if parsing fails
        if let hour = isoString.split(separator: "T").last {
            return String(hour)
        }
        return isoString
    }

    private var weatherConditionDescription: String {
        mapWeatherCodeToDescription(currentWeather.weathercode)
    }
    
    private var weatherIcon: some View {
        Image(systemName: weatherIconName(from: currentWeather.weathercode))
            .renderingMode(.original)
    }
    
    private var windView: some View {
        HStack(spacing: 4) {
            Image(systemName: "wind")
                .foregroundColor(.primary)
            Text("\(Int(currentWeather.windspeed ?? 0)) km/h")
                .font(.subheadline)
            if let dir = currentWeather.winddirection {
                Image(systemName: directionToArrowName(direction: dir))
                    .rotationEffect(.degrees(dir))
                    .foregroundColor(.primary)
                    .frame(width: 16, height: 16)
            }
        }
    }
    
    // Helpers
    
    private func iso8601Date(from string: String) -> Date? {
        let formatter = ISO8601DateFormatter()
        return formatter.date(from: string)
    }
    
    private var shortTimeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }
    
    private func weatherIconName(from code: Int?) -> String {
        // A few example mappings for Open-Meteo weathercodes (add more as needed)
        switch code {
        case 0: return "sun.max.fill"  // Clear sky
        case 1, 2, 3: return "cloud.sun.fill"  // Mainly clear, partly cloudy
        case 45, 48: return "cloud.fog.fill"  // Fog
        case 51, 53, 55: return "cloud.drizzle.fill"  // Drizzle
        case 61, 63, 65: return "cloud.rain.fill"  // Rain
        case 71, 73, 75: return "snow"  // Snow
        case 80, 81, 82: return "cloud.heavyrain.fill"  // Heavy rain showers
        case 95, 96, 99: return "cloud.bolt.fill"  // Thunderstorms
        default: return "questionmark"
        }
    }
    
    private func mapWeatherCodeToDescription(_ code: Int?) -> String {
        switch code {
        case 0: return "Clear Sky"
        case 1: return "Mainly Clear"
        case 2: return "Partly Cloudy"
        case 3: return "Overcast"
        case 45, 48: return "Fog"
        case 51, 53, 55: return "Drizzle"
        case 61, 63, 65: return "Rain"
        case 71, 73, 75: return "Snow"
        case 80, 81, 82: return "Showers"
        case 95, 96, 99: return "Thunderstorms"
        default: return "Unknown"
        }
    }
    
    private func directionToArrowName(direction: Double) -> String {
        // Use a simple fixed arrow pointing up, rotate by direction
        "arrow.up"
    }
}

#Preview {
    CurrentWeatherView(
        weather: WeatherResponse(
            current_weather: CurrentWeather(
                temperature: 29.0,
                windspeed: 20,
                winddirection: 1.0,
                weathercode: 1,
                time: ""
            ),
            hourly: HourlyData(
                time: [
                    "2025-09-26T00:00", "2025-09-26T01:00", "2025-09-26T02:00",
                    "2025-09-26T03:00", "2025-09-26T04:00", "2025-09-26T05:00",
                    "2025-09-26T06:00", "2025-09-26T07:00", "2025-09-26T08:00",
                    "2025-09-26T09:00", "2025-09-26T10:00", "2025-09-26T11:00",
                    "2025-09-26T12:00", "2025-09-26T13:00", "2025-09-26T14:00",
                    "2025-09-26T15:00", "2025-09-26T16:00", "2025-09-26T17:00",
                    "2025-09-26T18:00", "2025-09-26T19:00", "2025-09-26T20:00",
                    "2025-09-26T21:00", "2025-09-26T22:00", "2025-09-26T23:00",
                ],
                temperature_2m: [
                    15.5, 15.2, 14.5, 14.0, 14.9, 15.0, 14.6, 13.9, 14.4, 16.0,
                    17.3, 20.7, 23.9, 26.4, 26.3, 25.8, 24.4, 23.5, 22.0, 19.7,
                    17.8, 16.7, 16.0, 15.8,
                ]
            )
        )
    )
}
