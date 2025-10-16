//
//  TourAPIResponse.swift
//  KoreaSpots
//
//  Created by YoungJin on 9/25/25.
//

import Foundation

struct TourAPIResponse: Decodable {
    let response: TourAPIResponseBody

    var items: [TourAPIBaseItem] {
        return response.body?.items?.item ?? []
    }

    var totalCount: Int {
        return response.body?.totalCount ?? 0
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        response = try container.decode(TourAPIResponseBody.self, forKey: .response)
    }

    private enum CodingKeys: String, CodingKey {
        case response
    }
}

struct TourAPIResponseBody: Decodable {
    let header: TourAPIHeader
    let body: TourAPIBody?

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        header = try container.decode(TourAPIHeader.self, forKey: .header)
        body = try container.decodeIfPresent(TourAPIBody.self, forKey: .body)
    }

    private enum CodingKeys: String, CodingKey {
        case header, body
    }
}
