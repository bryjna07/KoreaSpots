//
//  TourAPIDetailIntroItem.swift
//  KoreaSpots
//
//  Created by YoungJin on 10/16/25.
//

import Foundation

/// detailIntro2 API 응답 래퍼
/// contentTypeId에 따라 적절한 DetailIntroItem 타입으로 동적 디코딩
struct TourAPIDetailIntroItem: Decodable {
    let contentTypeId: String
    let detail: DetailIntroItem

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        contentTypeId = try container.decode(String.self, forKey: .contenttypeid)

        // contentTypeId에 따라 적절한 타입으로 디코딩
        switch contentTypeId {
        case "12":  // 관광지
            detail = try TouristSpotDetailIntro(from: decoder)
        case "14":  // 문화시설
            detail = try CulturalFacilityDetailIntro(from: decoder)
        case "15":  // 축제
            detail = try FestivalDetailIntro(from: decoder)
        case "25":  // 여행코스
            detail = try TravelCourseDetailIntro(from: decoder)
        case "28":  // 레포츠
            detail = try LeisureSportsDetailIntro(from: decoder)
        case "32":  // 숙박
            detail = try AccommodationDetailIntro(from: decoder)
        case "38":  // 쇼핑
            detail = try ShoppingDetailIntro(from: decoder)
        case "39":  // 음식점
            detail = try RestaurantDetailIntro(from: decoder)
        default:
            detail = try UnknownDetailIntro(from: decoder)
        }
    }

    private enum CodingKeys: String, CodingKey {
        case contenttypeid
    }
}
