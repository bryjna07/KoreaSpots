//
//  TourAPIHeader.swift
//  KoreaSpots
//
//  Created by YoungJin on 9/27/25.
//

import Foundation

struct TourAPIHeader: Decodable {
    let resultCode: String
    let resultMsg: String

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        resultCode = try container.decode(String.self, forKey: .resultCode)
        resultMsg = try container.decode(String.self, forKey: .resultMsg)
    }

    private enum CodingKeys: String, CodingKey {
        case resultCode
        case resultMsg
    }
}