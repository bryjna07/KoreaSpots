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
    let distance: Int? // 미터 단위
}

extension Place: Equatable {
    static func == (lhs: Place, rhs: Place) -> Bool {
        lhs.contentId == rhs.contentId
    }
}