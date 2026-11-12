//
//  RecentKeywordRepositoryImpl.swift
//  KoreaSpots
//
//  Created by YoungJin on 11/12/25.
//

import Foundation
import RxSwift

final class RecentKeywordRepositoryImpl: RecentKeywordRepository {
    private let localDataSource: TourLocalDataSource

    init(localDataSource: TourLocalDataSource) {
        self.localDataSource = localDataSource
    }

    func saveRecentKeyword(_ keyword: String) -> Completable {
        return localDataSource.saveRecentKeyword(keyword)
    }

    func getRecentKeywords(limit: Int) -> Single<[String]> {
        return localDataSource.getRecentKeywords(limit: limit)
    }

    func deleteRecentKeyword(_ keyword: String) -> Completable {
        return localDataSource.deleteRecentKeyword(keyword)
    }

    func clearAllRecentKeywords() -> Completable {
        return localDataSource.clearAllRecentKeywords()
    }
}
