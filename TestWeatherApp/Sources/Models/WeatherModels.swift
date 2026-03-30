//
//  WeatherModels.swift
//  TestWeatherApp
//
//  Created by Fedor Donskov on 30.03.2026.
//

import Foundation

// MARK: - CurrentResponse
struct CurrentResponse: Codable {
    let location: WeatherLocation?
    let current: CurrentWeather?
}

// MARK: - ForecastResponse
struct ForecastResponse: Codable {
    let location: WeatherLocation?
    let forecast: Forecast?
}

// MARK: - WeatherData
struct WeatherData {
    let current: CurrentResponse
    let forecast: ForecastResponse
}

// MARK: - WeatherLocation
struct WeatherLocation: Codable {
    let name: String?
    let country: String?
    let localtime: String?
}

// MARK: - CurrentWeather
struct CurrentWeather: Codable {
    let tempC: Double?
    let isDay: Int?
    let condition: WeatherCondition?
    let windKph: Double?
    let humidity: Int?
    let feelslikeC: Double?
    let pressureMb: Double?
    let uv: Double?
}

// MARK: - WeatherCondition
struct WeatherCondition: Codable {
    let text: String?
    let code: Int?
}

extension WeatherCondition {
    func sfSymbolName(isDay: Bool) -> String {
        switch code {
        case 1000:
            return isDay ? "sun.max.fill" : "moon.stars.fill"
        case 1003:
            return isDay ? "cloud.sun.fill" : "cloud.moon.fill"
        case 1006:
            return "cloud.fill"
        case 1009:
            return "smoke.fill"
        case 1030, 1135, 1147:
            return "cloud.fog.fill"
        case 1063, 1150, 1153, 1180, 1183, 1240:
            return "cloud.drizzle.fill"
        case 1066, 1210, 1213, 1216, 1219, 1222, 1225, 1255, 1258:
            return "cloud.snow.fill"
        case 1069, 1204, 1207, 1249, 1252:
            return "cloud.sleet.fill"
        case 1072, 1168, 1171, 1237, 1261, 1264:
            return "cloud.hail.fill"
        case 1087, 1279, 1282:
            return "cloud.bolt.fill"
        case 1114, 1117:
            return "wind.snow"
        case 1186, 1189:
            return "cloud.rain.fill"
        case 1192, 1195, 1243, 1246:
            return "cloud.heavyrain.fill"
        case 1198, 1201:
            return "cloud.sleet.fill"
        case 1273, 1276:
            return "cloud.bolt.rain.fill"
        default:
            return "cloud.fill"
        }
    }
}

// MARK: - Forecast
struct Forecast: Codable {
    let forecastday: [ForecastDay]?
}

// MARK: - ForecastDay
struct ForecastDay: Codable {
    let date: String?
    let day: DayWeather?
    let astro: Astro?
    let hour: [HourWeather]?
}

// MARK: - Astro
struct Astro: Codable {
    let sunrise: String?
    let sunset: String?
    let moonPhase: String?
}

// MARK: - DayWeather
struct DayWeather: Codable {
    let maxtempC: Double?
    let mintempC: Double?
    let maxwindKph: Double?
    let totalprecipMm: Double?
    let avghumidity: Int?
    let dailyChanceOfRain: Int?
    let dailyChanceOfSnow: Int?
    let condition: WeatherCondition?
    let uv: Double?
}

// MARK: - HourWeather
struct HourWeather: Codable {
    let time: String?
    let tempC: Double?
    let isDay: Int?
    let condition: WeatherCondition?
    let feelslikeC: Double?
    let windKph: Double?
    let windDir: String?
    let humidity: Int?
    let pressureMb: Double?
    let chanceOfRain: Int?
    let chanceOfSnow: Int?
    let precipMm: Double?
    let uv: Double?
}
