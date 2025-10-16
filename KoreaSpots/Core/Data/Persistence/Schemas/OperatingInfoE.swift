//
//  OperatingInfoE.swift
//  KoreaSpots
//
//  Created by YoungJin on 10/16/25.
//

import Foundation
import RealmSwift

/// 운영정보 Realm Embedded Object (PlaceR에 포함)
final class OperatingInfoE: EmbeddedObject {
    // MARK: - 공통 정보 (빠른 UI 표시용)
    @Persisted var useTime: String?        // 운영시간/이용시간
    @Persisted var restDate: String?       // 휴무일/쉬는날
    @Persisted var useFee: String?         // 이용요금/입장료
    @Persisted var homepage: String?       // 홈페이지/예약 URL
    @Persisted var infoCenter: String?     // 문의 및 안내 (전화번호 등)
    @Persisted var parking: String?        // 주차시설 정보

    // MARK: - 특화 정보 (JSON 문자열로 저장)
    @Persisted var specificInfoJson: String?
    /// contentTypeId (12=관광지, 14=문화시설, 15=축제, 25=여행코스, 28=레포츠, 32=숙박, 38=쇼핑, 39=음식점)
    @Persisted var contentTypeId: Int?

    // MARK: - 캐싱 정보
    @Persisted var cachedAt: Date = Date()
}

// MARK: - Mapping Extensions

extension OperatingInfoE {
    /// Domain OperatingInfo를 Realm OperatingInfoE로 변환
    convenience init(from operatingInfo: OperatingInfo, contentTypeId: Int) {
        self.init()
        self.useTime = operatingInfo.useTime
        self.restDate = operatingInfo.restDate
        self.useFee = operatingInfo.useFee
        self.homepage = operatingInfo.homepage
        self.infoCenter = operatingInfo.infoCenter
        self.parking = operatingInfo.parking
        self.contentTypeId = contentTypeId
        self.cachedAt = Date()

        // PlaceSpecificInfo를 JSON으로 인코딩
        if let specificInfo = operatingInfo.specificInfo {
            do {
                let encoder = JSONEncoder()
                let jsonData = try encoder.encode(specificInfo)
                self.specificInfoJson = String(data: jsonData, encoding: .utf8)
            } catch {
                print("❌ Failed to encode PlaceSpecificInfo: \(error)")
                self.specificInfoJson = nil
            }
        }
    }

    /// Realm OperatingInfoE를 Domain OperatingInfo로 변환
    func toDomain() -> OperatingInfo {
        var specificInfo: PlaceSpecificInfo? = nil

        // JSON 문자열을 PlaceSpecificInfo로 디코딩
        if let jsonString = specificInfoJson,
           let jsonData = jsonString.data(using: .utf8) {
            do {
                let decoder = JSONDecoder()
                specificInfo = try decoder.decode(PlaceSpecificInfo.self, from: jsonData)
            } catch {
                print("❌ Failed to decode PlaceSpecificInfo: \(error)")
            }
        }

        return OperatingInfo(
            useTime: useTime,
            restDate: restDate,
            useFee: useFee,
            homepage: homepage,
            infoCenter: infoCenter,
            parking: parking,
            specificInfo: specificInfo
        )
    }

    /// 캐시가 유효한지 확인 (TTL: 7일)
    func isValid(ttl: TimeInterval = 7 * 24 * 60 * 60) -> Bool {
        return Date().timeIntervalSince(cachedAt) < ttl
    }
}
