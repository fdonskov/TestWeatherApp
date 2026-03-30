//
//  LocalizationManager.swift
//  TestWeatherApp
//
//  Created by Fedor Donskov on 30.03.2026.
//

import Foundation

// MARK: - LocalizationManager
final class LocalizationManager {

    static let shared = LocalizationManager()

    private init() {}

    func localizedString(for key: String) -> String {
        Bundle.main.localizedString(forKey: key, value: nil, table: nil)
    }

    func localizedString(for key: String, _ arguments: CVarArg...) -> String {
        let format = localizedString(for: key)
        return String(format: format, arguments: arguments)
    }
}
