//
//  DailyDetailViewController.swift
//  TestWeatherApp
//
//  Created by Fedor Donskov on 30.03.2026.
//

import UIKit

// MARK: - DailyDetailViewController
final class DailyDetailViewController: UIViewController {

    // MARK: - Properties
    private let forecastDays: [ForecastDay]
    private let gradientLayer = CAGradientLayer()

    private lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.backgroundColor = .clear
        tv.separatorStyle = .none
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.dataSource = self
        tv.register(DailyDetailCell.self, forCellReuseIdentifier: DailyDetailCell.reuseID)
        return tv
    }()

    // MARK: - Initialization
    init(weatherData: WeatherData) {
        self.forecastDays = weatherData.forecast.forecast?.forecastday ?? []
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
        title = LocalizationManager.shared.localizedString(for: "weather.daily_forecast")
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

    private func dayName(for index: Int) -> String {
        if index == 0 {
            return LocalizationManager.shared.localizedString(for: "weather.today")
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let displayFormatter = DateFormatter()
        displayFormatter.locale = Locale.current
        displayFormatter.dateFormat = "EEEE"
        if let date = dateFormatter.date(from: forecastDays[index].date ?? "") {
            return displayFormatter.string(from: date).capitalized
        }
        return forecastDays[index].date ?? ""
    }
}

// MARK: - UITableViewDataSource
extension DailyDetailViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        forecastDays.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: DailyDetailCell.reuseID, for: indexPath) as? DailyDetailCell else {
            return UITableViewCell()
        }
        let day = forecastDays[indexPath.row]
        cell.configure(with: day, dayName: dayName(for: indexPath.row))
        return cell
    }
}
