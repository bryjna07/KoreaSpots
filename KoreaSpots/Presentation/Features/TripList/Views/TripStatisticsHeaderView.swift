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
    private let containerView = UIView()
    private let titleLabel = UILabel()
    private let statsStackView = UIStackView()
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
    
    override func configureView() {
        super.configureView()
        containerView.do {
            $0.backgroundColor = .secondBackGround
            $0.layer.cornerRadius = 12
            $0.layer.masksToBounds = true
        }

        titleLabel.do {
            $0.text = "여행 통계"
            $0.font = .systemFont(ofSize: 18, weight: .bold)
            $0.textColor = .label
        }

        statsStackView.do {
            $0.axis = .horizontal
            $0.spacing = 12
            $0.distribution = .fillEqually
        }
    }
}
