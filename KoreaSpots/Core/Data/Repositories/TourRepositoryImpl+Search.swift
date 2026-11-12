//
//  TourRepositoryImpl+Search.swift
//  KoreaSpots
//
//  Created by YoungJin on 11/12/25.
//

// 역할: 키워드 검색
// 의존: TourRemoteDataSource, handleAPIError
// 사용처: AppContainer (TourRepository 프로토콜로 주입)

import Foundation
import RxSwift
import Moya

extension TourRepositoryImpl {

    // MARK: - Search Operations
    func searchPlacesByKeyword(
        keyword: String,
        areaCode: Int?,
        sigunguCode: Int?,
        contentTypeId: Int?,
        cat1: String?,
        cat2: String?,
        cat3: String?,
        numOfRows: Int,
        pageNo: Int,
        arrange: String
    ) -> Single<[Place]> {
        // 검색은 캐시하지 않고 항상 최신 데이터 반환
        return remoteDataSource.fetchSearchKeyword(
            keyword: keyword,
            areaCode: areaCode,
            sigunguCode: sigunguCode,
            contentTypeId: contentTypeId,
            cat1: cat1,
            cat2: cat2,
            cat3: cat3,
            numOfRows: numOfRows,
            pageNo: pageNo,
            arrange: arrange
        )
        .do(onSuccess: { places in
            print("✅ Search API Success: \(places.count) places for keyword '\(keyword)'")
        }, onError: { error in
            print("❌ Search API Error: \(error)")
        })
        .catchError { [weak self] apiError in
            guard let self else { return .just([]) }
            print("⚠️ Search API failed, using fallback Mock Data")

            return self.mockDataSource.fetchSearchKeyword(
                keyword: keyword,
                areaCode: areaCode,
                sigunguCode: sigunguCode,
                contentTypeId: contentTypeId,
                cat1: cat1,
                cat2: cat2,
                cat3: cat3,
                numOfRows: numOfRows,
                pageNo: pageNo,
                arrange: arrange
            )
            .do(onSuccess: { places in
                print("✅ Mock Fallback Success: \(places.count) places for keyword '\(keyword)'")
            })
        }
    }
}
