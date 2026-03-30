//
//  DailyDetailCell.swift
//  TestWeatherApp
//
//  Created by Fedor Donskov on 30.03.2026.
//

import UIKit

// MARK: - DailyDetailCell
final class DailyDetailCell: UITableViewCell {

    static let reuseID = "DailyDetailCell"

    private let containerView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        v.layer.cornerRadius = 12
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let mainStack: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 10
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none

        contentView.addSubview(containerView)
        containerView.addSubview(mainStack)

        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),

            mainStack.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 14),
            mainStack.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 14),
            mainStack.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -14),
            mainStack.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -14)
        ])
    }

    func configure(with day: ForecastDay, dayName: String) {
        mainStack.arrangedSubviews.forEach { $0.removeFromSuperview() }

        let l = LocalizationManager.shared

        let headerStack = UIStackView()
        headerStack.axis = .horizontal
        headerStack.spacing = 8
        headerStack.alignment = .center

        let dayLabel = UILabel()
        dayLabel.text = dayName
        dayLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        dayLabel.textColor = .white

        let iconView = UIImageView(image: UIImage(systemName: day.day?.condition?.sfSymbolName(isDay: true) ?? "cloud.fill"))
        iconView.tintColor = .white
        iconView.contentMode = .scaleAspectFit
        iconView.widthAnchor.constraint(equalToConstant: 28).isActive = true
        iconView.heightAnchor.constraint(equalToConstant: 28).isActive = true

        let conditionLabel = UILabel()
        conditionLabel.text = (day.day?.condition?.text ?? "").trimmingCharacters(in: .whitespaces)
        conditionLabel.font = .systemFont(ofSize: 15, weight: .regular)
        conditionLabel.textColor = UIColor.white.withAlphaComponent(0.7)
        conditionLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)

        headerStack.addArrangedSubview(dayLabel)
        headerStack.addArrangedSubview(iconView)
        headerStack.addArrangedSubview(conditionLabel)
        headerStack.addArrangedSubview(UIView()) // spacer

        let tempLabel = UILabel()
        tempLabel.text = "\(Int((day.day?.maxtempC ?? 0).rounded()))° / \(Int((day.day?.mintempC ?? 0).rounded()))°"
        tempLabel.font = .systemFont(ofSize: 18, weight: .medium)
        tempLabel.textColor = .white
        headerStack.addArrangedSubview(tempLabel)

        mainStack.addArrangedSubview(headerStack)

        let sep = UIView()
        sep.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        sep.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        mainStack.addArrangedSubview(sep)

        let rows: [(String, String, String)] = [
            ("sunrise.fill", l.localizedString(for: "detail.sunrise"), day.astro?.sunrise ?? ""),
            ("sunset.fill", l.localizedString(for: "detail.sunset"), day.astro?.sunset ?? ""),
            ("thermometer.high", l.localizedString(for: "detail.max_temp"), "\(Int((day.day?.maxtempC ?? 0).rounded()))°"),
            ("thermometer.low", l.localizedString(for: "detail.min_temp"), "\(Int((day.day?.mintempC ?? 0).rounded()))°"),
            ("wind", l.localizedString(for: "detail.wind"), "\(Int((day.day?.maxwindKph ?? 0).rounded())) \(l.localizedString(for: "detail.kmh"))"),
            ("humidity.fill", l.localizedString(for: "detail.humidity"), "\(day.day?.avghumidity ?? 0)%"),
            ("umbrella.fill", l.localizedString(for: "detail.precipitation"), "\(day.day?.dailyChanceOfRain ?? 0)%"),
            ("sun.max.trianglebadge.exclamationmark", l.localizedString(for: "detail.uv_index"), "\(day.day?.uv ?? 0)"),
            ("moon.stars.fill", l.localizedString(for: "detail.moon_phase"), day.astro?.moonPhase ?? "")
        ]

        for (icon, title, value) in rows {
            let row = makeRow(icon: icon, title: title, value: value)
            mainStack.addArrangedSubview(row)
        }
    }

    private func makeRow(icon: String, title: String, value: String) -> UIView {
        let iconView = UIImageView(image: UIImage(systemName: icon))
        iconView.tintColor = UIColor.white.withAlphaComponent(0.7)
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.widthAnchor.constraint(equalToConstant: 16).isActive = true
        iconView.heightAnchor.constraint(equalToConstant: 16).isActive = true

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 14, weight: .regular)
        titleLabel.textColor = UIColor.white.withAlphaComponent(0.7)

        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.font = .systemFont(ofSize: 14, weight: .medium)
        valueLabel.textColor = .white
        valueLabel.textAlignment = .right

        let stack = UIStackView(arrangedSubviews: [iconView, titleLabel, valueLabel])
        stack.axis = .horizontal
        stack.spacing = 6
        return stack
    }
}
