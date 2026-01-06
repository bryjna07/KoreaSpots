//
//  DateFormatterUtil.swift
//  KoreaSpots
//
//  Created by YoungJin on 9/27/25.
//

import Foundation

enum DateFormatterUtil {

    // MARK: - Shared DateFormatters
    static let yyyyMMdd: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        return formatter
    }()

    static let displayDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "M.d"
        return formatter
    }()

    static let fullDisplayDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        return formatter
    }()

    static let shortDisplayDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yy.MM.dd"
        return formatter
    }()

    static let tripDateRange: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter
    }()

    // MARK: - Helper Methods
    /// 홈화면 축제 카드용 - M.d 형식
    static func formatPeriod(start: String, end: String) -> String {
        guard let startDate = yyyyMMdd.date(from: start),
              let endDate = yyyyMMdd.date(from: end) else {
            return "\(start) ~ \(end)"
        }

        let startString = displayDate.string(from: startDate)
        let endString = displayDate.string(from: endDate)

        if Calendar.current.compare(startDate, to: endDate, toGranularity: .day) == .orderedSame {
            return startString
        } else {
            return "\(startString) ~ \(endString)"
        }
    }

    /// 상세정보용 - yy.MM.dd 형식
    static func formatPeriodWithYear(start: String, end: String) -> String {
        guard let startDate = yyyyMMdd.date(from: start),
              let endDate = yyyyMMdd.date(from: end) else {
            return "\(start) ~ \(end)"
        }

        let startString = shortDisplayDate.string(from: startDate)
        let endString = shortDisplayDate.string(from: endDate)

        if Calendar.current.compare(startDate, to: endDate, toGranularity: .day) == .orderedSame {
            return startString
        } else {
            return "\(startString) ~ \(endString)"
        }
    }

    static func formatDisplayDate(from dateString: String) -> String? {
        guard let date = yyyyMMdd.date(from: dateString) else { return nil }
        return displayDate.string(from: date)
    }

    static func formatShortDisplayDate(from dateString: String) -> String? {
        guard let date = yyyyMMdd.date(from: dateString) else { return nil }
        return shortDisplayDate.string(from: date)
    }
}
