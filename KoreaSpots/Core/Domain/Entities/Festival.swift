//
//  Festival.swift
//  KoreaSpots
//
//  Created by YoungJin on 9/25/25.
//

import Foundation

struct Festival {
    let contentId: String
    let title: String
    let address: String
    let imageURL: String?
    let eventStartDate: String
    let eventEndDate: String
    let tel: String?
    let mapX: Double?
    let mapY: Double?
    let overview: String?
}

extension Festival: Equatable {
    static func == (lhs: Festival, rhs: Festival) -> Bool {
        lhs.contentId == rhs.contentId
    }
}