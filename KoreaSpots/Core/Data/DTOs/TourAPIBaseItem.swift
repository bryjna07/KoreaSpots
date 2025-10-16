//
//  TourAPIBaseItem.swift
//  KoreaSpots
//
//  Created by YoungJin on 10/16/25.
//

import Foundation

/// Tour API의 공통 응답 DTO
///
/// 사용 API:
/// - areaBasedList2: 지역 기반 목록 조회
/// - searchKeyword2: 키워드 검색
/// - searchFestival2: 축제 검색 (+ eventenddate, eventstartdate, progresstype, festivaltype)
/// - locationBasedList2: 위치 기반 목록 조회 (+ dist)
/// - detailCommon2: 상세 공통 정보 (+ homepage, telname, overview)
struct TourAPIBaseItem: Decodable {
    // MARK: - 필수 필드 (항상 존재)
    let contentid: String  // 콘텐츠 ID
    let title: String  // 콘텐츠 제목
    let contenttypeid: String  // 콘텐츠 타입 ID (12=관광지, 14=문화시설, 15=축제, 25=여행코스, 28=레포츠, 32=숙박, 38=쇼핑, 39=음식점)
    let addr1: String  // 주소
    let areacode: String  // 지역 코드
    let sigungucode: String  // 시군구 코드
    let modifiedtime: String  // 수정일

    // MARK: - 선택 필드 (모든 API 공통)
    let addr2: String?  // 상세주소
    let cat1: String?  // 대분류 코드
    let cat2: String?  // 중분류 코드
    let cat3: String?  // 소분류 코드
    let createdtime: String?  // 생성일
    let firstimage: String?  // 대표이미지 (원본)
    let firstimage2: String?  // 대표이미지 (썸네일)
    let cpyrhtDivCd: String?  // 저작권 유형
    let mapx: String?  // GPS X좌표 (경도)
    let mapy: String?  // GPS Y좌표 (위도)
    let mlevel: String?  // Map Level
    let tel: String?  // 전화번호
    let zipcode: String?  // 우편번호

    // MARK: - 법정동 코드 (모든 API 공통)
    let lDongRegnCd: String?  // 법정동 지역 코드
    let lDongSignguCd: String?  // 법정동 시군구 코드
    let lclsSystm1: String?  // 지역분류체계 1
    let lclsSystm2: String?  // 지역분류체계 2
    let lclsSystm3: String?  // 지역분류체계 3

    // MARK: - 축제 전용 (searchFestival2)
    let eventenddate: String?  // 행사 종료일 (YYYYMMDD)
    let eventstartdate: String?  // 행사 시작일 (YYYYMMDD)
    let progresstype: String?  // 진행유형 (선택안함 등)
    let festivaltype: String?  // 축제유형 (선택안함 등)

    // MARK: - 위치 기반 전용 (locationBasedList2)
    let dist: String?  // 거리 (m 단위, 소수점 포함 문자열)

    // MARK: - 상세 공통 전용 (detailCommon2)
    let homepage: String?  // 홈페이지 주소 (HTML 태그 포함)
    let telname: String?  // 전화번호명
    let overview: String?  // 개요 (상세 설명)

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // MARK: - 필수 필드
        contentid = try container.decode(String.self, forKey: .contentid)
        title = try container.decode(String.self, forKey: .title)
        contenttypeid = try container.decode(String.self, forKey: .contenttypeid)
        addr1 = try container.decode(String.self, forKey: .addr1)
        areacode = try container.decode(String.self, forKey: .areacode)
        sigungucode = try container.decode(String.self, forKey: .sigungucode)
        modifiedtime = try container.decode(String.self, forKey: .modifiedtime)

        // MARK: - 선택 필드 (모든 API 공통)
        addr2 = try container.decodeIfPresent(String.self, forKey: .addr2)
        cat1 = try container.decodeIfPresent(String.self, forKey: .cat1)
        cat2 = try container.decodeIfPresent(String.self, forKey: .cat2)
        cat3 = try container.decodeIfPresent(String.self, forKey: .cat3)
        createdtime = try container.decodeIfPresent(String.self, forKey: .createdtime)
        firstimage = try container.decodeIfPresent(String.self, forKey: .firstimage)
        firstimage2 = try container.decodeIfPresent(String.self, forKey: .firstimage2)
        cpyrhtDivCd = try container.decodeIfPresent(String.self, forKey: .cpyrhtDivCd)
        mapx = try container.decodeIfPresent(String.self, forKey: .mapx)
        mapy = try container.decodeIfPresent(String.self, forKey: .mapy)
        mlevel = try container.decodeIfPresent(String.self, forKey: .mlevel)
        tel = try container.decodeIfPresent(String.self, forKey: .tel)
        zipcode = try container.decodeIfPresent(String.self, forKey: .zipcode)

        // MARK: - 법정동 코드
        lDongRegnCd = try container.decodeIfPresent(String.self, forKey: .lDongRegnCd)
        lDongSignguCd = try container.decodeIfPresent(String.self, forKey: .lDongSignguCd)
        lclsSystm1 = try container.decodeIfPresent(String.self, forKey: .lclsSystm1)
        lclsSystm2 = try container.decodeIfPresent(String.self, forKey: .lclsSystm2)
        lclsSystm3 = try container.decodeIfPresent(String.self, forKey: .lclsSystm3)

        // MARK: - 축제 전용
        eventenddate = try container.decodeIfPresent(String.self, forKey: .eventenddate)
        eventstartdate = try container.decodeIfPresent(String.self, forKey: .eventstartdate)
        progresstype = try container.decodeIfPresent(String.self, forKey: .progresstype)
        festivaltype = try container.decodeIfPresent(String.self, forKey: .festivaltype)

        // MARK: - 위치 기반 전용
        dist = try container.decodeIfPresent(String.self, forKey: .dist)

        // MARK: - 상세 공통 전용
        homepage = try container.decodeIfPresent(String.self, forKey: .homepage)
        telname = try container.decodeIfPresent(String.self, forKey: .telname)
        overview = try container.decodeIfPresent(String.self, forKey: .overview)
    }

    private enum CodingKeys: String, CodingKey {
        // 필수
        case contentid, contenttypeid, title, addr1, areacode, sigungucode, modifiedtime
        // 공통 선택
        case addr2, cat1, cat2, cat3, createdtime, firstimage, firstimage2, cpyrhtDivCd
        case mapx, mapy, mlevel, tel, zipcode
        // 법정동 코드
        case lDongRegnCd, lDongSignguCd, lclsSystm1, lclsSystm2, lclsSystm3
        // 축제 전용
        case eventenddate, eventstartdate, progresstype, festivaltype
        // 위치 기반 전용
        case dist
        // 상세 공통 전용
        case homepage, telname, overview
    }
}
