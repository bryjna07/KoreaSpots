//
//  TourAPI.swift
//  KoreaSpots
//
//  Created by YoungJin on 9/25/25.
//

import Foundation
import Moya

//MARK: - Moya TargetType
enum TourAPI {
    /// 지역기반 목록: areaCode(옵셔널), sigunguCode/ contentTypeId는 옵셔널
    case areaBasedList(areaCode: Int?, sigunguCode: Int?, contentTypeId: Int?, cat1: String?, cat2: String?, cat3: String?, numOfRows: Int, pageNo: Int, arrange: String)
    /// 축제 검색: eventStartDate/eventEndDate로 현재 진행중인 축제 조회, areaCode로 지역 필터링 가능
    case searchFestival(eventStartDate: String, eventEndDate: String, areaCode: Int?, numOfRows: Int, pageNo: Int, arrange: String)
    /// 위치기반 관광지: mapX/mapY 좌표 기준 반경 내 관광지, contentTypeId로 타입 필터링 가능
    case locationBasedList(mapX: Double, mapY: Double, radius: Int, contentTypeId: Int?, numOfRows: Int, pageNo: Int, arrange: String)
    /// 키워드 검색: keyword로 통합 검색
    case searchKeyword(keyword: String, areaCode: Int?, sigunguCode: Int?, contentTypeId: Int?, cat1: String?, cat2: String?, cat3: String?, numOfRows: Int, pageNo: Int, arrange: String)
    /// 상세정보 공통: contentId로 기본 상세정보 조회
    case detailCommon(contentId: String)
    /// 상세정보 소개: contentId로 운영정보 등 상세 소개정보 조회
    case detailIntro(contentId: String, contentTypeId: Int)
    /// 상세이미지: contentId로 이미지 목록 조회 (모든 이미지 반환)
    case detailImage(contentId: String)
    /// 상세정보 반복: contentId로 반복정보 조회 (여행코스: 코스 목록)
    case detailInfo(contentId: String, contentTypeId: Int)
}

extension TourAPI: TargetType {
    var baseURL: URL {
        URL(string: "https://apis.data.go.kr")!
    }
    
    private var apiKey: String? {
        return Bundle.main.object(forInfoDictionaryKey: "APIKey") as? String
    }

    var path: String {
        switch self {
        case .areaBasedList:
            return "/B551011/KorService2/areaBasedList2"
        case .searchFestival:
            return "/B551011/KorService2/searchFestival2"
        case .locationBasedList:
            return "/B551011/KorService2/locationBasedList2"
        case .searchKeyword:
            return "/B551011/KorService2/searchKeyword2"
        case .detailCommon:
            return "/B551011/KorService2/detailCommon2"
        case .detailIntro:
            return "/B551011/KorService2/detailIntro2"
        case .detailImage:
            return "/B551011/KorService2/detailImage2"
        case .detailInfo:
            return "/B551011/KorService2/detailInfo2"
        }
    }

    var method: Moya.Method { .get }

    /// 공통 파라미터 (xcconfig → Info.plist 주입된 값 사용)
    private var baseParameters: [String: Any] {
        [
            "serviceKey": apiKey ?? "",
            "_type": "json",
            "MobileOS": "IOS",
            "MobileApp": "KoreaSpots"
        ]
    }

    /// 케이스별 파라미터
    private var caseParameters: [String: Any] {
        switch self {
        case let .areaBasedList(areaCode, sigunguCode, contentTypeId, cat1, cat2, cat3, numOfRows, pageNo, arrange):
            var p: [String: Any] = [
                "numOfRows": numOfRows,
                "pageNo": pageNo,
                "arrange": arrange
            ]
            if let a = areaCode {
                p["areaCode"] = a
            }
            if let s = sigunguCode {
                p["sigunguCode"] = s
            }
            if let c = contentTypeId {
                p["contentTypeId"] = c
            }
            if let c1 = cat1, !c1.isEmpty {
                p["cat1"] = c1
            }
            if let c2 = cat2, !c2.isEmpty {
                p["cat2"] = c2
            }
            if let c3 = cat3, !c3.isEmpty {
                p["cat3"] = c3
            }
            return p

        case let .searchFestival(eventStartDate, eventEndDate, areaCode, numOfRows, pageNo, arrange):
            var p: [String: Any] = [
                "eventStartDate": eventStartDate,
                "eventEndDate": eventEndDate,
                "numOfRows": numOfRows,
                "pageNo": pageNo,
                "arrange": arrange
            ]
            if let a = areaCode {
                p["areaCode"] = a
            }
            return p

        case let .locationBasedList(mapX, mapY, radius, contentTypeId, numOfRows, pageNo, arrange):
            var p: [String: Any] = [
                "mapX": mapX,
                "mapY": mapY,
                "radius": radius,
                "numOfRows": numOfRows,
                "pageNo": pageNo,
                "arrange": arrange
            ]
            if let c = contentTypeId {
                p["contentTypeId"] = c
            }
            return p

        case let .searchKeyword(keyword, areaCode, sigunguCode, contentTypeId, cat1, cat2, cat3, numOfRows, pageNo, arrange):
            var p: [String: Any] = [
                "keyword": keyword,
                "numOfRows": numOfRows,
                "pageNo": pageNo,
                "arrange": arrange
            ]
            if let a = areaCode {
                p["areaCode"] = a
            }
            if let s = sigunguCode {
                p["sigunguCode"] = s
            }
            if let c = contentTypeId {
                p["contentTypeId"] = c
            }
            if let c1 = cat1, !c1.isEmpty {
                p["cat1"] = c1
            }
            if let c2 = cat2, !c2.isEmpty {
                p["cat2"] = c2
            }
            if let c3 = cat3, !c3.isEmpty {
                p["cat3"] = c3
            }
            return p

        case let .detailCommon(contentId):
            return [
                "contentId": contentId
            ]

        case let .detailIntro(contentId, contentTypeId):
            return [
                "contentId": contentId,
                "contentTypeId": contentTypeId
            ]

        case let .detailImage(contentId):
            return [
                "contentId": contentId,
                "imageYN": "Y"
            ]

        case let .detailInfo(contentId, contentTypeId):
            return [
                "contentId": contentId,
                "contentTypeId": contentTypeId
            ]
        }
    }

    var task: Task {
        // GET이므로 쿼리스트링 인코딩
        let params = baseParameters.merging(caseParameters, uniquingKeysWith: { _, new in new })
        return .requestParameters(parameters: params, encoding: URLEncoding.default)
    }

    var headers: [String : String]? {
        ["Accept": "application/json"]
    }

    var sampleData: Data {
        Data()
    } // Unit Test stub용
}

