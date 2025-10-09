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
    @Persisted var contentTypeId: Int = 12
    @Persisted var cat1: String?
    @Persisted var cat2: String?
    @Persisted var cat3: String?
    @Persisted var distance: Int?

    // 캐싱 관련 필드
    @Persisted var cachedAt: Date = Date()
    @Persisted var lastModifiedTime: String = ""
    @Persisted var areaCode: Int = 0
    @Persisted var sigunguCode: Int = 0

    override static func primaryKey() -> String? {
        return "contentId"
    }

    override static func indexedProperties() -> [String] {
        return ["contentTypeId", "areaCode", "sigunguCode", "cat1", "cat2", "cat3", "cachedAt"]
    }
}

// MARK: - Mapping Extensions
extension PlaceR {
    convenience init(place: Place, areaCode: Int = 0, sigunguCode: Int = 0) {
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
        self.areaCode = areaCode
        self.sigunguCode = sigunguCode
        self.cachedAt = Date()
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
            distance: distance
        )
    }
}
