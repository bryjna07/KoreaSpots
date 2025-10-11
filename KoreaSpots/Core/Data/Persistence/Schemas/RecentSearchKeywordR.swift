//
//  RecentSearchKeywordR.swift
//  KoreaSpots
//
//  Created by YoungJin on 10/09/25.
//

import Foundation
import RealmSwift

/// 최근 검색어 Realm 스키마
final class RecentSearchKeywordR: Object {
    @Persisted(primaryKey: true) var keyword: String // 검색어 (Primary Key)
    @Persisted var searchedAt: Date // 검색 시간

    convenience init(keyword: String) {
        self.init()
        self.keyword = keyword
        self.searchedAt = Date()
    }
}
