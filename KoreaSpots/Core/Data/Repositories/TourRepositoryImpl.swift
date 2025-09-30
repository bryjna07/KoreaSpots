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
        numOfRows: Int,
        pageNo: Int,
        arrange: String
    ) -> Single<[Festival]> {
        // Cache-first 전략
        return localDataSource.getFestivals(startDate: eventStartDate, endDate: eventEndDate)
            .flatMap { [weak self] cachedFestivals -> Single<[Festival]> in
                guard let self = self else { return .just([]) }

                if !cachedFestivals.isEmpty {
                    print("✅ Festival Cache Hit: \(cachedFestivals.count) festivals")
                    return .just(cachedFestivals)
                }

                // 캐시가 없으면 API 호출 후 캐시 저장
                return self.remoteDataSource
                    .fetchFestivalList(
                        eventStartDate: eventStartDate,
                        eventEndDate: eventEndDate,
                        numOfRows: numOfRows,
                        pageNo: pageNo,
                        arrange: arrange
                    )
                    .do(onSuccess: { [weak self] festivals in
                        print("✅ Festival API Success: \(festivals.count) festivals")
                        // 백그라운드에서 캐시 저장
                        self?.localDataSource.saveFestivals(festivals, startDate: eventStartDate, endDate: eventEndDate)
                            .subscribe()
                            .disposed(by: self?.disposeBag ?? DisposeBag())
                    }, onError: { error in
                        print("❌ Festival API Error: \(error)")
                    })
            }
    }

    // MARK: - Place Operations
    func getLocationBasedPlaces(
        mapX: Double,
        mapY: Double,
        radius: Int,
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
                        numOfRows: numOfRows,
                        pageNo: pageNo,
                        arrange: arrange
                    )
                    .do(onSuccess: { [weak self] places in
                        print("✅ Location API Success: \(places.count) places")
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
        areaCode: Int,
        sigunguCode: Int?,
        contentTypeId: Int?,
        numOfRows: Int,
        pageNo: Int,
        arrange: String
    ) -> Single<[Place]> {
        // Cache-first 전략
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
        // detailIntro2에서 운영정보를 가져오고 TourAPIItem에서 직접 OperatingInfo로 변환
        return remoteDataSource
            .fetchDetailIntro(contentId: contentId, contentTypeId: contentTypeId)
            .flatMap { place -> Single<OperatingInfo> in
                // Mock에서는 detailIntro2_sample.json의 데이터를 사용
                // 실제로는 API 응답의 TourAPIItem을 OperatingInfo로 변환
                // 임시로 Mock 데이터 기반으로 고정 값 사용
                let operatingInfo = OperatingInfo(
                    useTime: "09:00~18:00 (하절기 09:00~18:30)", // detailIntro2 데이터 기반
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
