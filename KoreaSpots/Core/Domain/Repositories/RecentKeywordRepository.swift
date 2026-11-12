//
//  RecentKeywordRepository.swift
//  KoreaSpots
//
//  Created by YoungJin on 11/12/25.
//

import Foundation
import RxSwift

protocol RecentKeywordRepository {
    func saveRecentKeyword(_ keyword: String) -> Completable
    func getRecentKeywords(limit: Int) -> Single<[String]>
    func deleteRecentKeyword(_ keyword: String) -> Completable
    func clearAllRecentKeywords() -> Completable
}
