//
//  HourlyDetailCell.swift
//  TestWeatherApp
//
//  Created by Fedor Donskov on 30.03.2026.
//

import UIKit

// MARK: - HourlyDetailCell
final class HourlyDetailCell: UITableViewCell {

    static let reuseID = "HourlyDetailCell"

    private let containerView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        v.layer.cornerRadius = 12
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let timeLabel = HourlyDetailCell.makeLabel(size: 16, weight: .semibold)
    private let iconView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.tintColor = .white
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    private let tempLabel = HourlyDetailCell.makeLabel(size: 22, weight: .semibold)
    private let conditionLabel = HourlyDetailCell.makeLabel(size: 13, weight: .regular, alpha: 0.7)

    private let feelsLikeRow = DetailRow()
    private let windRow = DetailRow()
    private let humidityRow = DetailRow()
    private let pressureRow = DetailRow()
    private let precipRow = DetailRow()
    private let uvRow = DetailRow()

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

        let headerStack = UIStackView(arrangedSubviews: [iconView, tempLabel])
        headerStack.axis = .horizontal
        headerStack.spacing = 8
        headerStack.alignment = .center

        let topStack = UIStackView(arrangedSubviews: [timeLabel, headerStack, conditionLabel])
        topStack.axis = .vertical
        topStack.spacing = 4

        let separator = UIView()
        separator.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.heightAnchor.constraint(equalToConstant: 0.5).isActive = true

        let detailStack = UIStackView(arrangedSubviews: [
            feelsLikeRow, windRow, humidityRow, pressureRow, precipRow, uvRow
        ])
        detailStack.axis = .vertical
        detailStack.spacing = 6

        let mainStack = UIStackView(arrangedSubviews: [topStack, separator, detailStack])
        mainStack.axis = .vertical
        mainStack.spacing = 10
        mainStack.translatesAutoresizingMaskIntoConstraints = false

        containerView.addSubview(mainStack)

        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),

            mainStack.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            mainStack.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 14),
            mainStack.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -14),
            mainStack.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12),

            iconView.widthAnchor.constraint(equalToConstant: 28),
            iconView.heightAnchor.constraint(equalToConstant: 28)
        ])
    }

    func configure(with hour: HourWeather) {
        let components = (hour.time ?? "").split(separator: " ")
        timeLabel.text = components.count == 2 ? String(components[1]) : (hour.time ?? "")

        let symbolName = hour.condition?.sfSymbolName(isDay: (hour.isDay ?? 1) == 1) ?? "cloud.fill"
        iconView.image = UIImage(systemName: symbolName)
        tempLabel.text = "\(Int((hour.tempC ?? 0).rounded()))°"
        conditionLabel.text = (hour.condition?.text ?? "").trimmingCharacters(in: .whitespaces)

        let l = LocalizationManager.shared
        feelsLikeRow.configure(icon: "thermometer.medium", title: l.localizedString(for: "detail.feels_like"), value: "\(Int((hour.feelslikeC ?? 0).rounded()))°")
        windRow.configure(icon: "wind", title: l.localizedString(for: "detail.wind"), value: "\(Int((hour.windKph ?? 0).rounded())) \(l.localizedString(for: "detail.kmh")), \(hour.windDir ?? "")")
        humidityRow.configure(icon: "humidity.fill", title: l.localizedString(for: "detail.humidity"), value: "\(hour.humidity ?? 0)%")
        pressureRow.configure(icon: "gauge.with.dots.needle.bottom.50percent", title: l.localizedString(for: "detail.pressure"), value: "\(Int(hour.pressureMb ?? 0)) \(l.localizedString(for: "detail.mbar"))")
        precipRow.configure(icon: "umbrella.fill", title: l.localizedString(for: "detail.precipitation"), value: "\(hour.chanceOfRain ?? 0)%")
        uvRow.configure(icon: "sun.max.trianglebadge.exclamationmark", title: l.localizedString(for: "detail.uv_index"), value: "\(hour.uv ?? 0)")
    }

    private static func makeLabel(size: CGFloat, weight: UIFont.Weight, alpha: CGFloat = 1) -> UILabel {
        let label = UILabel()
        label.font = .systemFont(ofSize: size, weight: weight)
        label.textColor = UIColor.white.withAlphaComponent(alpha)
        return label
    }
}
