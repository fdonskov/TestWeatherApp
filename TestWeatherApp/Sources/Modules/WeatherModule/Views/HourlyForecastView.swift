//
//  HourlyForecastView.swift
//  TestWeatherApp
//
//  Created by Fedor Donskov on 30.03.2026.
//

import UIKit

// MARK: - HourlyForecastView
final class HourlyForecastView: UIView {

    // MARK: - Properties
    var onTap: (() -> Void)?
    private var hours: [HourWeather] = []

    // MARK: - UI Elements
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = UIColor.white.withAlphaComponent(0.7)
        return label
    }()

    private let clockIcon: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "clock"))
        imageView.tintColor = UIColor.white.withAlphaComponent(0.7)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let separator: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white.withAlphaComponent(0.3)
        return view
    }()

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 60, height: 100)
        layout.minimumInteritemSpacing = 4
        layout.minimumLineSpacing = 4

        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.showsHorizontalScrollIndicator = false
        cv.register(HourlyCell.self, forCellWithReuseIdentifier: HourlyCell.reuseID)
        cv.dataSource = self
        return cv
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
    @objc private func handleTap() {
        onTap?()
    }

    private func setupUI() {
        backgroundColor = UIColor.white.withAlphaComponent(0.15)
        layer.cornerRadius = 12

        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tap)

        titleLabel.text = LocalizationManager.shared.localizedString(for: "weather.hourly_forecast")

        let titleStack = UIStackView(arrangedSubviews: [clockIcon, titleLabel])
        titleStack.axis = .horizontal
        titleStack.spacing = 4
        titleStack.alignment = .center

        [titleStack, separator, collectionView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }

        NSLayoutConstraint.activate([
            clockIcon.widthAnchor.constraint(equalToConstant: 14),
            clockIcon.heightAnchor.constraint(equalToConstant: 14),

            titleStack.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            titleStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),

            separator.topAnchor.constraint(equalTo: titleStack.bottomAnchor, constant: 8),
            separator.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            separator.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            separator.heightAnchor.constraint(equalToConstant: 0.5),

            collectionView.topAnchor.constraint(equalTo: separator.bottomAnchor, constant: 8),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            collectionView.heightAnchor.constraint(equalToConstant: 100)
        ])
    }

    // MARK: - Configure
    func configure(with data: WeatherData) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"

        guard let currentDate = dateFormatter.date(from: data.current.location?.localtime ?? "") else { return }

        var filteredHours: [HourWeather] = []

        for (index, day) in (data.forecast.forecast?.forecastday ?? []).enumerated() {
            if index == 0 {
                for hour in day.hour ?? [] {
                    if let hourDate = dateFormatter.date(from: hour.time ?? ""), hourDate >= currentDate {
                        filteredHours.append(hour)
                    }
                }
            } else if index == 1 {
                filteredHours.append(contentsOf: day.hour ?? [])
            }
        }

        self.hours = filteredHours
        collectionView.reloadData()
    }
}

// MARK: - UICollectionViewDataSource
extension HourlyForecastView: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        hours.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HourlyCell.reuseID, for: indexPath) as? HourlyCell else {
            return UICollectionViewCell()
        }
        let hour = hours[indexPath.item]
        let isNow = indexPath.item == 0
        cell.configure(with: hour, isNow: isNow)
        return cell
    }
}
