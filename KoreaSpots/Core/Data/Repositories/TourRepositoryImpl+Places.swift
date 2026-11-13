//
//  TourRepositoryImpl+Places.swift
//  KoreaSpots
//
//  Created by YoungJin on 11/12/25.
//

// 역할: 위치/지역 기반 장소 조회 (캐시 우선, API 실패 시 mock 폴백) 및 cat3 클라이언트 필터
// 의존: TourRemoteDataSource, TourLocalDataSource, handleAPIError
// 사용처: AppContainer (TourRepository 프로토콜로 주입)

import Foundation
import RxSwift
import Moya

extension TourRepositoryImpl {

    // MARK: - Place Operations
    func getLocationBasedPlaces(
        mapX: Double,
        mapY: Double,
        radius: Int,
        contentTypeId: Int?,
        numOfRows: Int,
        pageNo: Int,
        arrange: String
    ) -> Single<[Place]> {
        print("🔍 getLocationBasedPlaces called")
        print("🔍 Current AppStateManager mode: \(AppStateManager.shared.currentMode)")

        // Mock 모드에서는 캐시 무시하고 Mock 데이터 반환
        if AppStateManager.shared.shouldUseMockData() {
            print("🔄 Mock mode active - skipping cache, using mock data for location-based")
            return mockDataSource.fetchLocationBasedList(
                mapX: mapX,
                mapY: mapY,
                radius: radius,
                contentTypeId: contentTypeId,
                numOfRows: numOfRows,
                pageNo: pageNo,
                arrange: arrange
            )
            .do(onSuccess: { places in
                print("✅ Mock data returned with \(places.count) places")
                if let first = places.first {
                    print("✅ First place title: \(first.title)")
                }
            })
        }

        print("📦 Normal mode - checking cache first")

        // 위치 기반은 짧은 TTL로 캐시 우선 확인
        return localDataSource.getLocationBasedPlaces(mapX: mapX, mapY: mapY, radius: radius)
            .flatMap { [weak self] cachedPlaces -> Single<[Place]> in
                guard let self = self else { return .just([]) }

                if !cachedPlaces.isEmpty {
                    print("✅ Location Cache Hit: \(cachedPlaces.count) places")
                    return .just(cachedPlaces)
                }

                // 캐시가 없으면 API 호출
                return self.remoteDataSource
                    .fetchLocationBasedList(
                        mapX: mapX,
                        mapY: mapY,
                        radius: radius,
                        contentTypeId: contentTypeId,
                        numOfRows: numOfRows,
                        pageNo: pageNo,
                        arrange: arrange
                    )
                    .do(onSuccess: { [weak self] places in
                        let typeInfo = contentTypeId != nil ? "타입 \(contentTypeId!)" : "전체 타입"
                        print("✅ Location API Success: \(places.count) places (\(typeInfo))")
                        // 백그라운드에서 캐시 저장
                        self?.localDataSource.saveLocationBasedPlaces(places, mapX: mapX, mapY: mapY, radius: radius)
                            .subscribe()
                            .disposed(by: self?.disposeBag ?? DisposeBag())
                    }, onError: { error in
                        print("❌ Location API Error: \(error)")
                    })
                    .catch { [weak self] apiError in
                        guard let self else { return .just([]) }

                        return self.handleAPIError(
                            apiError,
                            mockFallback: {
                                self.mockDataSource.fetchLocationBasedList(
                                    mapX: mapX,
                                    mapY: mapY,
                                    radius: radius,
                                    contentTypeId: contentTypeId,
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

    func getAreaBasedPlaces(
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
        // 중분류가 여러 개(쉼표 구분)면 각각 조회 후 병합 (예: 공연·전시 = EV02 + VE07)
        let cat2List = (cat2 ?? "").split(separator: ",").map { String($0.trimmingCharacters(in: .whitespaces)) }
        if cat2List.count > 1 {
            let requests = cat2List.map { code in
                getAreaBasedPlaces(
                    areaCode: areaCode,
                    sigunguCode: sigunguCode,
                    contentTypeId: contentTypeId,
                    cat1: String(code.prefix(2)),
                    cat2: code,
                    cat3: cat3,
                    numOfRows: numOfRows,
                    pageNo: pageNo,
                    arrange: arrange
                )
            }
            return Single.zip(requests).map { results in
                var seen = Set<String>()
                return results.flatMap { $0 }.filter { seen.insert($0.contentId).inserted }
            }
        }

        // Mock 모드에서는 Mock 데이터 반환
        if AppStateManager.shared.shouldUseMockData() {
            print("🔄 Mock mode active - using mock data")
            let cat3Filters = parseCat3Filters(cat3)

            // 소분류(8자리) 1개면 API에 직접 전달, 2개 이상이면 nil로 전달 후 클라이언트 접두사 필터링
            let apiCat3: String?
            let needsClientFiltering: Bool
            if cat3Filters.count == 1 {
                apiCat3 = cat3Filters.first.flatMap { $0.count == 8 ? $0 : nil }
                needsClientFiltering = false
            } else {
                apiCat3 = nil
                needsClientFiltering = !cat3Filters.isEmpty
            }

            return mockDataSource.fetchAreaBasedList(
                areaCode: areaCode,
                sigunguCode: sigunguCode,
                contentTypeId: contentTypeId,
                cat1: cat1,
                cat2: cat2,
                cat3: apiCat3,
                numOfRows: numOfRows,
                pageNo: pageNo,
                arrange: arrange
            )
            .map { places in
                return needsClientFiltering ? self.filterPlacesByCat3(places, cat3Filters: cat3Filters) : places
            }
        }

        // Cat3 필터 목록 파싱 (쉼표로 구분된 문자열)
        let cat3Filters = parseCat3Filters(cat3)

        // 소분류(8자리) 1개면 API에 직접 전달, 2개 이상이면 nil로 전달 후 클라이언트 접두사 필터링
        // (대/중분류 단일 코드는 cat1/cat2 파라미터로 이미 서버에서 좁혀짐)
        let apiCat3: String?
        let needsClientFiltering: Bool
        if cat3Filters.count == 1 {
            apiCat3 = cat3Filters.first.flatMap { $0.count == 8 ? $0 : nil }
            needsClientFiltering = false
        } else {
            apiCat3 = nil
            needsClientFiltering = !cat3Filters.isEmpty
        }

        // PlaceList는 페이징이 있으므로 캐시 없이 항상 API 호출
        print("🔄 Fetching area-based places (no cache, paging active)")
        return remoteDataSource
            .fetchAreaBasedList(
                areaCode: areaCode,
                sigunguCode: sigunguCode,
                contentTypeId: contentTypeId,
                cat1: cat1,
                cat2: cat2,
                cat3: apiCat3,  // cat3가 1개면 API에 전달, 아니면 nil
                numOfRows: needsClientFiltering ? numOfRows * 3 : numOfRows,  // 클라이언트 필터링 시 손실 보완
                pageNo: pageNo,
                arrange: arrange
            )
            .map { places in
                // cat3가 2개 이상인 경우만 클라이언트에서 필터링
                return needsClientFiltering ? self.filterPlacesByCat3(places, cat3Filters: cat3Filters) : places
            }
            .do(onSuccess: { places in
                let areaInfo = areaCode != nil ? "지역코드 \(areaCode!)" : "전국"
                print("✅ Area API Success: \(places.count) places (\(areaInfo), page: \(pageNo))")
            }, onError: { error in
                print("❌ Area API Error: \(error)")
            })
            .catch { [weak self] apiError in
                guard let self else { return .just([]) }

                return self.handleAPIError(
                    apiError,
                    mockFallback: {
                        self.mockDataSource.fetchAreaBasedList(
                            areaCode: areaCode,
                            sigunguCode: sigunguCode,
                            contentTypeId: contentTypeId,
                            cat1: cat1,
                            cat2: cat2,
                            cat3: apiCat3,  // cat3가 1개면 API에 전달, 아니면 nil
                            numOfRows: needsClientFiltering ? numOfRows * 3 : numOfRows,
                            pageNo: pageNo,
                            arrange: arrange
                        )
                        .map { places in
                            return needsClientFiltering ? self.filterPlacesByCat3(places, cat3Filters: cat3Filters) : places
                        }
                    },
                    emptyValue: []
                )
            }
    }

    // MARK: - Helper Methods

    /// Cat3 필터 문자열을 Set으로 파싱
    /// - Parameter cat3: 쉼표로 구분된 cat3 문자열 (예: "A01010100,A01010200,A01010300")
    /// - Returns: cat3 코드 Set (예: ["A01010100", "A01010200", "A01010300"])
    private func parseCat3Filters(_ cat3: String?) -> Set<String> {
        guard let cat3 = cat3, !cat3.isEmpty else { return [] }
        return Set(cat3.split(separator: ",").map { String($0.trimmingCharacters(in: .whitespaces)) })
    }

    /// Places를 cat3 필터로 필터링
    /// - Parameters:
    ///   - places: 필터링할 Place 배열
    ///   - cat3Filters: cat3 필터 Set (비어있으면 필터링 안 함)
    /// - Returns: 필터링된 Place 배열
    private func filterPlacesByCat3(_ places: [Place], cat3Filters: Set<String>) -> [Place] {
        guard !cat3Filters.isEmpty else { return places }

        return places.filter { place in
            guard let code = place.lclsSystm3, !code.isEmpty else { return false }
            return cat3Filters.contains { code.hasPrefix($0) }
        }
    }
}
