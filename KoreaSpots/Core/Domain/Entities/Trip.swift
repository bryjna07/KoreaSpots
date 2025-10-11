//
//  Trip.swift
//  KoreaSpots
//
//  Created by YoungJin on 10/10/25.
//

import Foundation

// MARK: - Trip (여행 기록)
struct Trip: Hashable {
    let id: String
    let title: String
    let coverPhotoPath: String?
    let startDate: Date
    let endDate: Date
    let memo: String
    let visitedPlaces: [VisitedPlace]

    // MARK: - 향후 확장 필드 (1차 출시 미사용)
    let visitedAreas: [VisitedArea]
    let tags: [String]
    let createdAt: Date
    let updatedAt: Date

    // MARK: - 향후 확장 필드
    let isRouteTrackingEnabled: Bool
    let totalDistance: Double?
    let travelStyle: String?

    var dateRangeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        return "\(formatter.string(from: startDate)) - \(formatter.string(from: endDate))"
    }

    var duration: Int {
        Calendar.current.dateComponents([.day], from: startDate, to: endDate).day ?? 0
    }

    var visitedPlaceCount: Int {
        visitedPlaces.count
    }

    // Hashable conformance
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: Trip, rhs: Trip) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - VisitedPlace (방문 관광지)
struct VisitedPlace: Hashable {
    let entryId: String
    let placeId: String
    let placeNameSnapshot: String
    let thumbnailURLSnapshot: String?
    let areaCode: Int?
    let sigunguCode: Int?
    let addedAt: Date
    let order: Int
    let note: String?
    let rating: Int?

    // MARK: - 향후 확장 필드
    let location: GeoPoint?
    let visitedTime: Date?
    let stayDuration: Int?
    let routeIndex: Int?

    // MARK: - 유저 사진 (여행 기록용)
    let photos: [VisitPhoto]
}

// MARK: - VisitPhoto (방문지 사진)
struct VisitPhoto: Hashable {
    let photoId: String
    let localPath: String
    let caption: String?
    let takenAt: Date
    let isCover: Bool
    let order: Int
    let width: Int
    let height: Int

    // MARK: - 향후 확장 필드
    let cloudURL: String?
    let isUploaded: Bool
}

// MARK: - 향후 확장 엔티티 (1차 출시 미사용)

// MARK: - VisitedArea (지역 집계)
/// 추후 여행 통계 업데이트 시 사용
struct VisitedArea: Hashable {
    let areaCode: Int?
    let sigunguCode: Int?
    let count: Int
    let firstVisitedAt: Date
    let lastVisitedAt: Date

    var areaName: String {
        AreaCode(rawValue: areaCode ?? 12)?.displayName ?? "알 수 없음"
    }
}

// MARK: - GeoPoint (좌표)
/// 추후 지도 기능 업데이트 시 사용 (네이버 지도 API)
struct GeoPoint: Hashable {
    let lat: Double
    let lng: Double
}

// MARK: - TripStatistics (여행 통계)
struct TripStatistics: Hashable {
    let totalTripCount: Int
    let totalPlaceCount: Int
    let mostVisitedAreas: [VisitedArea]
}
