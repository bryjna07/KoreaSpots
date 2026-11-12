//
//  TourRepositoryImpl.swift
//  KoreaSpots
//
//  Created by YoungJin on 9/26/25.
//

import Foundation
import RxSwift
import Moya

final class TourRepositoryImpl: TourRepository {

    let remoteDataSource: TourRemoteDataSource
    let mockDataSource: TourRemoteDataSource
    let localDataSource: TourLocalDataSource
    let networkMonitor: NetworkMonitor
    let disposeBag = DisposeBag()

    init(
        remoteDataSource: TourRemoteDataSource,
        mockDataSource: TourRemoteDataSource,
        localDataSource: TourLocalDataSource,
        networkMonitor: NetworkMonitor = NetworkMonitor.shared
    ) {
        self.remoteDataSource = remoteDataSource
        self.mockDataSource = mockDataSource
        self.localDataSource = localDataSource
        self.networkMonitor = networkMonitor
    }

    // MARK: - Festival Operations
    func getFestivals(
        eventStartDate: String,
        eventEndDate: String,
        areaCode: Int?,
        numOfRows: Int,
        pageNo: Int,
        arrange: String
    ) -> Single<[Place]> {
        // 축제는 contentTypeId=15
        // 캐시 우선 전략: 같은 지역 + 같은 날짜 범위의 축제 캐시 확인
        return localDataSource.getPlaces(areaCode: areaCode, sigunguCode: nil, contentTypeId: 15)
            .flatMap { [weak self] cachedPlaces -> Single<[Place]> in
                guard let self else { return .just([]) }

                // 캐시된 축제를 날짜로 필터링
                let filteredPlaces = cachedPlaces.filter { place in
                    guard let eventMeta = place.eventMeta else { return false }
                    // 이벤트 기간이 요청한 날짜 범위와 겹치는지 확인
                    return eventMeta.eventStartDate <= eventEndDate && eventMeta.eventEndDate >= eventStartDate
                }

                // 캐시가 충분한지 확인: 요청한 개수만큼 있어야 캐시 히트
                if filteredPlaces.count >= numOfRows {
                    print("✅ Festival Cache Hit: \(filteredPlaces.count) festivals (areaCode: \(areaCode?.description ?? "전국"))")
                    return .just(Array(filteredPlaces.prefix(numOfRows)))
                }

                // 캐시가 부족하면 API 호출
                return self.remoteDataSource
                    .fetchFestivalList(
                        eventStartDate: eventStartDate,
                        eventEndDate: eventEndDate,
                        areaCode: areaCode,
                        numOfRows: numOfRows,
                        pageNo: pageNo,
                        arrange: arrange
                    )
                    .do(onSuccess: { [weak self] places in
                        let areaInfo = areaCode != nil ? "지역코드 \(areaCode!)" : "전국"
                        print("✅ Festival API Success: \(places.count) festivals (\(areaInfo))")

                        // 백그라운드에서 캐시 저장 (contentTypeId=15 축제)
                        self?.localDataSource.savePlaces(places, areaCode: areaCode, sigunguCode: nil, contentTypeId: 15)
                            .subscribe()
                            .disposed(by: self?.disposeBag ?? DisposeBag())
                    }, onError: { error in
                        print("❌ Festival API Error: \(error)")
                    })
                    .catchError { [weak self] apiError in
                        guard let self else { return .just([]) }

                        return self.handleAPIError(
                            apiError,
                            mockFallback: {
                                self.mockDataSource.fetchFestivalList(
                                    eventStartDate: eventStartDate,
                                    eventEndDate: eventEndDate,
                                    areaCode: areaCode,
                                    numOfRows: numOfRows,
                                    pageNo: pageNo,
                                    arrange: arrange
                                )
                            },
                            emptyValue: []
                        )
                    }
            }
    }

    // MARK: - Cache Management
    func clearExpiredCache() -> Completable {
        return localDataSource.clearExpiredCache()
    }
}
