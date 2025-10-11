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

    // MARK: - 향후 확장 필드 (1차 출시 미사용)
    /// 지역 집계 (추후 통계 기능 업데이트 시 사용)
    @Persisted var visitedAreas: List<VisitedAreaE>
    /// 태그 (추후 태그 기능 업데이트 시 사용)
    @Persisted var tags: List<String>
    @Persisted var createdAt: Date = Date()
    @Persisted var updatedAt: Date = Date()

    // MARK: - 향후 확장 필드
    /// 경로 추적 활성화 여부 (추후 업데이트)
    @Persisted var isRouteTrackingEnabled: Bool = false
    /// 총 이동 거리 (km, 추후 업데이트)
    @Persisted var totalDistance: Double?
    /// 여행 스타일 태그 (추후 업데이트)
    @Persisted var travelStyle: String?

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
    @Persisted var areaCode: Int?
    @Persisted var sigunguCode: Int?
    @Persisted var addedAt: Date = Date()
    @Persisted var order: Int = 0
    @Persisted var note: String?
    @Persisted var rating: Int?

    // MARK: - 향후 확장 필드
    /// 방문 당시 좌표 (추후 지도 기능 업데이트 시 사용)
    @Persisted var locationSnapshot: GeoPointE?
    /// 방문 시각 (추후 업데이트)
    @Persisted var visitedTime: Date?
    /// 체류 시간 (분 단위, 추후 업데이트)
    @Persisted var stayDuration: Int?
    /// 경로 순서 인덱스 (order와 별도로 경로 추적용, 추후 업데이트)
    @Persisted var routeIndex: Int?

    // MARK: - 유저 사진 (여행 기록용)
    /// 해당 방문지에서 촬영한 사진들
    @Persisted var photos: List<VisitPhotoE>
}

// MARK: - VisitPhotoE (방문지 사진 - Embedded)
final class VisitPhotoE: EmbeddedObject {
    /// 사진 고유 ID
    @Persisted var photoId: String = UUID().uuidString
    /// 로컬 파일 경로 (예: Documents/TripPhotos/trip_123_photo_1.jpg)
    @Persisted var localPath: String = ""
    /// 사진 캡션 (선택)
    @Persisted var caption: String?
    /// 촬영 시각
    @Persisted var takenAt: Date = Date()
    /// 해당 방문지의 대표 사진 여부
    @Persisted var isCover: Bool = false
    /// 사진 정렬 순서 (0부터 시작)
    @Persisted var order: Int = 0
    /// 원본 이미지 너비
    @Persisted var width: Int = 0
    /// 원본 이미지 높이
    @Persisted var height: Int = 0

    // MARK: - 향후 확장 필드
    /// 클라우드 백업 URL (추후 업데이트)
    @Persisted var cloudURL: String?
    /// 클라우드 업로드 완료 여부 (추후 업데이트)
    @Persisted var isUploaded: Bool = false
}

// MARK: - 향후 확장 스키마 (1차 출시 미사용)

// MARK: - VisitedAreaE (지역 집계 - Embedded)
/// 추후 여행 통계 업데이트 시 사용 (지역별 방문 횟수, 배지/스탬프)
final class VisitedAreaE: EmbeddedObject {
    @Persisted var areaCode: Int?
    @Persisted var sigunguCode: Int?
    @Persisted var count: Int = 0
    @Persisted var firstVisitedAt: Date = Date()
    @Persisted var lastVisitedAt: Date = Date()
}

// MARK: - GeoPointE (좌표 - Embedded)
/// 추후 지도 기능 업데이트 시 사용 (네이버 지도 API 연동)
final class GeoPointE: EmbeddedObject {
    @Persisted var lat: Double = 0.0
    @Persisted var lng: Double = 0.0
}

// MARK: - VisitIndexR (파생 인덱스 - 전역 검색/집계용)
/// 추후 검색/통계 기능 업데이트 시 사용 (최근 방문, 전체 검색, 월별 통계)
final class VisitIndexR: Object {
    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted var tripId: ObjectId
    @Persisted var entryId: String = ""
    @Persisted var placeId: String = ""
    @Persisted var placeNameSnapshot: String = ""
    @Persisted var thumbnailURLSnapshot: String?
    @Persisted var areaCode: Int?
    @Persisted var sigunguCode: Int?
    @Persisted var visitedAt: Date = Date()
    @Persisted var tagKeys: List<String>
    @Persisted var createdAt: Date = Date()
    @Persisted var updatedAt: Date = Date()

    override static func indexedProperties() -> [String] {
        return ["tripId", "entryId", "placeId", "areaCode", "sigunguCode", "visitedAt", "createdAt", "updatedAt"]
    }
}

// MARK: - TagR (태그)
/// 추후 태그 기능 업데이트 시 사용 (테마 태그, 색상/이모지 커스터마이징)
final class TagR: Object {
    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted var name: String = ""
    @Persisted var color: String?
    @Persisted var emoji: String?

    override static func indexedProperties() -> [String] {
        return ["name"]
    }
}
