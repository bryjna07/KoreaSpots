//
//  TripRecordViewController+Calendar.swift
//  KoreaSpots
//
//  Created by YoungJin on 10/10/25.
//

import UIKit
import FSCalendar

// MARK: - FSCalendar Configuration

extension TripRecordViewController {

    /// 캘린더 바 렌더링 상수
    enum CalendarBarConfig {
        static let height: CGFloat = 20
        static let spacing: CGFloat = 3
        static let topMarginRatio: CGFloat = 0.40
        static let maxTracksToShow: Int = 3
        static let titleMaxLength: Int = 5
        static let titleFontSize: CGFloat = 10
        static let moreLabelFontSize: CGFloat = 9
        static let startPadding: CGFloat = 0.05
        static let endPadding: CGFloat = 0.95
    }
}

// MARK: - FSCalendarDelegate & DataSource

extension TripRecordViewController: FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance {

    // MARK: - Selection
    // 날짜 선택 기능 비활성화 (allowsSelection = false)

    // MARK: - Appearance

    func calendar(_ calendar: FSCalendar, subtitleFor date: Date) -> String? {
        return nil
    }

    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, fillDefaultColorFor date: Date) -> UIColor? {
        return nil
    }

    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleDefaultColorFor date: Date) -> UIColor? {
        let weekday = Calendar.current.component(.weekday, from: date)

        // 토요일(7)은 검정색으로 표시
        if weekday == 7 {
            return .label
        }

        return nil
    }

    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleSelectionColorFor date: Date) -> UIColor? {
        let weekday = Calendar.current.component(.weekday, from: date)

        // 선택 시에도 토요일은 검정색, 일요일은 빨간색 유지
        if weekday == 7 {
            return .label  // 토요일
        } else if weekday == 1 {
            return .systemRed  // 일요일
        }

        return .label  // 평일
    }

    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, subtitleDefaultColorFor date: Date) -> UIColor? {
        return nil
    }

    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, borderDefaultColorFor date: Date) -> UIColor? {
        return .clear
    }

    // MARK: - Custom Cell Rendering

    func calendar(_ calendar: FSCalendar, willDisplay cell: FSCalendarCell, for date: Date, at monthPosition: FSCalendarMonthPosition) {
        // 기존 커스텀 레이어 제거
        removeCustomLayers(from: cell)

        // 셀의 bounds가 유효한지 확인 (hidden 상태에서 0이 될 수 있음)
        guard cell.contentView.bounds.width > 0, cell.contentView.bounds.height > 0 else { return }

        // 해당 날짜의 모든 여행 가져오기
        let tripsForDate = tripRecordView.trips(for: date)
        guard !tripsForDate.isEmpty else { return }

        let sortedTrips = sortTripsByTrack(tripsForDate)

        // 각 여행의 바 그리기
        for trip in sortedTrips {
            guard let trackIndex = tripTracks[trip.id],
                  trackIndex < CalendarBarConfig.maxTracksToShow else { continue }

            renderTripBar(for: trip, at: trackIndex, on: cell, date: date)
        }

        // 표시되지 않은 여행 개수 표시
        renderHiddenTripsCount(sortedTrips, on: cell)
    }
}

// MARK: - Private Rendering Helpers

private extension TripRecordViewController {

    func removeCustomLayers(from cell: FSCalendarCell) {
        cell.contentView.layer.sublayers?
            .filter { $0.name?.hasPrefix("tripRange") ?? false }
            .forEach { $0.removeFromSuperlayer() }
    }

    func sortTripsByTrack(_ trips: [Trip]) -> [Trip] {
        return trips.sorted { trip1, trip2 in
            let track1 = tripTracks[trip1.id] ?? 0
            let track2 = tripTracks[trip2.id] ?? 0
            return track1 < track2
        }
    }

    func renderTripBar(for trip: Trip, at trackIndex: Int, on cell: FSCalendarCell, date: Date) {
        let cellHeight = cell.contentView.bounds.height
        let cellWidth = cell.contentView.bounds.width

        let isStart = Calendar.current.isDate(date, inSameDayAs: trip.startDate)
        let isEnd = Calendar.current.isDate(date, inSameDayAs: trip.endDate)

        let yOffset = CalendarBarConfig.topMarginRatio * cellHeight +
                      CGFloat(trackIndex) * (CalendarBarConfig.height + CalendarBarConfig.spacing)

        let rangeLayer = createRangeLayer(
            for: trip,
            isStart: isStart,
            isEnd: isEnd,
            cellWidth: cellWidth,
            yOffset: yOffset
        )

        cell.contentView.layer.insertSublayer(rangeLayer, at: 0)

        // 시작일에 여행 제목 표시
        if isStart {
            let titleLayer = createTitleLayer(for: trip, rangeLayer: rangeLayer, yOffset: yOffset)
            cell.contentView.layer.addSublayer(titleLayer)
        }
    }

    func createRangeLayer(for trip: Trip, isStart: Bool, isEnd: Bool, cellWidth: CGFloat, yOffset: CGFloat) -> CALayer {
        let layer = CALayer()
        layer.name = "tripRangeBar_\(trip.id)"

        let config = CalendarBarConfig.self

        if isStart && isEnd {
            // 1일짜리 여행
            layer.frame = CGRect(
                x: cellWidth * config.startPadding,
                y: yOffset,
                width: cellWidth * (1 - config.startPadding * 2),
                height: config.height
            )
            layer.cornerRadius = config.height / 2
            layer.backgroundColor = UIColor.primary.withAlphaComponent(0.8).cgColor
        } else if isStart {
            // 여행 시작일
            layer.frame = CGRect(
                x: cellWidth * config.startPadding,
                y: yOffset,
                width: cellWidth * config.endPadding,
                height: config.height
            )
            layer.cornerRadius = config.height / 2
            layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
            layer.backgroundColor = UIColor.primary.withAlphaComponent(0.8).cgColor
        } else if isEnd {
            // 여행 종료일
            layer.frame = CGRect(
                x: 0,
                y: yOffset,
                width: cellWidth * config.endPadding,
                height: config.height
            )
            layer.cornerRadius = config.height / 2
            layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
            layer.backgroundColor = UIColor.primary.withAlphaComponent(0.8).cgColor
        } else {
            // 여행 중간일
            layer.frame = CGRect(
                x: 0,
                y: yOffset,
                width: cellWidth,
                height: config.height
            )
            layer.backgroundColor = UIColor.primary.withAlphaComponent(0.5).cgColor
        }

        return layer
    }

    func createTitleLayer(for trip: Trip, rangeLayer: CALayer, yOffset: CGFloat) -> CATextLayer {
        let titleLayer = CATextLayer()
        titleLayer.name = "tripRangeTitle_\(trip.id)"

        let config = CalendarBarConfig.self
        let title = trip.title.count > config.titleMaxLength ?
            String(trip.title.prefix(config.titleMaxLength)) + "..." :
            trip.title

        titleLayer.string = title
        titleLayer.fontSize = config.titleFontSize
        titleLayer.foregroundColor = UIColor.textPrimary.cgColor
        titleLayer.alignmentMode = .left
        titleLayer.truncationMode = .end
        titleLayer.frame = CGRect(
            x: rangeLayer.frame.minX + 6,
            y: yOffset + 3,
            width: rangeLayer.frame.width - 12,
            height: config.height - 6
        )
        titleLayer.contentsScale = UIScreen.main.scale

        return titleLayer
    }

    func renderHiddenTripsCount(_ sortedTrips: [Trip], on cell: FSCalendarCell) {
        let hiddenTripsCount = sortedTrips.filter {
            (tripTracks[$0.id] ?? 0) >= CalendarBarConfig.maxTracksToShow
        }.count

        guard hiddenTripsCount > 0 else { return }

        let config = CalendarBarConfig.self
        let cellHeight = cell.contentView.bounds.height
        let cellWidth = cell.contentView.bounds.width

        let moreLabel = CATextLayer()
        moreLabel.name = "tripRangeMore"
        moreLabel.string = "+\(hiddenTripsCount)"
        moreLabel.fontSize = config.moreLabelFontSize
        moreLabel.foregroundColor = UIColor.secondaryLabel.cgColor
        moreLabel.alignmentMode = .center

        let moreYOffset = config.topMarginRatio * cellHeight +
                         CGFloat(config.maxTracksToShow) * (config.height + config.spacing)

        moreLabel.frame = CGRect(x: 0, y: moreYOffset, width: cellWidth, height: 12)
        moreLabel.contentsScale = UIScreen.main.scale

        cell.contentView.layer.addSublayer(moreLabel)
    }
}
