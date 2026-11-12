//
//  CodeBookStore.swift
//  KoreaSpots
//
//  Created by YoungJin on 10/16/25.
//

import Foundation

// MARK: - 공통 NameRecord
public struct CodeNameRecord: Codable {
    public let ko: String
    public let en: String?
}

public enum LanguageTag: String {
    case ko, en
}

// MARK: - 통합 CodeBookStore (Generic)
/// Cat3, Sigungu 등 계층 구조를 가진 코드북을 관리하는 통합 Store
/// - Key1: 상위 코드 (예: Cat2, AreaCode)
/// - Key2: 하위 코드 (예: Cat3, SigunguCode)
public enum CodeBookStore {
    // cache: category -> (parentCode -> (childCode -> record))
    private static var cache: [String: [String: [String: CodeNameRecord]]] = [:]
    private static let syncQueue = DispatchQueue(label: "kr.koreaspots.codebook.store", attributes: .concurrent)

    // MARK: - Load Methods

    /// 동기 로딩 (이미 data를 확보한 경우)
    public static func load(category: String, from data: Data) throws {
        let decoded = try JSONDecoder().decode([String: [String: CodeNameRecord]].self, from: data)
        syncQueue.async(flags: .barrier) {
            cache[category] = decoded
        }
    }

    /// 번들 JSON에서 비동기 로딩
    public static func loadFromBundleAsync(
        category: String,
        fileName: String,
        ext: String = "json",
        in bundle: Bundle = .main,
        completion: @escaping (Bool) -> Void
    ) {
        DispatchQueue.global(qos: .utility).async {
            guard let url = bundle.url(forResource: fileName, withExtension: ext),
                  let data = try? Data(contentsOf: url),
                  let decoded = try? JSONDecoder().decode([String: [String: CodeNameRecord]].self, from: data) else {
                DispatchQueue.main.async { completion(false) }
                return
            }
            syncQueue.async(flags: .barrier) { cache[category] = decoded }
            DispatchQueue.main.async { completion(true) }
        }
    }

    // MARK: - Query Methods

    /// 현재 메모리 캐시에 데이터가 있는지
    public static func isLoaded(category: String) -> Bool {
        var result = false
        syncQueue.sync { result = cache[category] != nil && !cache[category]!.isEmpty }
        return result
    }

    /// 조회: 언어 우선순위(ko → en)로 반환
    public static func name(
        category: String,
        parentCode: String,
        childCode: String,
        preferred: LanguageTag = .ko
    ) -> String? {
        var record: CodeNameRecord?
        syncQueue.sync {
            record = cache[category]?[parentCode]?[childCode]
        }
        guard let rec = record else { return nil }
        switch preferred {
        case .ko: return rec.ko
        case .en: return rec.en ?? rec.ko
        }
    }

    /// 상위 코드에 속한 모든 하위 코드 목록 반환
    public static func allChildCodes(category: String, parentCode: String) -> [String] {
        var codes: [String] = []
        syncQueue.sync {
            if let parentMap = cache[category]?[parentCode] {
                codes = Array(parentMap.keys)
            }
        }
        return codes.sorted()
    }

    /// 모든 상위 코드 목록 반환
    public static func allParentCodes(category: String) -> [String] {
        var codes: [String] = []
        syncQueue.sync {
            if let categoryCache = cache[category] {
                codes = Array(categoryCache.keys)
            }
        }
        return codes.sorted()
    }

    // MARK: - Merge Methods

    /// 외부에서 런타임 병합 (디버그 하이드레이션 등)
    public static func merge(category: String, parentCode: String, entries: [String: CodeNameRecord]) {
        syncQueue.async(flags: .barrier) {
            var categoryCache = cache[category] ?? [:]
            var parentMap = categoryCache[parentCode] ?? [:]
            for (code, rec) in entries {
                parentMap[code] = rec
            }
            categoryCache[parentCode] = parentMap
            cache[category] = categoryCache
        }
    }

    // MARK: - Clear Methods

    /// 특정 카테고리 캐시 초기화
    public static func clear(category: String) {
        syncQueue.async(flags: .barrier) {
            cache.removeValue(forKey: category)
        }
    }

    /// 모든 캐시 초기화
    public static func clearAll() {
        syncQueue.async(flags: .barrier) {
            cache.removeAll()
        }
    }
}

// MARK: - Convenience Extensions

extension CodeBookStore {
    // Cat3 관련 편의 메서드
    public enum Cat3 {
        private static let category = "cat3"

        public static func load(from data: Data) throws {
            try CodeBookStore.load(category: category, from: data)
        }

        public static func loadFromBundleAsync(
            fileName: String = "cat3_codes",
            completion: @escaping (Bool) -> Void
        ) {
            CodeBookStore.loadFromBundleAsync(
                category: category,
                fileName: fileName,
                completion: completion
            )
        }

        public static var isLoaded: Bool {
            CodeBookStore.isLoaded(category: category)
        }

        public static func name(cat2Code: String, cat3Code: String, preferred: LanguageTag = .ko) -> String? {
            CodeBookStore.name(category: category, parentCode: cat2Code, childCode: cat3Code, preferred: preferred)
        }

        public static func allCat3Codes(for cat2Code: String) -> [String] {
            CodeBookStore.allChildCodes(category: category, parentCode: cat2Code)
        }

        public static func merge(cat2Code: String, entries: [String: CodeNameRecord]) {
            CodeBookStore.merge(category: category, parentCode: cat2Code, entries: entries)
        }
    }

    // Sigungu 관련 편의 메서드
    public enum Sigungu {
        private static let category = "sigungu"

        public static func load(from data: Data) throws {
            try CodeBookStore.load(category: category, from: data)
        }

        public static func loadFromBundleAsync(
            fileName: String = "sigungu_codes",
            completion: @escaping (Bool) -> Void
        ) {
            CodeBookStore.loadFromBundleAsync(
                category: category,
                fileName: fileName,
                completion: completion
            )
        }

        public static var isLoaded: Bool {
            CodeBookStore.isLoaded(category: category)
        }

        public static func name(areaCode: Int, sigunguCode: Int, preferred: LanguageTag = .ko) -> String? {
            CodeBookStore.name(
                category: category,
                parentCode: "\(areaCode)",
                childCode: "\(sigunguCode)",
                preferred: preferred
            )
        }

        public static func allSigunguCodes(for areaCode: Int) -> [String] {
            CodeBookStore.allChildCodes(category: category, parentCode: "\(areaCode)")
        }

        public static func merge(areaCode: Int, entries: [String: CodeNameRecord]) {
            CodeBookStore.merge(category: category, parentCode: "\(areaCode)", entries: entries)
        }
    }
}
