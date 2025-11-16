//
//  TripRecordView.swift
//  KoreaSpots
//
//  Created by YoungJin on 10/10/25.
//

import UIKit
import SnapKit
import Then
import FSCalendar

final class TripRecordView: BaseView {

    // MARK: - UI Components
    let scrollView = UIScrollView()
    let contentView = UIView()
    let statisticsHeaderView = TripStatisticsHeaderView()
    let calendarView = TripCalendarView()
    lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())

    // MARK: - Properties
    var trips: [Trip] = []
}

// MARK: - Hierarchy & Layout

extension TripRecordView {
    override func configureHierarchy() {
        addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubviews(statisticsHeaderView, calendarView, collectionView)
    }

    override func configureLayout() {
        scrollView.snp.makeConstraints {
            $0.edges.equalTo(safeAreaLayoutGuide)
        }

        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
        }

        statisticsHeaderView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(150)
        }

        calendarView.snp.makeConstraints {
            $0.top.equalTo(statisticsHeaderView.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(620)
        }

        collectionView.snp.makeConstraints {
            $0.top.equalTo(calendarView.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(500)
            $0.bottom.equalToSuperview()
        }
    }

    override func configureView() {
        super.configureView()

        scrollView.do {
            $0.showsVerticalScrollIndicator = true
            $0.alwaysBounceVertical = true
        }

        contentView.do {
            $0.backgroundColor = .clear
        }

        collectionView.do {
            $0.backgroundColor = .backGround
            $0.showsVerticalScrollIndicator = false
            $0.isScrollEnabled = false
            $0.allowsSelection = true
        }
    }
}

    // MARK: - Compositional Layout

extension TripRecordView {
    func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { sectionIndex, environment in
            // Only trips section with list configuration
            return self.createTripsSection(environment: environment)
        }
        return layout
    }

    func createTripsSection(environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        var configuration = UICollectionLayoutListConfiguration(appearance: .plain)
        configuration.showsSeparators = false
        configuration.backgroundColor = .clear

        let section = NSCollectionLayoutSection.list(
            using: configuration,
            layoutEnvironment: environment
        )

        section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 0, bottom: 16, trailing: 0)

        return section
    }
}

// MARK: - Calendar Helpers

extension TripRecordView {
    /// 특정 날짜에 해당하는 여행 찾기 (첫 번째)
    func trip(for date: Date) -> Trip? {
        return trips.first { trip in
            let calendar = Calendar.current
            let startOfDay = calendar.startOfDay(for: date)
            let startOfTripStart = calendar.startOfDay(for: trip.startDate)
            let startOfTripEnd = calendar.startOfDay(for: trip.endDate)

            return startOfDay >= startOfTripStart && startOfDay <= startOfTripEnd
        }
    }

    /// 특정 날짜에 해당하는 모든 여행 찾기 (겹치는 여행 포함)
    func trips(for date: Date) -> [Trip] {
        return trips.filter { trip in
            let calendar = Calendar.current
            let startOfDay = calendar.startOfDay(for: date)
            let startOfTripStart = calendar.startOfDay(for: trip.startDate)
            let startOfTripEnd = calendar.startOfDay(for: trip.endDate)

            return startOfDay >= startOfTripStart && startOfDay <= startOfTripEnd
        }
    }

    /// 특정 날짜가 여행 시작일인지 확인
    func isTripStart(date: Date) -> Bool {
        return trips.contains { trip in
            Calendar.current.isDate(date, inSameDayAs: trip.startDate)
        }
    }

    /// 특정 날짜가 여행 종료일인지 확인
    func isTripEnd(date: Date) -> Bool {
        return trips.contains { trip in
            Calendar.current.isDate(date, inSameDayAs: trip.endDate)
        }
    }

    /// 특정 날짜가 여행 기간 중간인지 확인
    func isTripMiddle(date: Date) -> Bool {
        return trip(for: date) != nil && !isTripStart(date: date) && !isTripEnd(date: date)
    }
}
