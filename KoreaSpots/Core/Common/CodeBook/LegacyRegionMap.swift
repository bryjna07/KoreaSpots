//
//  LegacyRegionMap.swift
//  KoreaSpots
//
//  Created by YoungJin on 11/12/25.
//

import Foundation

/// 옛 지역 코드(areaCode/sigunguCode)를 법정동 코드(lDongRegnCd/lDongSignguCd)로 변환
/// - 용도: 새 필드가 없는 Mock JSON 보완, Realm 마이그레이션(v2 → v3)
/// - 데이터: Resources/legacy_region_map.json (scripts/build_legacy_region_map.py로 생성)
enum LegacyRegionMap {
    private struct Entry: Decodable {
        let regn: Int
        let sigungu: [String: Int]
    }

    private static let table: [String: Entry] = {
        guard let url = Bundle.main.url(forResource: "legacy_region_map", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let decoded = try? JSONDecoder().decode([String: Entry].self, from: data) else {
            return [:]
        }
        return decoded
    }()

    /// 옛 areaCode -> 새 시도 코드 (광주 5, 전남 38 -> 12)
    static func regionCode(fromLegacyArea area: Int) -> Int? {
        table["\(area)"]?.regn
    }

    /// 옛 (areaCode, sigunguCode) -> 새 시군구 코드. 폐지·분리된 시군구는 nil
    static func signguCode(fromLegacyArea area: Int, sigungu: Int) -> Int? {
        table["\(area)"]?.sigungu["\(sigungu)"]
    }
}
