//
//  PlaceDetail.swift
//  KoreaSpots
//
//  Created by YoungJin on 9/29/25.
//

import Foundation

struct PlaceDetail {
    let place: Place
    let images: [PlaceImage]
    let operatingInfo: OperatingInfo?
    let nearbyPlaces: [Place]
}

struct PlaceImage {
    let contentId: String
    let originImageURL: String
    let imageName: String?
    let smallImageURL: String?
}

struct OperatingInfo {
    // 공통 정보 (빠른 UI 표시용, 모든 타입)
    let useTime: String?        // 운영시간/이용시간
    let restDate: String?       // 휴무일/쉬는날
    let useFee: String?         // 이용요금/입장료
    let homepage: String?       // 홈페이지/예약 URL
    let infoCenter: String?     // 문의 및 안내 (전화번호 등)
    let parking: String?        // 주차시설 정보

    // contentTypeId별 특화 정보 (상세 정보)
    let specificInfo: PlaceSpecificInfo?

    // MARK: - Empty Instance
    static let empty = OperatingInfo(
        useTime: "준비 중",
        restDate: "준비 중",
        useFee: "준비 중",
        homepage: "준비 중",
        infoCenter: "준비 중",
        parking: "준비 중",
        specificInfo: nil
    )
}

extension PlaceDetail {
    var hasOperatingInfo: Bool {
        return operatingInfo?.useTime != nil ||
               operatingInfo?.restDate != nil ||
               operatingInfo?.useFee != nil
    }

    var hasImages: Bool {
        return !images.isEmpty
    }

    var hasNearbyPlaces: Bool {
        return !nearbyPlaces.isEmpty
    }
}
