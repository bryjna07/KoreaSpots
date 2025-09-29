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
    /// 지역기반 목록: areaCode=1(서울), sigunguCode/ contentTypeId는 옵셔널
    case areaBasedList(areaCode: Int, sigunguCode: Int?, contentTypeId: Int?, numOfRows: Int, pageNo: Int, arrange: String)
    /// 축제 검색: eventStartDate/eventEndDate로 현재 진행중인 축제 조회
    case searchFestival(eventStartDate: String, eventEndDate: String, numOfRows: Int, pageNo: Int, arrange: String)
    /// 위치기반 관광지: mapX/mapY 좌표 기준 반경 내 관광지
    case locationBasedList(mapX: Double, mapY: Double, radius: Int, numOfRows: Int, pageNo: Int, arrange: String)
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
        case let .areaBasedList(areaCode, sigunguCode, contentTypeId, numOfRows, pageNo, arrange):
            var p: [String: Any] = [
                "areaCode": areaCode,
                "numOfRows": numOfRows,
                "pageNo": pageNo,
                "arrange": arrange
            ]
            if let s = sigunguCode {
                p["sigunguCode"] = s
            }
            if let c = contentTypeId {
                p["contentTypeId"] = c
            }
            return p

        case let .searchFestival(eventStartDate, eventEndDate, numOfRows, pageNo, arrange):
            return [
                "eventStartDate": eventStartDate,
                "eventEndDate": eventEndDate,
                "numOfRows": numOfRows,
                "pageNo": pageNo,
                "arrange": arrange
            ]

        case let .locationBasedList(mapX, mapY, radius, numOfRows, pageNo, arrange):
            return [
                "mapX": mapX,
                "mapY": mapY,
                "radius": radius,
                "numOfRows": numOfRows,
                "pageNo": pageNo,
                "arrange": arrange
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

