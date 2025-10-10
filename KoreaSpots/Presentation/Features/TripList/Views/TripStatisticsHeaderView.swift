//
//  TripStatisticsHeaderView.swift
//  KoreaSpots
//
//  Created by YoungJin on 10/10/25.
//

import UIKit
import SnapKit
import Then

final class TripStatisticsHeaderView: BaseReusableView {

    // MARK: - UI Components

    private let containerView = UIView().then {
        $0.backgroundColor = .secondBackGround
        $0.layer.cornerRadius = 12
        $0.layer.masksToBounds = true
    }

    private let titleLabel = UILabel().then {
        $0.text = "여행 통계"
        $0.font = .systemFont(ofSize: 18, weight: .bold)
        $0.textColor = .label
    }

    private let statsStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 12
        $0.distribution = .fillEqually
    }

    private let tripCountView = StatItemView()
    private let placeCountView = StatItemView()
    private let topAreaView = StatItemView()

    // MARK: - Configuration

    func configure(with statistics: TripStatistics) {
        tripCountView.configure(
            icon: "airplane",
            title: "총 여행",
            value: "\(statistics.totalTripCount)개"
        )

        placeCountView.configure(
            icon: "mappin.circle",
            title: "방문 관광지",
            value: "\(statistics.totalPlaceCount)개"
        )

        let topAreaName = statistics.mostVisitedAreas.first?.areaName ?? "-"
        topAreaView.configure(
            icon: "star.fill",
            title: "최다 방문",
            value: topAreaName
        )
    }

    // MARK: - Hierarchy & Layout

    override func configureHierarchy() {
        addSubview(containerView)
        containerView.addSubviews(titleLabel, statsStackView)

        statsStackView.addArrangedSubview(tripCountView)
        statsStackView.addArrangedSubview(placeCountView)
        statsStackView.addArrangedSubview(topAreaView)
    }

    override func configureLayout() {
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16))
        }

        titleLabel.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview().inset(16)
        }

        statsStackView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.bottom.equalToSuperview().offset(-16)
        }
    }
}

// MARK: - StatItemView

private final class StatItemView: UIView {

    private let iconImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.tintColor = .textPrimary
    }

    private let titleLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 12, weight = .regular)
        $0.textColor = .secondaryLabel
        $0.textAlignment = .center
    }

    private let valueLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 16, weight: .bold)
        $0.textColor = .label
        $0.textAlignment = .center
    }

    private let stackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 4
        $0.alignment = .center
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        addSubview(stackView)
        stackView.addArrangedSubview(iconImageView)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(valueLabel)

        stackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        iconImageView.snp.makeConstraints {
            $0.width.height.equalTo(24)
        }
    }

    func configure(icon: String, title: String, value: String) {
        iconImageView.image = UIImage(systemName: icon)
        titleLabel.text = title
        valueLabel.text = value
    }
}
