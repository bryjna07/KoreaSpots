//
//  ThemeCatalog.swift
//  KoreaSpots
//
//  Created by YoungJin on 11/12/25.
//

import Foundation

// MARK: - 앱 자체 테마 정의 (themes.json)
/// API 소분류(lclsSystm)를 사용자가 보기 편하게 묶은 앱 소유 테마 목록.
/// API 분류가 바뀌어도 themes.json만 수정하면 되도록 코드는 JSON에 두고 Swift는 해석만 한다.
enum ThemeCatalog {
    struct Entry: Decodable {
        let id: String
        let contentTypeId: Int
        /// 접두사 매칭 코드: 2자리(대분류) / 4자리(중분류) / 8자리(소분류)
        let lcls: [String]

        /// 소분류 코드가 이 테마에 속하는지 (접두사 일치)
        func matches(lclsSystm3: String?) -> Bool {
            guard let code = lclsSystm3, !code.isEmpty else { return false }
            return lcls.contains { code.hasPrefix($0) }
        }

        /// 서버 요청용 대분류: 모든 코드가 같은 대분류일 때만 값이 있다
        var requestLcls1: String? {
            let prefixes = Set(lcls.map { String($0.prefix(2)) })
            return prefixes.count == 1 ? prefixes.first : nil
        }

        /// 서버 요청용 중분류: 모든 코드가 같은 중분류(4자리 이상)일 때만 값이 있다
        var requestLcls2: String? {
            guard lcls.allSatisfy({ $0.count >= 4 }) else { return nil }
            let prefixes = Set(lcls.map { String($0.prefix(4)) })
            return prefixes.count == 1 ? prefixes.first : nil
        }
    }

    /// themes.json 로드 결과 (실패 시 빈 배열)
    static let entries: [Entry] = {
        guard let url = Bundle.main.url(forResource: "themes", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let decoded = try? JSONDecoder().decode([Entry].self, from: data) else {
            return []
        }
        return decoded
    }()

    static func entry(id: String) -> Entry? {
        entries.first { $0.id == id }
    }

    /// 소분류 코드가 속한 첫 번째 테마 (JSON 순서 우선)
    static func entry(matching lclsSystm3: String?) -> Entry? {
        entries.first { $0.matches(lclsSystm3: lclsSystm3) }
    }
}
