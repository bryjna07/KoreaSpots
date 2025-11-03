//
//  TravelCourseDetailItem.swift
//  KoreaSpots
//
//  Created by YoungJin on 10/28/25.
//

import Foundation

// MARK: - Travel Course Detail Response

struct TravelCourseDetailResponse: Decodable {
    let response: TravelCourseDetailResponseBody

    var items: [TravelCourseDetailItem] {
        return response.body?.items?.item ?? []
    }
}

struct TravelCourseDetailResponseBody: Decodable {
    let header: TourAPIHeader
    let body: TravelCourseDetailBody?
}

struct TravelCourseDetailBody: Decodable {
    let items: TravelCourseDetailItems?
    let numOfRows: Int?
    let pageNo: Int?
    let totalCount: Int?
}

struct TravelCourseDetailItems: Decodable {
    let item: [TravelCourseDetailItem]
}

// MARK: - Travel Course Detail Item (여행코스 상세 반복정보)

struct TravelCourseDetailItem: Decodable {
    let contentId: String
    let contentTypeId: String
    let subNum: String?             // 코스 순서
    let subContentId: String?       // 하위 콘텐츠 ID
    let subName: String?            // 코스 이름
    let subDetailOverview: String?  // 코스 설명
    let subDetailImg: String?       // 코스 이미지
    let subDetailAlt: String?       // 이미지 설명

    init(contentId: String, contentTypeId: String, subNum: String?, subContentId: String?, subName: String?, subDetailOverview: String?, subDetailImg: String?, subDetailAlt: String?) {
        self.contentId = contentId
        self.contentTypeId = contentTypeId
        self.subNum = subNum
        self.subContentId = subContentId
        self.subName = subName
        self.subDetailOverview = subDetailOverview
        self.subDetailImg = subDetailImg
        self.subDetailAlt = subDetailAlt
    }

    private enum CodingKeys: String, CodingKey {
        case contentId = "contentid"
        case contentTypeId = "contenttypeid"
        case subNum = "subnum"
        case subContentId = "subcontentid"
        case subName = "subname"
        case subDetailOverview = "subdetailoverview"
        case subDetailImg = "subdetailimg"
        case subDetailAlt = "subdetailalt"
    }
}
