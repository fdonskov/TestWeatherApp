//
//  DailyForecastView.swift
//  TestWeatherApp
//
//  Created by Fedor Donskov on 30.03.2026.
//

import UIKit

// MARK: - DailyForecastView
final class DailyForecastView: UIView {

    // MARK: - Properties
    var onTap: (() -> Void)?

    // MARK: - UI Elements
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = UIColor.white.withAlphaComponent(0.7)
        return label
    }()

    private let calendarIcon: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "calendar"))
        imageView.tintColor = UIColor.white.withAlphaComponent(0.7)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let topSeparator: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white.withAlphaComponent(0.3)
        return view
    }()

    private let stackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 0
        return sv
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

        titleLabel.text = LocalizationManager.shared.localizedString(for: "weather.daily_forecast")

        let titleStack = UIStackView(arrangedSubviews: [calendarIcon, titleLabel])
        titleStack.axis = .horizontal
        titleStack.spacing = 4
        titleStack.alignment = .center

        [titleStack, topSeparator, stackView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }

        NSLayoutConstraint.activate([
            calendarIcon.widthAnchor.constraint(equalToConstant: 14),
            calendarIcon.heightAnchor.constraint(equalToConstant: 14),

            titleStack.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            titleStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),

            topSeparator.topAnchor.constraint(equalTo: titleStack.bottomAnchor, constant: 8),
            topSeparator.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            topSeparator.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            topSeparator.heightAnchor.constraint(equalToConstant: 0.5),

            stackView.topAnchor.constraint(equalTo: topSeparator.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    // MARK: - Configure
    func configure(with data: WeatherData) {
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        let displayFormatter = DateFormatter()
        displayFormatter.locale = Locale.current
        displayFormatter.dateFormat = "EE"

        let days = data.forecast.forecast?.forecastday ?? []

        let globalMin = days.map { $0.day?.mintempC ?? 0 }.min() ?? 0
        let globalMax = days.map { $0.day?.maxtempC ?? 0 }.max() ?? 1

        for (index, day) in days.enumerated() {
            let dayName: String
            if index == 0 {
                dayName = LocalizationManager.shared.localizedString(for: "weather.today")
            } else if let date = dateFormatter.date(from: day.date ?? "") {
                dayName = displayFormatter.string(from: date).capitalized
            } else {
                dayName = day.date ?? ""
            }

            let row = createRow(
                dayName: dayName,
                condition: day.day?.condition ?? WeatherCondition(text: "", code: nil),
                low: Int((day.day?.mintempC ?? 0).rounded()),
                high: Int((day.day?.maxtempC ?? 0).rounded()),
                globalMin: globalMin,
                globalMax: globalMax
            )
            stackView.addArrangedSubview(row)

            if index < days.count - 1 {
                let sep = createSeparator()
                stackView.addArrangedSubview(sep)
            }
        }
    }

    // MARK: - Helpers
    private func createRow(
        dayName: String,
        condition: WeatherCondition,
        low: Int,
        high: Int,
        globalMin: Double,
        globalMax: Double
    ) -> UIView {
        let container = UIView()

        let dayLabel = UILabel()
        dayLabel.text = dayName
        dayLabel.font = .systemFont(ofSize: 18, weight: .medium)
        dayLabel.textColor = .white

        let iconView = UIImageView()
        iconView.image = UIImage(systemName: condition.sfSymbolName(isDay: true))
        iconView.tintColor = .white
        iconView.contentMode = .scaleAspectFit

        let lowLabel = UILabel()
        lowLabel.text = "\(low)°"
        lowLabel.font = .systemFont(ofSize: 16, weight: .regular)
        lowLabel.textColor = UIColor.white.withAlphaComponent(0.6)
        lowLabel.textAlignment = .right

        let barContainer = UIView()
        barContainer.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        barContainer.layer.cornerRadius = 2
        barContainer.clipsToBounds = true

        let barFill = UIView()
        barFill.layer.cornerRadius = 2
        barFill.clipsToBounds = true
        barContainer.addSubview(barFill)
        barFill.translatesAutoresizingMaskIntoConstraints = false

        let avgTemp = (Double(low) + Double(high)) / 2.0
        if avgTemp < 0 {
            barFill.backgroundColor = UIColor.systemCyan
        } else if avgTemp < 15 {
            barFill.backgroundColor = UIColor.systemGreen
        } else if avgTemp < 30 {
            barFill.backgroundColor = UIColor.systemYellow
        } else {
            barFill.backgroundColor = UIColor.systemOrange
        }

        let range = globalMax - globalMin
        let leftFraction = range > 0 ? (Double(low) - globalMin) / range : 0
        let rightFraction = range > 0 ? (globalMax - Double(high)) / range : 0

        NSLayoutConstraint.activate([
            barFill.topAnchor.constraint(equalTo: barContainer.topAnchor),
            barFill.bottomAnchor.constraint(equalTo: barContainer.bottomAnchor),
            barFill.leadingAnchor.constraint(equalTo: barContainer.leadingAnchor,
                                             constant: CGFloat(leftFraction) * 100),
            barFill.trailingAnchor.constraint(equalTo: barContainer.trailingAnchor,
                                              constant: -CGFloat(rightFraction) * 100)
        ])

        let highLabel = UILabel()
        highLabel.text = "\(high)°"
        highLabel.font = .systemFont(ofSize: 16, weight: .medium)
        highLabel.textColor = .white

        [dayLabel, iconView, lowLabel, barContainer, highLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            container.addSubview($0)
        }

        NSLayoutConstraint.activate([
            dayLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            dayLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            dayLabel.widthAnchor.constraint(equalToConstant: 80),

            iconView.leadingAnchor.constraint(equalTo: dayLabel.trailingAnchor, constant: 8),
            iconView.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 28),
            iconView.heightAnchor.constraint(equalToConstant: 28),

            lowLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 12),
            lowLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            lowLabel.widthAnchor.constraint(equalToConstant: 36),

            barContainer.leadingAnchor.constraint(equalTo: lowLabel.trailingAnchor, constant: 8),
            barContainer.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            barContainer.heightAnchor.constraint(equalToConstant: 4),
            barContainer.widthAnchor.constraint(equalToConstant: 100),

            highLabel.leadingAnchor.constraint(equalTo: barContainer.trailingAnchor, constant: 8),
            highLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            highLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),

            container.heightAnchor.constraint(equalToConstant: 50)
        ])

        return container
    }

    private func createSeparator() -> UIView {
        let container = UIView()
        let line = UIView()
        line.backgroundColor = UIColor.white.withAlphaComponent(0.3)
        line.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(line)

        NSLayoutConstraint.activate([
            line.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            line.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            line.topAnchor.constraint(equalTo: container.topAnchor),
            line.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            line.heightAnchor.constraint(equalToConstant: 0.5)
        ])

        return container
    }
}
