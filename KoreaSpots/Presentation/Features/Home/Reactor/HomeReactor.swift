//
//  HomeReactor.swift
//  KoreaSpots
//
//  Created by YoungJin on 9/25/25.
//

import Foundation
import ReactorKit
import RxSwift

final class HomeReactor: Reactor {

    enum Action {
        case viewDidLoad
        case refresh
        case locationPermissionGranted(latitude: Double, longitude: Double)
        case locationPermissionDenied
    }

    enum Mutation {
        case setLoading(Bool)
        case setFestivals([Place])
        case setNearbyPlaces([Place])
        case setError(String?)
        case setUserLocation(latitude: Double, longitude: Double)
        case setCurrentAreaCode(AreaCode?)
        case setShouldShowNearbySection(Bool)
    }

    struct State {
        var isLoading: Bool = false
        var festivals: [Place] = []
        var nearbyPlaces: [Place] = []
        var error: String?
        var userLocation: (latitude: Double, longitude: Double)?
        var currentAreaCode: AreaCode?
        var sections: [HomeSectionModel] = []
        var shouldShowNearbySection: Bool = true
    }

    let initialState: State = {
        // 스켈레톤뷰 표시를 위한 초기 상태 (더미 데이터)
        let categoryItems = Category.homeCategories.map { HomeSectionItem.category($0) }

        // SkeletonDataProvider로 더미 데이터 생성
        let skeletonFestivals = SkeletonDataProvider.makeSkeletonPlaces(count: 1, type: .festival)
        let skeletonPlaces = SkeletonDataProvider.makeSkeletonPlaces(count: 3, type: .place)

        let initialSections = [
            HomeSectionModel(section: .festival, items: skeletonFestivals.map { HomeSectionItem.festival($0) }),
            HomeSectionModel(section: .category, items: categoryItems),
            HomeSectionModel(section: .theme, items: Theme.staticThemes.map { HomeSectionItem.theme($0) }),
            HomeSectionModel(section: .nearby, items: skeletonPlaces.map { HomeSectionItem.place($0) }),
        ]
        return State(
            isLoading: true,
            festivals: skeletonFestivals,  // State의 festivals 배열에도 스켈레톤 추가
            nearbyPlaces: skeletonPlaces,   // State의 nearbyPlaces 배열에도 스켈레톤 추가
            sections: initialSections
        )
    }()

    // MARK: - Dependencies
    private let fetchFestivalUseCase: FetchFestivalUseCase
    private let fetchLocationBasedPlacesUseCase: FetchLocationBasedPlacesUseCase
    let locationService: LocationService

    init(fetchFestivalUseCase: FetchFestivalUseCase,
         fetchLocationBasedPlacesUseCase: FetchLocationBasedPlacesUseCase,
         locationService: LocationService) {
        self.fetchFestivalUseCase = fetchFestivalUseCase
        self.fetchLocationBasedPlacesUseCase = fetchLocationBasedPlacesUseCase
        self.locationService = locationService
    }

    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewDidLoad:
            // Nearby는 observeLocationUpdates()를 통해 자동으로 로드됨
            return Observable.concat([
                Observable.just(.setLoading(true)),
                fetchCurrentFestivals(),
                Observable.just(.setLoading(false))
            ])

        case .refresh:
            // Nearby는 observeLocationUpdates()를 통해 자동으로 로드됨
            return Observable.concat([
                Observable.just(.setLoading(true)),
                fetchCurrentFestivals(),
                Observable.just(.setLoading(false))
            ])

        case let .locationPermissionGranted(latitude, longitude):
            // 한국 내 위치인지 먼저 확인
            let isInKorea = locationService.isCoordinateInKorea(latitude: latitude, longitude: longitude)

            if !isInKorea {
                // 한국 밖이면 Nearby 섹션 숨김 + 전국 축제 데이터 로드
                return Observable.concat([
                    Observable.just(.setUserLocation(latitude: latitude, longitude: longitude)),
                    Observable.just(.setShouldShowNearbySection(false)),
                    Observable.just(.setNearbyPlaces([])),
                    Observable.just(.setLoading(true)),
                    fetchCurrentFestivals(),  // 전국 축제 데이터 로드 (areaCode=nil)
                    Observable.just(.setLoading(false))
                ])
            }

            // 한국 내면 Nearby 섹션 표시 + 지역 기반 축제 + 주변 장소 로드
            return Observable.concat([
                Observable.just(.setUserLocation(latitude: latitude, longitude: longitude)),
                Observable.just(.setShouldShowNearbySection(true)),
                Observable.just(.setLoading(true)),
                fetchFestivalsFromLastKnownLocation(),  // 마지막 위치 기반 지역 축제 로드
                fetchNearbyPlaces(latitude: latitude, longitude: longitude),
                Observable.just(.setLoading(false))
            ])

        case .locationPermissionDenied:
            // 위치 권한 거부 시: 전국 축제 데이터 로드, Nearby 섹션 숨김
            return Observable.concat([
                Observable.just(.setCurrentAreaCode(nil)),  // 지역코드 초기화
                Observable.just(.setShouldShowNearbySection(false)),
                Observable.just(.setNearbyPlaces([])),
                Observable.just(.setLoading(true)),
                fetchCurrentFestivals(),  // 전국 축제 데이터 로드 (areaCode=nil)
                Observable.just(.setLoading(false))
            ])
        }
    }

    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state

        switch mutation {
        case let .setLoading(isLoading):
            newState.isLoading = isLoading

        case let .setFestivals(festivals):
            newState.festivals = festivals
            newState.error = nil
            newState.sections = buildSections(
                festivals: festivals,
                nearbyPlaces: newState.nearbyPlaces,
                shouldShowNearby: newState.shouldShowNearbySection
            )

        case let .setNearbyPlaces(places):
            newState.nearbyPlaces = places
            newState.error = nil
            newState.sections = buildSections(
                festivals: newState.festivals,
                nearbyPlaces: places,
                shouldShowNearby: newState.shouldShowNearbySection
            )

        case let .setError(error):
            newState.error = error

        case let .setUserLocation(latitude, longitude):
            newState.userLocation = (latitude: latitude, longitude: longitude)

        case let .setCurrentAreaCode(areaCode):
            newState.currentAreaCode = areaCode

        case let .setShouldShowNearbySection(shouldShow):
            newState.shouldShowNearbySection = shouldShow
            // buildSections는 setNearbyPlaces에서 호출될 예정이므로 여기서는 생략
        }

        return newState
    }
}

// MARK: - Private Methods
private extension HomeReactor {

    func fetchCurrentFestivals() -> Observable<Mutation> {
        let today = DateFormatterUtil.yyyyMMdd.string(from: Date())
        let endDate = DateFormatterUtil.yyyyMMdd.string(from: Date().addingTimeInterval(30 * 24 * 60 * 60))

        // 사용자 위치 기반 지역코드 조회 후 축제 요청
        return locationService.getCurrentAreaCode()
            .asObservable()
            .flatMap { [weak self] areaCode -> Observable<Mutation> in
                guard let self else { return .empty() }

                let input = FetchFestivalInput(
                    startDate: today,
                    endDate: endDate,
                    areaCode: areaCode?.rawValue,
                    maxCount: 20,
                    sortOption: .date
                )

                return Observable.concat([
                    .just(.setCurrentAreaCode(areaCode)),
                    self.fetchFestivalUseCase
                        .execute(input)
                        .asObservable()
                        .map(Mutation.setFestivals)
                ])
            }
            .catch { _ in .just(.setFestivals([])) }
    }

    /// 마지막으로 알려진 위치 기반 축제 데이터 로드
    func fetchFestivalsFromLastKnownLocation() -> Observable<Mutation> {
        let today = DateFormatterUtil.yyyyMMdd.string(from: Date())
        let endDate = DateFormatterUtil.yyyyMMdd.string(from: Date().addingTimeInterval(30 * 24 * 60 * 60))

        // 마지막 위치 기반 지역코드 조회 후 축제 요청
        return locationService.getAreaCodeFromLastKnownLocation()
            .asObservable()
            .flatMap { [weak self] areaCode -> Observable<Mutation> in
                guard let self else { return .empty() }

                let input = FetchFestivalInput(
                    startDate: today,
                    endDate: endDate,
                    areaCode: areaCode?.rawValue,
                    maxCount: 10,
                    sortOption: .date
                )

                return Observable.concat([
                    .just(.setCurrentAreaCode(areaCode)),
                    self.fetchFestivalUseCase
                        .execute(input)
                        .asObservable()
                        .map(Mutation.setFestivals)
                ])
            }
            .catch { _ in .just(.setFestivals([])) }
    }

    func fetchNearbyPlaces(latitude: Double, longitude: Double) -> Observable<Mutation> {
        let input = FetchLocationBasedPlacesInput(
            latitude: latitude,
            longitude: longitude,
            radius: 1000,
            contentTypeId: 12,  // 관광지만 필터링 (12: 관광지, 14: 문화시설, 15: 축제, 38: 쇼핑, 39: 음식점)
            maxCount: 10,
            sortOption: .distance
        )

        return fetchLocationBasedPlacesUseCase
            .execute(input)
            .asObservable()
            .map(Mutation.setNearbyPlaces)
            .catch { _ in .just(.setNearbyPlaces([])) }
    }

    private func buildSections(festivals: [Place], nearbyPlaces: [Place], shouldShowNearby: Bool) -> [HomeSectionModel] {
        var sections: [HomeSectionModel] = []

        // Festival Section
        let festivalItems = festivals.map { HomeSectionItem.festival($0) }
        sections.append(HomeSectionModel(section: .festival, items: festivalItems))

        // Category Section (항상 표시)
        let categoryItems = Category.homeCategories.map { HomeSectionItem.category($0) }
        sections.append(HomeSectionModel(section: .category, items: categoryItems))

        // Theme Section (항상 표시)
        let themeItems = Theme.staticThemes.map { HomeSectionItem.theme($0) }
        sections.append(HomeSectionModel(section: .theme, items: themeItems))

        // Nearby Places Section - 한국 내에서만 표시
        if shouldShowNearby {
            let nearbyItems = nearbyPlaces.map { HomeSectionItem.place($0) }
            sections.append(HomeSectionModel(section: .nearby, items: nearbyItems))
        }

        return sections
    }

}

// MARK: - Public Methods
extension HomeReactor {

    func requestLocationPermission() {
        locationService.requestLocationPermission()
    }

    func observeLocationUpdates() -> Observable<Action> {
        return locationService.currentLocation
            .map { Action.locationPermissionGranted(latitude: $0.coordinate.latitude, longitude: $0.coordinate.longitude) }
    }

    func observeAuthorizationStatus() -> Observable<Action> {
        return locationService.authorizationStatus
            .distinctUntilChanged()
            .compactMap { status -> Action? in
                switch status {
                case .denied, .restricted:
                    return .locationPermissionDenied
                default:
                    return nil
                }
            }
    }
}

