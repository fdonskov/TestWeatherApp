//
//  HourlyDetailViewController.swift
//  TestWeatherApp
//
//  Created by Fedor Donskov on 30.03.2026.
//

import UIKit

// MARK: - HourlyDetailViewController
final class HourlyDetailViewController: UIViewController {

    // MARK: - Properties
    private let hours: [HourWeather]
    private let gradientLayer = CAGradientLayer()

    private lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.backgroundColor = .clear
        tv.separatorStyle = .none
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.dataSource = self
        tv.register(HourlyDetailCell.self, forCellReuseIdentifier: HourlyDetailCell.reuseID)
        return tv
    }()

    // MARK: - Initialization
    init(weatherData: WeatherData) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"

        let localtime = weatherData.current.location?.localtime ?? ""
        let currentDate = dateFormatter.date(from: localtime) ?? Date()

        var filtered: [HourWeather] = []
        for (index, day) in (weatherData.forecast.forecast?.forecastday ?? []).enumerated() {
            if index == 0 {
                for hour in day.hour ?? [] {
                    if let hourDate = dateFormatter.date(from: hour.time ?? ""), hourDate >= currentDate {
                        filtered.append(hour)
                    }
                }
            } else if index == 1 {
                filtered.append(contentsOf: day.hour ?? [])
            }
        }
        self.hours = filtered
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGradient()
        setupNavigation()
        setupTableView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
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
        view.layer.insertSublayer(gradientLayer, at: 0)
    }

    private func setupNavigation() {
        title = LocalizationManager.shared.localizedString(for: "weather.hourly_forecast")
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance

        let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .medium)
        let image = UIImage(systemName: "chevron.backward", withConfiguration: config)
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: image,
            primaryAction: UIAction { [weak self] _ in
                self?.navigationController?.popViewController(animated: true)
            }
        )
        navigationItem.leftBarButtonItem?.tintColor = .white
        navigationItem.hidesBackButton = true
        navigationController?.interactivePopGestureRecognizer?.delegate = nil
    }


    private func setupTableView() {
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

// MARK: - UITableViewDataSource
extension HourlyDetailViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        hours.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: HourlyDetailCell.reuseID, for: indexPath) as? HourlyDetailCell else {
            return UITableViewCell()
        }
        cell.configure(with: hours[indexPath.row])
        return cell
    }
}
