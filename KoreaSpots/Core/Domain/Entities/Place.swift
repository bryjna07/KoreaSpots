//
//  Place.swift
//  KoreaSpots
//
//  Created by YoungJin on 9/25/25.
//

import Foundation

struct Place {
    let contentId: String
    let title: String
    let address: String
    let imageURL: String?
    let mapX: Double?
    let mapY: Double?
    let tel: String?
    let overview: String?
    let contentTypeId: Int?
    let areaCode: Int?  // 커스텀 장소나 위치 기반 검색은 areaCode 없을 수 있음
    let sigunguCode: Int?
    let cat1: String?
    let cat2: String?
    let cat3: String?
    let distance: Int? // 미터 단위

    // MARK: - 캐싱 관련
    let modifiedTime: String? // API modifiedtime (변경 감지용, areaBasedList2/detailCommon2/searchKeyword2에서 제공)

    // MARK: - 이벤트 메타 (축제, 공연, 전시 등)
    let eventMeta: EventMeta?

    // MARK: - 커스텀 관광지 지원
    let isCustom: Bool
    let customPlaceId: String?
    let userProvidedImagePath: String?
}

extension Place: Equatable {
    static func == (lhs: Place, rhs: Place) -> Bool {
        lhs.contentId == rhs.contentId
    }

    static var empty: Place {
        return Place(
            contentId: "",
            title: "",
            address: "",
            imageURL: nil,
            mapX: nil,
            mapY: nil,
            tel: nil,
            overview: nil,
            contentTypeId: 0,
            areaCode: nil,
            sigunguCode: nil,
            cat1: nil,
            cat2: nil,
            cat3: nil,
            distance: nil,
            modifiedTime: nil,
            eventMeta: nil,
            isCustom: false,
            customPlaceId: nil,
            userProvidedImagePath: nil
        )
    }

    /// 이벤트(축제/공연/전시)인지 확인
    var isEvent: Bool {
        return eventMeta != nil
    }
}
