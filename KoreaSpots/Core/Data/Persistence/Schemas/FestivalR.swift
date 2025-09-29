//
//  FestivalR.swift
//  KoreaSpots
//
//  Created by YoungJin on 9/27/25.
//

import Foundation
import RealmSwift

class FestivalR: Object {
    @Persisted var contentId: String = ""
    @Persisted var title: String = ""
    @Persisted var address: String = ""
    @Persisted var imageURL: String?
    @Persisted var eventStartDate: String = ""
    @Persisted var eventEndDate: String = ""
    @Persisted var tel: String?
    @Persisted var mapX: Double?
    @Persisted var mapY: Double?
    @Persisted var overview: String?

    // 캐싱 관련 필드
    @Persisted var cachedAt: Date = Date()
    @Persisted var lastModifiedTime: String = ""

    override static func primaryKey() -> String? {
        return "contentId"
    }

    override static func indexedProperties() -> [String] {
        return ["eventStartDate", "eventEndDate", "cachedAt"]
    }
}

// MARK: - Mapping Extensions
extension FestivalR {
    convenience init(festival: Festival) {
        self.init()
        self.contentId = festival.contentId
        self.title = festival.title
        self.address = festival.address
        self.imageURL = festival.imageURL
        self.eventStartDate = festival.eventStartDate
        self.eventEndDate = festival.eventEndDate
        self.tel = festival.tel
        self.mapX = festival.mapX
        self.mapY = festival.mapY
        self.overview = festival.overview
        self.cachedAt = Date()
    }

    func toDomain() -> Festival {
        return Festival(
            contentId: contentId,
            title: title,
            address: address,
            imageURL: imageURL,
            eventStartDate: eventStartDate,
            eventEndDate: eventEndDate,
            tel: tel,
            mapX: mapX,
            mapY: mapY,
            overview: overview
        )
    }
}