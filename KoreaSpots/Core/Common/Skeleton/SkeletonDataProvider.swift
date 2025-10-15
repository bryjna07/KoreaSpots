//
//  SkeletonDataProvider.swift
//  KoreaSpots
//
//  Created by YoungJin on 10/14/25.
//

import Foundation

/// 스켈레톤용 더미 데이터 생성
struct SkeletonDataProvider {

    /// 스켈레톤용 더미 Place 생성
    static func makeSkeletonPlaces(count: Int, type: PlaceType) -> [Place] {
        return (0..<count).map { index in
            Place(
                contentId: "skeleton-\(type.rawValue)-\(index)",
                title: "Loading...",
                address: "Loading...",
                imageURL: nil,
                mapX: nil,
                mapY: nil,
                tel: nil,
                overview: nil,
                contentTypeId: type.contentTypeId,
                areaCode: nil,
                sigunguCode: nil,
                cat1: nil,
                cat2: nil,
                cat3: nil,
                distance: nil,
                eventMeta: type.needsEventMeta ? EventMeta(eventStartDate: "", eventEndDate: "") : nil,
                isCustom: false,
                customPlaceId: nil,
                userProvidedImagePath: nil
            )
        }
    }

    enum PlaceType: String {
        case festival
        case place
        case attraction

        var contentTypeId: Int {
            switch self {
            case .festival: return 15
            case .place, .attraction: return 12
            }
        }

        var needsEventMeta: Bool {
            return self == .festival
        }
    }
}

/// TODO: - API 에러용 Placeholder Cell 생성 필요
