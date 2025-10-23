//
//  TourAPIDetailIntroResponse.swift
//  KoreaSpots
//
//  Created by YoungJin on 10/16/25.
//

import Foundation

/// detailIntro2 API 전용 응답 구조
struct TourAPIDetailIntroResponse: Decodable {
    let response: ResponseBody

    var items: [TourAPIDetailIntroItem] {
        return response.body?.items?.item ?? []
    }

    var totalCount: Int {
        return response.body?.totalCount ?? 0
    }

    struct ResponseBody: Decodable {
        let header: TourAPIHeader
        let body: Body?
    }

    struct Body: Decodable {
        let numOfRows: Int
        let pageNo: Int
        let totalCount: Int
        let items: Items?
    }

    struct Items: Decodable {
        let item: [TourAPIDetailIntroItem]

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)

            if let itemArray = try? container.decode([TourAPIDetailIntroItem].self, forKey: .item) {
                item = itemArray
            } else {
                item = []
            }
        }

        private enum CodingKeys: String, CodingKey {
            case item
        }
    }
}
