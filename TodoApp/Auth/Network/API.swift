//
//  API.swift
//  TodoApp
//
//  Created by Pratik on 26/09/25.
//

import Moya
import Foundation
import Alamofire

enum API {
    case weather(lat: Double, long: Double)
}

extension API: TargetType {
    
    var method: Moya.Method { return .get }
    
    // This is the base URL we'll be using.
    var baseURL: URL {
        guard let url = URL(string: "https://api.open-meteo.com/") else { fatalError() }
        return url
    }
    
    // This is the path of each operation that will be appended to our base URL.
    var path: String {
        switch self {
        case .weather( _, _):
            "v1/forecast"
        }
    }
    
    // Here we specify body parameters.
    var task: Task {
        switch self {
        case .weather(let lat, let long):
            return .requestParameters(
                parameters: [
                    "latitude": lat,
                    "longitude": long,
                    "hourly": "temperature_2m",
                    "current_weather": "true",
                    "timezone": "auto",
                    "start_date": "2025-09-26", // TODO - Update this date with actual dates
                    "end_date": "2025-09-26"
                ],
                encoding: URLEncoding.default
            )
        }
    }
    
    // These are the headers that our service requires.
    var headers: [String: String]? {
        return [:]
    }
    
    // This is sample return data that we can use to mock and test your services.
    var sampleData: Data {
        return Data()
    }
}
