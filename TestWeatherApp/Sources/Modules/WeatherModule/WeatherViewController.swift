//
//  WeatherViewController.swift
//  TestWeatherApp
//
//  Created by Fedor Donskov on 30.03.2026.
//

import UIKit
import CoreLocation

// MARK: - WeatherViewController
final class WeatherViewController: UIViewController {

    // MARK: - State
    private enum State {
        case loading
        case loaded(WeatherData)
        case error(String)
    }

    // MARK: - Properties
    private var state: State = .loading {
        didSet { updateUI() }
    }

    private let locationService = LocationService()
    private let weatherService = NetworkWeatherService()

    private static let moscowLat = 55.7558
    private static let moscowLon = 37.6173

    // MARK: - UI Elements
    private let gradientLayer = CAGradientLayer()

    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()

    private let contentStack: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 16
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()

    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .white
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()

    private var errorMessage: String = ""

    private let currentWeatherView = CurrentWeatherView()
    private let hourlyForecastView = HourlyForecastView()
    private let dailyForecastView = DailyForecastView()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGradient()
        setupScrollView()
        setupLoadingView()
        fetchWeather()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = view.bounds
    }

    // MARK: - Setup
    private func setupGradient() {
        gradientLayer.colors = [
            UIColor(red: 0.30, green: 0.55, blue: 0.85, alpha: 1).cgColor,
            UIColor(red: 0.18, green: 0.35, blue: 0.65, alpha: 1).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        view.layer.insertSublayer(gradientLayer, at: 0)
    }

    private func setupScrollView() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentStack)

        contentStack.addArrangedSubview(currentWeatherView)
        contentStack.addArrangedSubview(hourlyForecastView)
        contentStack.addArrangedSubview(dailyForecastView)

        hourlyForecastView.onTap = { [weak self] in
            guard let self else { return }
            
            guard case .loaded(let data) = self.state else { return }
            let vc = HourlyDetailViewController(weatherData: data)
            self.navigationController?.pushViewController(vc, animated: true)
        }

        dailyForecastView.onTap = { [weak self] in
            guard let self else { return }
            
            guard case .loaded(let data) = self.state else { return }
            let vc = DailyDetailViewController(weatherData: data)
            self.navigationController?.pushViewController(vc, animated: true)
        }

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentStack.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -32),
            contentStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -32)
        ])

        scrollView.isHidden = true
    }

    private func setupLoadingView() {
        view.addSubview(loadingIndicator)
        NSLayoutConstraint.activate([
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func applyErrorConfiguration(_ message: String) {
        var config = UIContentUnavailableConfiguration.empty()
        config.image = UIImage(systemName: "wifi.exclamationmark")
        config.imageProperties.tintColor = .white

        config.text = LocalizationManager.shared.localizedString(for: "error.title")
        config.textProperties.color = .white
        config.textProperties.font = .systemFont(ofSize: 22, weight: .semibold)

        config.secondaryText = message
        config.secondaryTextProperties.color = UIColor.white.withAlphaComponent(0.7)
        config.secondaryTextProperties.font = .systemFont(ofSize: 15, weight: .regular)

        var buttonConfig = UIButton.Configuration.filled()
        buttonConfig.baseBackgroundColor = UIColor.white.withAlphaComponent(0.2)
        buttonConfig.baseForegroundColor = .white
        buttonConfig.title = LocalizationManager.shared.localizedString(for: "weather.retry")
        buttonConfig.cornerStyle = .medium

        config.button = buttonConfig
        config.buttonProperties.primaryAction = UIAction { [weak self] _ in
            guard let self else { return }
            
            self.fetchWeather()
        }

        contentUnavailableConfiguration = config
    }

    private func clearErrorConfiguration() {
        contentUnavailableConfiguration = nil
    }

    // MARK: - Actions
    @objc private func retryTapped() {
        fetchWeather()
    }

    // MARK: - Data Loading
    private func fetchWeather() {
        state = .loading

        locationService.requestLocation { [weak self] result in
            guard let self else { return }

            let lat: Double
            let lon: Double

            switch result {
            case .success(let coordinate):
                lat = coordinate.latitude
                lon = coordinate.longitude
            case .failure:
                lat = Self.moscowLat
                lon = Self.moscowLon
            }

            self.weatherService.fetchWeather(lat: lat, lon: lon) { [weak self] result in
                guard let self else { return }
                
                switch result {
                case .success(let data):
                    self.state = .loaded(data)
                case .failure(let error):
                    self.state = .error(error.localizedDescription)
                }
            }
        }
    }

    // MARK: - State Updates
    private func updateUI() {
        switch state {
        case .loading:
            loadingIndicator.startAnimating()
            scrollView.isHidden = true
            clearErrorConfiguration()

        case .loaded(let data):
            loadingIndicator.stopAnimating()
            scrollView.isHidden = false
            clearErrorConfiguration()

            currentWeatherView.configure(with: data)
            hourlyForecastView.configure(with: data)
            dailyForecastView.configure(with: data)

        case .error(let message):
            loadingIndicator.stopAnimating()
            scrollView.isHidden = true
            applyErrorConfiguration(message)
        }
    }
}
