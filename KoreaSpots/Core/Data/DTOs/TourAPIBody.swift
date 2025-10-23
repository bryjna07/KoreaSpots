//
//  TourAPIBody.swift
//  KoreaSpots
//
//  Created by YoungJin on 9/27/25.
//

import Foundation

struct TourAPIBody: Decodable {
    // MARK: - 필수 필드 (API 응답에 항상 존재)
    let numOfRows: Int
    let pageNo: Int
    let totalCount: Int

    // MARK: - 조건부 필수 필드 (데이터가 있을 때만 존재)
    let items: TourAPIItems?

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // MARK: - 필수 페이징 정보 디코딩
        numOfRows = try container.decode(Int.self, forKey: .numOfRows)
        pageNo = try container.decode(Int.self, forKey: .pageNo)
        totalCount = try container.decode(Int.self, forKey: .totalCount)

        // MARK: - 조건부 데이터 (totalCount가 0이면 nil일 수 있음)
        items = try container.decodeIfPresent(TourAPIItems.self, forKey: .items)
    }

    private enum CodingKeys: String, CodingKey {
        case items, numOfRows, pageNo, totalCount
    }
}

struct TourAPIItems: Decodable {
    let item: [TourAPIBaseItem]

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // MARK: - 방어적 디코딩: 실패 시 빈 배열 반환
        if let itemArray = try? container.decode([TourAPIBaseItem].self, forKey: .item) {
            item = itemArray
        } else {
            // API에서 item이 없거나 잘못된 형식일 때 빈 배열로 처리
            item = []
        }
    }

    private enum CodingKeys: String, CodingKey {
        case item
    }
}