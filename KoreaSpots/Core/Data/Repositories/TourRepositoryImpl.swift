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

    private let remoteDataSource: TourRemoteDataSource
    private let mockDataSource: TourRemoteDataSource
    private let localDataSource: TourLocalDataSource
    private let networkMonitor: NetworkMonitor
    private let disposeBag = DisposeBag()

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
        if AppStateManager.shared.currentMode == .mockFallback {
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
                    .catchError { [weak self] apiError in
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
        if AppStateManager.shared.currentMode == .mockFallback {
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
            .catchError { [weak self] apiError in
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

    // MARK: - Detail Operations
    func getPlaceDetail(contentId: String) -> Single<Place> {
        // Mock 모드에서는 캐시 무시하고 Mock 데이터 반환
        if AppStateManager.shared.currentMode == .mockFallback {
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
                        self?.localDataSource.savePlaceDetail(place)
                            .subscribe()
                            .disposed(by: self?.disposeBag ?? DisposeBag())
                    }, onError: { error in
                        print("❌ Detail API Error for contentId \(contentId): \(error)")
                    })
                    .catchError { [weak self] apiError in
                        guard let self else { return .error(apiError) }
                        print("⚠️ Detail API failed, using fallback Mock Data")

                        return self.mockDataSource
                            .fetchDetailCommon(contentId: contentId)
                            .do(onSuccess: { [weak self] place in
                                print("✅ Mock Fallback Success for contentId: \(contentId)")
                                // Mock 데이터도 캐싱
                                self?.localDataSource.savePlaceDetail(place)
                                    .subscribe()
                                    .disposed(by: self?.disposeBag ?? DisposeBag())
                            })
                    }
            }
    }

    func getPlaceOperatingInfo(contentId: String, contentTypeId: Int) -> Single<OperatingInfo> {
        // Mock 모드에서는 빈 OperatingInfo 반환 (운영정보 선택사항)
        if AppStateManager.shared.currentMode == .mockFallback {
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
                        self?.localDataSource.saveOperatingInfo(operatingInfo, contentId: contentId, contentTypeId: contentTypeId)
                            .subscribe()
                            .disposed(by: self?.disposeBag ?? DisposeBag())
                    }, onError: { error in
                        print("❌ OperatingInfo API Error for contentId \(contentId): \(error)")
                    })
                    .catchError { apiError in
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
            .catchError { [weak self] apiError in
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
            .catchError { [weak self] apiError in
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
        // 읽기 작업은 항상 허용
        return localDataSource.getFavoritePlaces()
    }

    func toggleFavorite(contentId: String) -> Completable {
        // Mock 모드에서는 쓰기 작업 차단
        print("🔍 toggleFavorite called - Current mode: \(AppStateManager.shared.currentMode)")
        print("🔍 canPerformWriteOperation: \(AppStateManager.shared.canPerformWriteOperation())")

        guard AppStateManager.shared.canPerformWriteOperation() else {
            print("❌ Write operation blocked - returning error")
            return .error(TourRepositoryError.writeOperationBlocked)
        }

        print("✅ Write operation allowed - proceeding")
        return localDataSource.toggleFavorite(contentId: contentId)
    }

    // MARK: - Cache Management
    func clearExpiredCache() -> Completable {
        return localDataSource.clearExpiredCache()
    }

    // MARK: - Helper: Fallback Handler
    private func handleAPIError<T>(
        _ error: Error,
        mockFallback: @escaping () -> Single<T>,
        emptyValue: T
    ) -> Single<T> {
        print("🚨 handleAPIError called with error: \(error)")
        print("🚨 Error type: \(type(of: error))")

        let errorType = APIErrorType(from: error)
        print("⚠️ API ErrorType classified as: \(errorType)")
        print("⚠️ shouldUseMockData: \(errorType.shouldUseMockData)")

        // 네트워크 연결 상태 확인 (NWPathMonitor)
        if !networkMonitor.isConnectedValue {
            print("❌ Network offline detected")
            AppStateManager.shared.enterOfflineMode()
            return .error(TourRepositoryError.networkUnavailable)
        }

        // API 키 문제/한도 초과/서버 오류 → Mock 데이터로 폴백
        if errorType.shouldUseMockData {
            print("🔄 Using Mock fallback for: \(errorType)")
            print("🔄 Current AppState mode BEFORE: \(AppStateManager.shared.currentMode)")

            // Mock 모드 진입 (쓰기 작업 시도 시 Alert 표시됨)
            AppStateManager.shared.enterMockMode(reason: errorType.userMessage ?? "API Error")

            print("🔄 Current AppState mode AFTER: \(AppStateManager.shared.currentMode)")

            return mockFallback()
                .do(onSuccess: { _ in
                    print("✅ Mock Fallback Success")
                })
        }

        // 기타 에러 → 빈 값 반환
        print("⚠️ Returning empty value for errorType: \(errorType)")
        return .just(emptyValue)
    }

    // MARK: - Helper: modifiedTime 기반 스마트 갱신
    /// API에서 받은 Place들의 modifiedTime을 확인하여 변경된 경우에만 캐시 업데이트
    /// - Parameters:
    ///   - apiPlaces: API 응답으로 받은 Place 배열
    ///   - cachedPlaces: 기존 캐시된 Place 배열
    /// - Returns: 실제로 변경이 필요한 Place 배열
    private func filterChangedPlaces(_ apiPlaces: [Place], cachedPlaces: [Place]) -> [Place] {
        let cachedDict = Dictionary(uniqueKeysWithValues: cachedPlaces.map { ($0.contentId, $0) })

        return apiPlaces.filter { apiPlace in
            guard let cached = cachedDict[apiPlace.contentId] else {
                // 캐시에 없는 새로운 데이터
                return true
            }

            // modifiedTime 비교
            if let apiModifiedTime = apiPlace.modifiedTime,
               let cachedModifiedTime = cached.modifiedTime {
                return apiModifiedTime != cachedModifiedTime
            }

            // modifiedTime이 없는 경우 (detailIntro2, detailImage2 등) 무조건 갱신
            return true
        }
    }
}

// MARK: - Repository Errors
enum TourRepositoryError: Error, LocalizedError {
    case dataSourceError(Error)
    case mappingError
    case networkUnavailable  // 네트워크 끊김 (신규 유저는 차단)
    case writeOperationBlocked  // Mock 모드에서 쓰기 작업 차단
    case unknown

    var errorDescription: String? {
        switch self {
        case .dataSourceError(let error):
            return "Data source error: \(error.localizedDescription)"
        case .mappingError:
            return "Failed to map data"
        case .networkUnavailable:
            return "네트워크 연결이 필요합니다"
        case .writeOperationBlocked:
            return "현재 서버 오류로 인해\n예시 데이터를 표시 중입니다.\n\n예시 데이터 사용 중에는\n이 기능을 사용할 수 없습니다."
        case .unknown:
            return "Unknown repository error"
        }
    }
}

// MARK: - API Error Classification
enum APIErrorType {
    case networkOffline           // 비행기 모드, 네트워크 끊김
    case apiKeyExpired            // API 키 만료 (코드 30, 31)
    case dailyLimitExceeded       // 일일 한도 초과 (코드 22)
    case serverError              // 서버 오류 (5xx)
    case noData                   // 데이터 없음 (코드 03)
    case unknown

    var shouldUseMockData: Bool {
        switch self {
        case .apiKeyExpired, .dailyLimitExceeded, .serverError:
            return true  // Mock 데이터 사용
        case .networkOffline:
            return false  // 신규 유저는 차단, 기존 유저는 캐시만
        case .noData:
            return false  // 빈 결과 반환
        case .unknown:
            return false
        }
    }

    var userMessage: String? {
        switch self {
        case .apiKeyExpired:
            return "API 서비스 점검 중입니다.\n임시 데이터로 표시됩니다."
        case .dailyLimitExceeded:
            return "일일 API 호출 한도 초과\n캐시 및 임시 데이터로 표시됩니다."
        case .serverError:
            return "서버 오류가 발생했습니다.\n임시 데이터로 표시됩니다."
        case .networkOffline:
            return "네트워크 연결이 필요합니다."
        case .noData:
            return nil
        case .unknown:
            return nil
        }
    }

    init(from error: Error) {
        print("🔍 APIErrorType.init - Analyzing error: \(error)")

        // Moya 에러 분석
        if let moyaError = error as? MoyaError {
            print("🔍 Detected MoyaError: \(moyaError)")

            switch moyaError {
            case .underlying(let nsError, _):
                print("🔍 MoyaError.underlying: \(nsError)")
                // URLError 체크 (네트워크 끊김)
                if let urlError = nsError as? URLError {
                    print("🔍 Detected URLError: \(urlError.code)")
                    switch urlError.code {
                    case .notConnectedToInternet, .networkConnectionLost, .timedOut:
                        print("✅ Classified as: networkOffline")
                        self = .networkOffline
                        return
                    default:
                        break
                    }
                }
            case .statusCode(let response):
                print("🔍 MoyaError.statusCode: \(response.statusCode)")
                // HTTP 상태 코드 체크
                switch response.statusCode {
                case 401, 403:
                    // 401 Unauthorized: 잘못된 API 키
                    // 403 Forbidden: 권한 없음 또는 일일 한도 초과
                    print("✅ Classified as: apiKeyExpired (status \(response.statusCode))")
                    self = .apiKeyExpired
                    return
                case 500...599:
                    // 5xx: 서버 오류
                    print("✅ Classified as: serverError (status \(response.statusCode))")
                    self = .serverError
                    return
                default:
                    print("⚠️ Unhandled status code: \(response.statusCode)")
                    break
                }

            case .objectMapping(_, let response):
                // JSON 파싱 실패 - 하지만 response에 status code가 있음
                print("🔍 MoyaError.objectMapping with statusCode: \(response.statusCode)")
                switch response.statusCode {
                case 401, 403:
                    // 401 Unauthorized: 잘못된 API 키 (JSON이 아닌 "Unauthorized" 텍스트 응답)
                    print("✅ Classified as: apiKeyExpired (objectMapping with status \(response.statusCode))")
                    self = .apiKeyExpired
                    return
                case 500...599:
                    print("✅ Classified as: serverError (objectMapping with status \(response.statusCode))")
                    self = .serverError
                    return
                default:
                    print("⚠️ Unhandled objectMapping status code: \(response.statusCode)")
                    break
                }

            default:
                print("🔍 Other MoyaError case: \(moyaError)")
                break
            }
        } else {
            print("🔍 Not a MoyaError")
        }

        // DataSourceError 체크
        if let dataSourceError = error as? DataSourceError {
            print("🔍 Detected DataSourceError: \(dataSourceError)")
            switch dataSourceError {
            case .networkError:
                print("✅ Classified as: networkOffline (DataSourceError)")
                self = .networkOffline
                return
            default:
                break
            }
        }

        print("⚠️ Classified as: unknown (no match found)")
        self = .unknown
    }
}
