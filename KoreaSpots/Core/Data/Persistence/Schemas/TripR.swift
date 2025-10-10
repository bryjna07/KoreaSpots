//
//  TripR.swift
//  KoreaSpots
//
//  Created by YoungJin on 10/10/25.
//

import Foundation
import RealmSwift

// MARK: - TripR (여행 기록)
final class TripR: Object {
    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted var title: String = ""
    @Persisted var coverPhotoId: String?
    @Persisted var startDate: Date = Date()
    @Persisted var endDate: Date = Date()
    @Persisted var memo: String = ""
    @Persisted var visitedPlaces: List<VisitedPlaceE>
    @Persisted var visitedAreas: List<VisitedAreaE>
    @Persisted var tags: List<String> // TagR 이름 리스트
    @Persisted var createdAt: Date = Date()
    @Persisted var updatedAt: Date = Date()

    override static func indexedProperties() -> [String] {
        return ["startDate", "endDate", "createdAt", "updatedAt"]
    }
}

// MARK: - VisitedPlaceE (방문 관광지 - Embedded)
final class VisitedPlaceE: EmbeddedObject {
    @Persisted var entryId: String = UUID().uuidString
    @Persisted var placeId: String = ""
    @Persisted var placeNameSnapshot: String = ""
    @Persisted var thumbnailURLSnapshot: String?
    @Persisted var areaCode: Int = 0
    @Persisted var sigunguCode: Int = 0
    @Persisted var addedAt: Date = Date()
    @Persisted var order: Int = 0
    @Persisted var note: String?
    @Persisted var rating: Int?
    @Persisted var locationSnapshot: GeoPointE?
}

// MARK: - VisitedAreaE (지역 집계 - Embedded)
final class VisitedAreaE: EmbeddedObject {
    @Persisted var areaCode: Int = 0
    @Persisted var sigunguCode: Int?
    @Persisted var count: Int = 0
    @Persisted var firstVisitedAt: Date = Date()
    @Persisted var lastVisitedAt: Date = Date()
}

// MARK: - GeoPointE (좌표 - Embedded)
final class GeoPointE: EmbeddedObject {
    @Persisted var lat: Double = 0.0
    @Persisted var lng: Double = 0.0
}

// MARK: - VisitIndexR (파생 인덱스 - 전역 검색/집계용)
final class VisitIndexR: Object {
    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted var tripId: ObjectId
    @Persisted var entryId: String = ""
    @Persisted var placeId: String = ""
    @Persisted var placeNameSnapshot: String = ""
    @Persisted var thumbnailURLSnapshot: String?
    @Persisted var areaCode: Int = 0
    @Persisted var sigunguCode: Int = 0
    @Persisted var visitedAt: Date = Date()
    @Persisted var tagKeys: List<String>
    @Persisted var createdAt: Date = Date()
    @Persisted var updatedAt: Date = Date()

    override static func indexedProperties() -> [String] {
        return ["tripId", "entryId", "placeId", "areaCode", "sigunguCode", "visitedAt", "createdAt", "updatedAt"]
    }
}

// MARK: - TagR (태그)
final class TagR: Object {
    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted var name: String = ""
    @Persisted var color: String?
    @Persisted var emoji: String?

    override static func indexedProperties() -> [String] {
        return ["name"]
    }
}
