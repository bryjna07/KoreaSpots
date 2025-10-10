//
//  Trip.swift
//  KoreaSpots
//
//  Created by YoungJin on 10/10/25.
//

import Foundation

// MARK: - Trip (여행 기록)
struct Trip {
    let id: String
    let title: String
    let coverPhotoPath: String?
    let startDate: Date
    let endDate: Date
    let memo: String
    let visitedPlaces: [VisitedPlace]
    let visitedAreas: [VisitedArea]
    let tags: [String]
    let createdAt: Date
    let updatedAt: Date

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
}

// MARK: - VisitedPlace (방문 관광지)
struct VisitedPlace {
    let entryId: String
    let placeId: String
    let placeNameSnapshot: String
    let thumbnailURLSnapshot: String?
    let areaCode: Int
    let sigunguCode: Int
    let addedAt: Date
    let order: Int
    let note: String?
    let rating: Int?
    let location: GeoPoint?
}

// MARK: - VisitedArea (지역 집계)
struct VisitedArea {
    let areaCode: Int
    let sigunguCode: Int?
    let count: Int
    let firstVisitedAt: Date
    let lastVisitedAt: Date

    var areaName: String {
        AreaCode(rawValue: areaCode)?.displayName ?? "알 수 없음"
    }
}

// MARK: - GeoPoint (좌표)
struct GeoPoint {
    let lat: Double
    let lng: Double
}

// MARK: - TripStatistics (여행 통계)
struct TripStatistics {
    let totalTripCount: Int
    let totalPlaceCount: Int
    let mostVisitedAreas: [VisitedArea]
}
