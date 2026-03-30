//
//  HourlyCell.swift
//  TestWeatherApp
//
//  Created by Fedor Donskov on 30.03.2026.
//

import UIKit

// MARK: - HourlyCell
final class HourlyCell: UICollectionViewCell {

    static let reuseID = "HourlyCell"

    private let timeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()

    private let iconView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.tintColor = .white
        return iv
    }()

    private let tempLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        let stack = UIStackView(arrangedSubviews: [timeLabel, iconView, tempLabel])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 28),
            iconView.heightAnchor.constraint(equalToConstant: 28)
        ])
    }

    func configure(with hour: HourWeather, isNow: Bool) {
        if isNow {
            timeLabel.text = LocalizationManager.shared.localizedString(for: "weather.now")
        } else {
            let components = (hour.time ?? "").split(separator: " ")
            if components.count == 2 {
                let timePart = String(components[1])
                let hourPart = timePart.split(separator: ":").first.map(String.init) ?? ""
                timeLabel.text = "\(hourPart):00"
            }
        }

        let symbolName = hour.condition?.sfSymbolName(isDay: (hour.isDay ?? 1) == 1) ?? "cloud.fill"
        iconView.image = UIImage(systemName: symbolName)
        tempLabel.text = "\(Int((hour.tempC ?? 0).rounded()))°"
    }
}

