//
//  TourRepositoryImpl+Detail.swift
//  KoreaSpots
//
//  Created by YoungJin on 11/12/25.
//

// 역할: 장소 상세/운영정보/이미지/코스 상세 조회 (캐시 우선)
// 의존: TourRemoteDataSource, TourLocalDataSource, handleAPIError
// 사용처: AppContainer (TourRepository 프로토콜로 주입)

import Foundation
import RxSwift
import Moya

extension TourRepositoryImpl {

    // MARK: - Detail Operations
    func getPlaceDetail(contentId: String) -> Single<Place> {
        // Mock 모드에서는 캐시 무시하고 Mock 데이터 반환
        if AppStateManager.shared.shouldUseMockData() {
            print("🔄 Mock mode active - skipping cache, using mock data")
            return mockDataSource.fetchDetailCommon(contentId: contentId)
        }

        // Detail은 긴 TTL로 캐시 우선 확인
        return localDataSource.getPlaceDetail(contentId: contentId)
            .flatMap { [weak self] cachedPlace -> Single<Place> in
                guard let self else { return Single.error(TourRepositoryError.unknown) }

                if let place = cachedPlace {
                    print("✅ Detail Cache Hit for contentId: \(contentId)")
                    return .just(place)
                }

                // 캐시가 없으면 API 호출
                return self.remoteDataSource
                    .fetchDetailCommon(contentId: contentId)
                    .do(onSuccess: { [weak self] place in
                        print("✅ Detail API Success for contentId: \(contentId)")
                        // 백그라운드에서 캐시 저장
                        // Completable은 완료 시 구독이 해제되므로 DisposeBag에 보관하지 않음 (bag 무한 증가 방지)
                        _ = self?.localDataSource.savePlaceDetail(place)
                            .subscribe(onError: { error in
                                print("❌ Cache save failed: \(error)")
                            })
                    }, onError: { error in
                        print("❌ Detail API Error for contentId \(contentId): \(error)")
                    })
                    .catch { [weak self] apiError in
                        guard let self else { return .error(apiError) }
                        print("⚠️ Detail API failed, using fallback Mock Data")

                        return self.mockDataSource
                            .fetchDetailCommon(contentId: contentId)
                            .do(onSuccess: { _ in
                                // Mock 데이터는 캐싱하지 않음 (서버 복구 후에도 예시 데이터가 남는 문제 방지)
                                print("✅ Mock Fallback Success for contentId: \(contentId)")
                            })
                    }
            }
    }

    func getPlaceOperatingInfo(contentId: String, contentTypeId: Int) -> Single<OperatingInfo> {
        // Mock 모드에서는 빈 OperatingInfo 반환 (운영정보 선택사항)
        if AppStateManager.shared.shouldUseMockData() {
            print("🔄 Mock mode active - returning empty OperatingInfo")
            return .just(OperatingInfo.empty)
        }

        // 캐시 확인
        return localDataSource.getOperatingInfo(contentId: contentId)
            .flatMap { [weak self] cachedOperatingInfo -> Single<OperatingInfo> in
                guard let self else { return .error(TourRepositoryError.unknown) }

                if let operatingInfo = cachedOperatingInfo {
                    print("✅ OperatingInfo Cache Hit for contentId: \(contentId)")
                    return .just(operatingInfo)
                }

                // 캐시가 없으면 API 호출
                return self.remoteDataSource
                    .fetchDetailIntro(contentId: contentId, contentTypeId: contentTypeId)
                    .do(onSuccess: { [weak self] operatingInfo in
                        print("✅ OperatingInfo API Success for contentId: \(contentId)")
                        print("📋 UseTime: \(operatingInfo.useTime ?? "nil")")
                        print("📋 RestDate: \(operatingInfo.restDate ?? "nil")")
                        print("📋 UseFee: \(operatingInfo.useFee ?? "nil")")

                        // 백그라운드에서 캐시 저장
                        // Completable은 완료 시 구독이 해제되므로 DisposeBag에 보관하지 않음 (bag 무한 증가 방지)
                        _ = self?.localDataSource.saveOperatingInfo(operatingInfo, contentId: contentId, contentTypeId: contentTypeId)
                            .subscribe(onError: { error in
                                print("❌ Cache save failed: \(error)")
                            })
                    }, onError: { error in
                        print("❌ OperatingInfo API Error for contentId \(contentId): \(error)")
                    })
                    .catch { apiError in
                        print("⚠️ OperatingInfo API failed, returning empty info")
                        // 운영정보는 선택사항이므로 빈 값 반환
                        return .just(OperatingInfo.empty)
                    }
            }
    }

    func getPlaceImages(contentId: String) -> Single<[PlaceImage]> {
        return remoteDataSource
            .fetchDetailImages(contentId: contentId)
            .do(onSuccess: { images in
                print("✅ Images API Success: \(images.count) images")
            }, onError: { error in
                print("❌ Images API Error: \(error)")
            })
            .catch { [weak self] apiError in
                guard let self else { return .just([]) }
                print("⚠️ Images API failed, using fallback Mock Data")

                return self.mockDataSource
                    .fetchDetailImages(contentId: contentId)
                    .do(onSuccess: { images in
                        print("✅ Mock Fallback Success: \(images.count) images")
                    })
            }
    }

    func getTravelCourseDetails(contentId: String, contentTypeId: Int) -> Single<[CourseDetail]> {
        return remoteDataSource
            .fetchDetailInfo(contentId: contentId, contentTypeId: contentTypeId)
            .map { items in
                items.map { item in
                    CourseDetail(
                        subNum: item.subNum,
                        subContentId: item.subContentId,
                        subName: item.subName,
                        subDetailOverview: item.subDetailOverview,
                        subDetailImg: item.subDetailImg,
                        subDetailAlt: item.subDetailAlt
                    )
                }
            }
            .do(onSuccess: { details in
                print("✅ Travel Course Details API Success: \(details.count) course items")
            }, onError: { error in
                print("❌ Travel Course Details API Error: \(error)")
            })
            .catch { [weak self] apiError in
                guard let self else { return .just([]) }
                print("⚠️ Travel Course Details API failed, using fallback Mock Data")

                return self.mockDataSource
                    .fetchDetailInfo(contentId: contentId, contentTypeId: contentTypeId)
                    .map { items in
                        items.map { item in
                            CourseDetail(
                                subNum: item.subNum,
                                subContentId: item.subContentId,
                                subName: item.subName,
                                subDetailOverview: item.subDetailOverview,
                                subDetailImg: item.subDetailImg,
                                subDetailAlt: item.subDetailAlt
                            )
                        }
                    }
                    .do(onSuccess: { details in
                        print("✅ Mock Fallback Success: \(details.count) course items")
                    })
            }
    }
}
