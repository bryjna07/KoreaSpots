//
//  TourAPIItem.swift
//  KoreaSpots
//
//  Created by YoungJin on 9/27/25.
//

import Foundation

struct TourAPIItem: Decodable {
    // MARK: - 필수 필드 (항상 존재해야 하는 데이터)
    let contentid: String
    let title: String
    let contenttypeid: String

    // MARK: - 반필수 필드 (대부분 존재하지만 빈 값일 수 있음)
    let addr1: String
    let areacode: String
    let sigungucode: String
    let modifiedtime: String

    // MARK: - 선택 필드 (존재하지 않을 수 있음)
    let addr2: String?
    let booktour: String?
    let cat1: String?
    let cat2: String?
    let cat3: String?
    let createdtime: String?
    let dist: String?
    let eventenddate: String?
    let eventstartdate: String?
    let firstimage: String?
    let firstimage2: String?
    let mapx: String?
    let mapy: String?
    let mlevel: String?
    let overview: String?
    let readcount: String?
    let tel: String?
    let zipcode: String?
    let cpyrhtDivCd: String?

    // MARK: - 위치기반 API 응답 전용 필드들 (요청에는 미사용)
    let lDongRegnCd: String?
    let lDongSignguCd: String?
    let lclsSystm1: String?
    let lclsSystm2: String?
    let lclsSystm3: String?

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // MARK: - 필수 필드 디코딩 (실패 시 에러 발생)
        contentid = try container.decode(String.self, forKey: .contentid)
        title = try container.decode(String.self, forKey: .title)
        contenttypeid = try container.decode(String.self, forKey: .contenttypeid)

        // MARK: - 반필수 필드 디코딩 (빈 문자열로 기본값 설정)
        addr1 = try container.decodeIfPresent(String.self, forKey: .addr1) ?? ""
        areacode = try container.decodeIfPresent(String.self, forKey: .areacode) ?? ""
        sigungucode = try container.decodeIfPresent(String.self, forKey: .sigungucode) ?? ""
        modifiedtime = try container.decodeIfPresent(String.self, forKey: .modifiedtime) ?? ""

        // MARK: - 선택 필드 디코딩 (nil 허용)
        addr2 = try container.decodeIfPresent(String.self, forKey: .addr2)
        booktour = try container.decodeIfPresent(String.self, forKey: .booktour)
        cat1 = try container.decodeIfPresent(String.self, forKey: .cat1)
        cat2 = try container.decodeIfPresent(String.self, forKey: .cat2)
        cat3 = try container.decodeIfPresent(String.self, forKey: .cat3)
        createdtime = try container.decodeIfPresent(String.self, forKey: .createdtime)
        dist = try container.decodeIfPresent(String.self, forKey: .dist)
        eventenddate = try container.decodeIfPresent(String.self, forKey: .eventenddate)
        eventstartdate = try container.decodeIfPresent(String.self, forKey: .eventstartdate)
        firstimage = try container.decodeIfPresent(String.self, forKey: .firstimage)
        firstimage2 = try container.decodeIfPresent(String.self, forKey: .firstimage2)
        mapx = try container.decodeIfPresent(String.self, forKey: .mapx)
        mapy = try container.decodeIfPresent(String.self, forKey: .mapy)
        mlevel = try container.decodeIfPresent(String.self, forKey: .mlevel)
        overview = try container.decodeIfPresent(String.self, forKey: .overview)
        readcount = try container.decodeIfPresent(String.self, forKey: .readcount)
        tel = try container.decodeIfPresent(String.self, forKey: .tel)
        zipcode = try container.decodeIfPresent(String.self, forKey: .zipcode)
        cpyrhtDivCd = try container.decodeIfPresent(String.self, forKey: .cpyrhtDivCd)

        // MARK: - 위치기반 API 응답 전용 필드들 디코딩
        lDongRegnCd = try container.decodeIfPresent(String.self, forKey: .lDongRegnCd)
        lDongSignguCd = try container.decodeIfPresent(String.self, forKey: .lDongSignguCd)
        lclsSystm1 = try container.decodeIfPresent(String.self, forKey: .lclsSystm1)
        lclsSystm2 = try container.decodeIfPresent(String.self, forKey: .lclsSystm2)
        lclsSystm3 = try container.decodeIfPresent(String.self, forKey: .lclsSystm3)
    }

    private enum CodingKeys: String, CodingKey {
        case addr1, addr2, areacode, booktour, cat1, cat2, cat3
        case contentid, contenttypeid, createdtime, dist
        case eventenddate, eventstartdate, firstimage, firstimage2
        case mapx, mapy, mlevel, modifiedtime, overview
        case readcount, sigungucode, tel, title, zipcode, cpyrhtDivCd
        case lDongRegnCd, lDongSignguCd, lclsSystm1, lclsSystm2, lclsSystm3
    }
}