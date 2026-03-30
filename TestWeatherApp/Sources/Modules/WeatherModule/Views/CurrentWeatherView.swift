//
//  CurrentWeatherView.swift
//  TestWeatherApp
//
//  Created by Fedor Donskov on 30.03.2026.
//

import UIKit

// MARK: - CurrentWeatherView
final class CurrentWeatherView: UIView {

    // MARK: - UI Elements
    private let cityLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 34, weight: .regular)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()

    private let temperatureLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 96, weight: .thin)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()

    private let conditionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .medium)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()

    private let highLowLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .medium)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()

    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup
    private func setupUI() {
        let stack = UIStackView(arrangedSubviews: [cityLabel, temperatureLabel, conditionLabel, highLowLabel])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 4
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)
        ])
    }

    // MARK: - Configure
    func configure(with data: WeatherData) {
        cityLabel.text = data.current.location?.name ?? ""
        temperatureLabel.text = "\(Int((data.current.current?.tempC ?? 0).rounded()))°"
        conditionLabel.text = (data.current.current?.condition?.text ?? "").trimmingCharacters(in: .whitespaces)

        if let today = (data.forecast.forecast?.forecastday ?? []).first {
            highLowLabel.text = LocalizationManager.shared.localizedString(
                for: "weather.high_low",
                Int((today.day?.maxtempC ?? 0).rounded()),
                Int((today.day?.mintempC ?? 0).rounded())
            )
        }
    }
}
