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

    // 운영정보 (detailIntro2 캐시, TTL 7일)
    @Persisted var operatingInfo: OperatingInfoE?

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
        self.modifiedTime = place.modifiedTime
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
        self.modifiedTime = place.modifiedTime
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
            modifiedTime: modifiedTime,
            eventMeta: eventMeta?.toDomain(),
            isCustom: isCustom,
            customPlaceId: customPlaceId,
            userProvidedImagePath: userProvidedImagePath
        )
    }
}

// MARK: - Cache Refresh Logic
extension PlaceR {
    /// AM 4:00 (KST) 기준으로 1일 1회 갱신 필요 여부 판단
    func needsRefresh() -> Bool {
        let now = Date()
        let calendar = Calendar.current
        guard let kst = TimeZone(identifier: "Asia/Seoul") else {
            return true
        }

        // 현재 시간을 KST로 변환
        var todayComponents = calendar.dateComponents(in: kst, from: now)
        todayComponents.hour = 4
        todayComponents.minute = 0
        todayComponents.second = 0

        guard let todayRefreshTime = calendar.date(from: todayComponents) else {
            return true
        }

        // 현재 시간이 오늘 4시 이전이면 어제 4시를 기준점으로 사용
        // 현재 시간이 오늘 4시 이후면 오늘 4시를 기준점으로 사용
        let refreshThreshold = now < todayRefreshTime
            ? calendar.date(byAdding: .day, value: -1, to: todayRefreshTime)!
            : todayRefreshTime

        return cachedAt < refreshThreshold
    }

    /// modifiedTime 기반 변경 감지 및 선택적 갱신
    /// - Parameter apiModifiedTime: API 응답의 modifiedtime 값
    /// - Returns: 실제 데이터가 변경되었는지 여부
    func hasDataChanged(apiModifiedTime: String?) -> Bool {
        guard let apiModifiedTime = apiModifiedTime else {
            // modifiedTime이 없는 경우 (detailIntro2, detailImage2)
            // 상위 데이터 변경 여부에 따라 판단해야 함
            return true
        }

        // 기존 modifiedTime과 비교
        return self.modifiedTime != apiModifiedTime
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
