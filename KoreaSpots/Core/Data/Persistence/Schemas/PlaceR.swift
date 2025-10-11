//
//  PlaceR.swift
//  KoreaSpots
//
//  Created by YoungJin on 9/27/25.
//

import Foundation
import RealmSwift

class PlaceR: Object {
    @Persisted var contentId: String = ""
    @Persisted var title: String = ""
    @Persisted var address: String = ""
    @Persisted var imageURL: String?
    @Persisted var mapX: Double?
    @Persisted var mapY: Double?
    @Persisted var tel: String?
    @Persisted var overview: String?
    @Persisted var contentTypeId: Int?
    @Persisted var cat1: String?
    @Persisted var cat2: String?
    @Persisted var cat3: String?
    @Persisted var distance: Int?

    // 캐싱 관련 필드
    @Persisted var cachedAt: Date = Date()
    @Persisted var modifiedTime: String? // API modifiedtime (변경 감지용)
    @Persisted var areaCode: Int?
    @Persisted var sigunguCode: Int?

    // 이벤트 메타 (축제, 공연, 전시 등)
    @Persisted var eventMeta: EventMetaE?

    // 즐겨찾기
    @Persisted var isFavorite: Bool = false

    // MARK: - 커스텀 관광지 지원 (API 없는 장소)
    /// 유저가 직접 생성한 장소 여부 (true: 커스텀, false: API 장소)
    @Persisted var isCustom: Bool = false
    /// 커스텀 장소 고유 ID (isCustom=true일 때만 사용)
    @Persisted var customPlaceId: String?
    /// 커스텀 장소의 대표 사진 로컬 경로 (isCustom=true일 때만 사용)
    @Persisted var userProvidedImagePath: String?

    override static func primaryKey() -> String? {
        return "contentId"
    }

    override static func indexedProperties() -> [String] {
        return ["contentTypeId", "areaCode", "sigunguCode", "cat1", "cat2", "cat3", "cachedAt", "isFavorite", "isCustom"]
    }
}

// MARK: - EventMetaE (이벤트 메타데이터 - Embedded)
final class EventMetaE: EmbeddedObject {
    @Persisted var eventStartDate: String = ""
    @Persisted var eventEndDate: String = ""
}

// MARK: - Mapping Extensions
extension PlaceR {
    convenience init(place: Place) {
        self.init()
        self.contentId = place.contentId
        self.title = place.title
        self.address = place.address
        self.imageURL = place.imageURL
        self.mapX = place.mapX
        self.mapY = place.mapY
        self.tel = place.tel
        self.overview = place.overview
        self.contentTypeId = place.contentTypeId
        self.cat1 = place.cat1
        self.cat2 = place.cat2
        self.cat3 = place.cat3
        self.distance = place.distance
        self.areaCode = place.areaCode
        self.sigunguCode = place.sigunguCode
        self.cachedAt = Date()
        self.isCustom = place.isCustom
        self.customPlaceId = place.customPlaceId
        self.userProvidedImagePath = place.userProvidedImagePath

        // EventMeta 매핑
        if let eventMeta = place.eventMeta {
            let eventMetaE = EventMetaE()
            eventMetaE.eventStartDate = eventMeta.eventStartDate
            eventMetaE.eventEndDate = eventMeta.eventEndDate
            self.eventMeta = eventMetaE
        }
    }

    func update(from place: Place) {
        self.title = place.title
        self.address = place.address
        self.imageURL = place.imageURL
        self.mapX = place.mapX
        self.mapY = place.mapY
        self.tel = place.tel
        self.overview = place.overview
        self.contentTypeId = place.contentTypeId
        self.cat1 = place.cat1
        self.cat2 = place.cat2
        self.cat3 = place.cat3
        self.distance = place.distance
        self.areaCode = place.areaCode
        self.sigunguCode = place.sigunguCode
        self.isCustom = place.isCustom
        self.customPlaceId = place.customPlaceId
        self.userProvidedImagePath = place.userProvidedImagePath

        // EventMeta 업데이트
        if let eventMeta = place.eventMeta {
            if self.eventMeta == nil {
                self.eventMeta = EventMetaE()
            }
            self.eventMeta?.eventStartDate = eventMeta.eventStartDate
            self.eventMeta?.eventEndDate = eventMeta.eventEndDate
        } else {
            self.eventMeta = nil
        }
    }

    func toDomain() -> Place {
        return Place(
            contentId: contentId,
            title: title,
            address: address,
            imageURL: imageURL,
            mapX: mapX,
            mapY: mapY,
            tel: tel,
            overview: overview,
            contentTypeId: contentTypeId,
            areaCode: areaCode,
            sigunguCode: sigunguCode,
            cat1: cat1,
            cat2: cat2,
            cat3: cat3,
            distance: distance,
            eventMeta: eventMeta?.toDomain(),
            isCustom: isCustom,
            customPlaceId: customPlaceId,
            userProvidedImagePath: userProvidedImagePath
        )
    }
}

// MARK: - EventMetaE Mapping
extension EventMetaE {
    func toDomain() -> EventMeta {
        return EventMeta(
            eventStartDate: eventStartDate,
            eventEndDate: eventEndDate
        )
    }
}
