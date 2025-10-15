//
//  TourRepositoryImpl.swift
//  KoreaSpots
//
//  Created by YoungJin on 9/26/25.
//

import Foundation
import RxSwift

final class TourRepositoryImpl: TourRepository {

    private let remoteDataSource: TourRemoteDataSource
    private let localDataSource: TourLocalDataSource
    private let disposeBag = DisposeBag()

    init(remoteDataSource: TourRemoteDataSource, localDataSource: TourLocalDataSource) {
        self.remoteDataSource = remoteDataSource
        self.localDataSource = localDataSource
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
        // 축제는 contentTypeId=15, 캐시 없이 항상 API 호출
        return remoteDataSource
            .fetchFestivalList(
                eventStartDate: eventStartDate,
                eventEndDate: eventEndDate,
                areaCode: areaCode,
                numOfRows: numOfRows,
                pageNo: pageNo,
                arrange: arrange
            )
            .do(onSuccess: { places in
                let areaInfo = areaCode != nil ? "지역코드 \(areaCode!)" : "전국"
                print("✅ Festival API Success: \(places.count) festivals (\(areaInfo))")
            }, onError: { error in
                print("❌ Festival API Error: \(error)")
            })
    }

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
        // 카테고리/테마 필터가 있으면 캐시 스킵
        let skipCache = cat1 != nil || cat2 != nil || cat3 != nil

        if skipCache {
            print("🔄 Skipping cache for category/theme filtering")
            return remoteDataSource
                .fetchAreaBasedList(
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
                    print("✅ Area API Success (no cache): \(places.count) places")
                }, onError: { error in
                    print("❌ Area API Error: \(error)")
                })
        }

        // Cache-first 전략 (Real API + 단순 쿼리일 때만)
        // areaCode가 nil이면 캐시 조회 스킵 (전국 데이터)
        if areaCode == nil {
            print("🔄 Fetching nationwide data (no cache)")
            return remoteDataSource
                .fetchAreaBasedList(
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
                    print("✅ Nationwide Area API Success: \(places.count) places")
                }, onError: { error in
                    print("❌ Area API Error: \(error)")
                })
        }

        return localDataSource.getPlaces(areaCode: areaCode, sigunguCode: sigunguCode, contentTypeId: contentTypeId)
            .flatMap { [weak self] cachedPlaces -> Single<[Place]> in
                guard let self = self else { return .just([]) }

                if !cachedPlaces.isEmpty {
                    print("✅ Area Cache Hit: \(cachedPlaces.count) places")
                    return .just(cachedPlaces)
                }

                // 캐시가 없으면 API 호출
                return self.remoteDataSource
                    .fetchAreaBasedList(
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
                    .do(onSuccess: { [weak self] places in
                        print("✅ Area API Success: \(places.count) places")
                        // 백그라운드에서 캐시 저장
                        self?.localDataSource.savePlaces(places, areaCode: areaCode, sigunguCode: sigunguCode, contentTypeId: contentTypeId)
                            .subscribe()
                            .disposed(by: self?.disposeBag ?? DisposeBag())
                    }, onError: { error in
                        print("❌ Area API Error: \(error)")
                    })
            }
    }

    // MARK: - Detail Operations
    func getPlaceDetail(contentId: String, contentTypeId: Int?) -> Single<Place> {
        // Detail은 긴 TTL로 캐시 우선 확인
        return localDataSource.getPlaceDetail(contentId: contentId)
            .flatMap { [weak self] cachedPlace -> Single<Place> in
                guard let self = self else { return Single.error(TourRepositoryError.unknown) }

                if let place = cachedPlace {
                    print("✅ Detail Cache Hit for contentId: \(contentId)")
                    return .just(place)
                }

                // 캐시가 없으면 API 호출
                return self.remoteDataSource
                    .fetchDetailCommon(contentId: contentId, contentTypeId: contentTypeId)
                    .do(onSuccess: { [weak self] place in
                        print("✅ Detail API Success for contentId: \(contentId)")
                        // 백그라운드에서 캐시 저장
                        self?.localDataSource.savePlaceDetail(place)
                            .subscribe()
                            .disposed(by: self?.disposeBag ?? DisposeBag())
                    }, onError: { error in
                        print("❌ Detail API Error for contentId \(contentId): \(error)")
                    })
            }
    }

    func getPlaceOperatingInfo(contentId: String, contentTypeId: Int) -> Single<OperatingInfo> {
        // detailIntro2 API에서 운영정보를 가져옴
        return remoteDataSource
            .fetchDetailIntro(contentId: contentId, contentTypeId: contentTypeId)
            .flatMap { place -> Single<OperatingInfo> in
                // TODO: TourAPI detailIntro2 응답을 OperatingInfo로 제대로 파싱 필요
                // 현재는 임시로 고정 값 반환 (실제 API 응답 필드 매핑 필요)
                let operatingInfo = OperatingInfo(
                    useTime: "09:00~18:00 (하절기 09:00~18:30)",
                    restDate: "화요일",
                    useFee: "성인 3,000원, 청소년 1,500원, 어린이 1,500원",
                    homepage: place.tel
                )
                return Single.just(operatingInfo)
            }
            .do(onSuccess: { operatingInfo in
                print("✅ OperatingInfo API Success for contentId: \(contentId)")
                print("📋 UseTime: \(operatingInfo.useTime ?? "nil")")
                print("📋 RestDate: \(operatingInfo.restDate ?? "nil")")
                print("📋 UseFee: \(operatingInfo.useFee ?? "nil")")
            }, onError: { error in
                print("❌ OperatingInfo API Error for contentId \(contentId): \(error)")
            })
    }

    func getPlaceImages(contentId: String, numOfRows: Int, pageNo: Int) -> Single<[PlaceImage]> {
        return remoteDataSource
            .fetchDetailImages(
                contentId: contentId,
                numOfRows: numOfRows,
                pageNo: pageNo
            )
            .do(onSuccess: { images in
                print("✅ Images API Success: \(images.count) images")
            }, onError: { error in
                print("❌ Images API Error: \(error)")
            })
    }

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
    }

    // MARK: - Recent Search Keywords
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

    // MARK: - Favorites
    func getFavoritePlaces() -> Single<[Place]> {
        return localDataSource.getFavoritePlaces()
    }

    func toggleFavorite(contentId: String) -> Completable {
        return localDataSource.toggleFavorite(contentId: contentId)
    }

    // MARK: - Cache Management
    func clearExpiredCache() -> Completable {
        return localDataSource.clearExpiredCache()
    }
}

// MARK: - Repository Errors
enum TourRepositoryError: Error, LocalizedError {
    case dataSourceError(Error)
    case mappingError
    case unknown

    var errorDescription: String? {
        switch self {
        case .dataSourceError(let error):
            return "Data source error: \(error.localizedDescription)"
        case .mappingError:
            return "Failed to map data"
        case .unknown:
            return "Unknown repository error"
        }
    }
}
