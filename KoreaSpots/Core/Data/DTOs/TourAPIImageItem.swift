//
//  TourAPIImageItem.swift
//  KoreaSpots
//
//  Created by YoungJin on 9/29/25.
//

import Foundation

struct TourAPIImageItem: Decodable {
    let contentid: String
    let originimgurl: String
    let imgname: String?
    let smallimageurl: String?
    let cpyrhtDivCd: String?
    let serialnum: String?

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        contentid = try container.decode(String.self, forKey: .contentid)
        originimgurl = try container.decode(String.self, forKey: .originimgurl)
        imgname = try container.decodeIfPresent(String.self, forKey: .imgname)
        smallimageurl = try container.decodeIfPresent(String.self, forKey: .smallimageurl)
        cpyrhtDivCd = try container.decodeIfPresent(String.self, forKey: .cpyrhtDivCd)
        serialnum = try container.decodeIfPresent(String.self, forKey: .serialnum)
    }

    private enum CodingKeys: String, CodingKey {
        case contentid, originimgurl, imgname, smallimageurl, cpyrhtDivCd, serialnum
    }
}

struct TourAPIImageResponse: Decodable {
    let response: TourAPIImageResponseBody
}

struct TourAPIImageResponseBody: Decodable {
    let header: TourAPIHeader
    let body: TourAPIImageBodyContent?
}

struct TourAPIImageBodyContent: Decodable {
    let items: TourAPIImageItems?
    let numOfRows: Int
    let pageNo: Int
    let totalCount: Int
}

struct TourAPIImageItems: Decodable {
    let item: [TourAPIImageItem]
}