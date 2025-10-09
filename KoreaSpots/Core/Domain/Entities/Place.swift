//
//  Place.swift
//  KoreaSpots
//
//  Created by YoungJin on 9/25/25.
//

import Foundation

struct Place {
    let contentId: String
    let title: String
    let address: String
    let imageURL: String?
    let mapX: Double?
    let mapY: Double?
    let tel: String?
    let overview: String?
    let contentTypeId: Int
    let areaCode: Int
    let sigunguCode: Int?
    let cat1: String?
    let cat2: String?
    let cat3: String?
    let distance: Int? // 미터 단위
}

extension Place: Equatable {
    static func == (lhs: Place, rhs: Place) -> Bool {
        lhs.contentId == rhs.contentId
    }

    static var empty: Place {
        return Place(
            contentId: "",
            title: "",
            address: "",
            imageURL: nil,
            mapX: nil,
            mapY: nil,
            tel: nil,
            overview: nil,
            contentTypeId: 0,
            areaCode: 0,
            sigunguCode: nil,
            cat1: nil,
            cat2: nil,
            cat3: nil,
            distance: nil
        )
    }
}