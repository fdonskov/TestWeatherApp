//
//  NetworkWeatherService.swift
//  TestWeatherApp
//
//  Created by Fedor Donskov on 30.03.2026.
//

import Foundation

// MARK: - WeatherError
enum WeatherError: LocalizedError {
    case invalidURL
    case noData
    case serverError(Int)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return LocalizationManager.shared.localizedString(for: "error.invalid_url")
        case .noData:
            return LocalizationManager.shared.localizedString(for: "error.no_data")
        case .serverError(let code):
            return LocalizationManager.shared.localizedString(for: "error.server", code)
        }
    }
}

// MARK: - NetworkWeatherService
final class NetworkWeatherService {

    private let apiKey = "fa8b3df74d4042b9aa7135114252304"
    private let baseURL = "https://api.weatherapi.com/v1"

    func fetchWeather(lat: Double, lon: Double, completion: @escaping (Result<WeatherData, Error>) -> Void) {
        let lang = Locale.current.language.languageCode?.identifier ?? "en"
        let currentURL = "\(baseURL)/current.json?key=\(apiKey)&q=\(lat),\(lon)&lang=\(lang)"
        let forecastURL = "\(baseURL)/forecast.json?key=\(apiKey)&q=\(lat),\(lon)&days=3&lang=\(lang)"

        let group = DispatchGroup()
        var currentResult: Result<CurrentResponse, Error>?
        var forecastResult: Result<ForecastResponse, Error>?

        group.enter()
        performRequest(urlString: currentURL) { (result: Result<CurrentResponse, Error>) in
            currentResult = result
            group.leave()
        }

        group.enter()
        performRequest(urlString: forecastURL) { (result: Result<ForecastResponse, Error>) in
            forecastResult = result
            group.leave()
        }

        group.notify(queue: .main) {
            guard let current = currentResult, let forecast = forecastResult else {
                completion(.failure(WeatherError.noData))
                return
            }

            switch (current, forecast) {
            case (.success(let currentResponse), .success(let forecastResponse)):
                completion(.success(WeatherData(current: currentResponse, forecast: forecastResponse)))
            case (.failure(let error), _), (_, .failure(let error)):
                completion(.failure(error))
            }
        }
    }

    private func performRequest<T: Decodable>(urlString: String, completion: @escaping (Result<T, Error>) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(.failure(WeatherError.invalidURL))
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
                completion(.failure(WeatherError.serverError(httpResponse.statusCode)))
                return
            }

            guard let data = data else {
                completion(.failure(WeatherError.noData))
                return
            }

            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let decoded = try decoder.decode(T.self, from: data)
                completion(.success(decoded))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
