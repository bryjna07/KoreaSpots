//
//  EventMeta.swift
//  KoreaSpots
//
//  Created by YoungJin on 10/11/25.
//

import Foundation

/// 이벤트성 콘텐츠 메타데이터 (축제, 공연, 전시 등)
struct EventMeta: Equatable {
    let eventStartDate: String  // yyyyMMdd 형식
    let eventEndDate: String    // yyyyMMdd 형식

    /// 현재 진행중인 이벤트인지 확인
    var isOngoing: Bool {
        let today = Date()
        let todayString = DateFormatterUtil.yyyyMMdd.string(from: today)
        return eventStartDate <= todayString && eventEndDate >= todayString
    }

    /// 종료된 이벤트인지 확인
    var isExpired: Bool {
        let today = Date()
        let todayString = DateFormatterUtil.yyyyMMdd.string(from: today)
        return eventEndDate < todayString
    }

    /// 예정된 이벤트인지 확인
    var isUpcoming: Bool {
        let today = Date()
        let todayString = DateFormatterUtil.yyyyMMdd.string(from: today)
        return eventStartDate > todayString
    }

    /// 날짜 범위를 yy.MM.dd ~ yy.MM.dd 형식으로 반환 (상세정보용)
    var formattedDateRange: String {
        return DateFormatterUtil.formatPeriodWithYear(start: eventStartDate, end: eventEndDate)
    }
}
