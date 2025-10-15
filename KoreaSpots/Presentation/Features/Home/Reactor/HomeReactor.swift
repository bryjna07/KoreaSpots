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
    }

    enum Mutation {
        case setLoading(Bool)
        case setFestivals([Place])
        case setNearbyPlaces([Place])
        case setError(String?)
        case setUserLocation(latitude: Double, longitude: Double)
    }

    struct State {
        var isLoading: Bool = false
        var festivals: [Place] = []
        var nearbyPlaces: [Place] = []
        var error: String?
        var userLocation: (latitude: Double, longitude: Double)?
        var sections: [HomeSectionModel] = []
        var hasFestivalData: Bool = false  // 실제 축제 데이터 로드 여부
        var hasNearbyData: Bool = false    // 실제 관광지 데이터 로드 여부
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
        return State(isLoading: true, sections: initialSections)
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
            return Observable.concat([
                Observable.just(.setLoading(true)),
                fetchCurrentFestivals(),
                Observable.just(.setLoading(false))
            ])

        case .refresh:
            return Observable.concat([
                Observable.just(.setLoading(true)),
                fetchCurrentFestivals(),
                fetchNearbyPlacesIfLocationAvailable(),
                Observable.just(.setLoading(false))
            ])

        case let .locationPermissionGranted(latitude, longitude):
            return Observable.concat([
                Observable.just(.setUserLocation(latitude: latitude, longitude: longitude)),
                Observable.just(.setLoading(true)),
                fetchNearbyPlaces(latitude: latitude, longitude: longitude),
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
            // 실제 데이터가 로드되면 플래그 업데이트
            if !festivals.isEmpty {
                newState.hasFestivalData = true
            }
            newState.sections = buildSections(festivals: festivals, nearbyPlaces: newState.nearbyPlaces)

        case let .setNearbyPlaces(places):
            newState.nearbyPlaces = places
            newState.error = nil
            // 실제 데이터가 로드되면 플래그 업데이트
            if !places.isEmpty {
                newState.hasNearbyData = true
            }
            newState.sections = buildSections(festivals: newState.festivals, nearbyPlaces: places)

        case let .setError(error):
            newState.error = error

        case let .setUserLocation(latitude, longitude):
            newState.userLocation = (latitude: latitude, longitude: longitude)

        }

        return newState
    }
}

// MARK: - Private Methods
private extension HomeReactor {

    func fetchCurrentFestivals() -> Observable<Mutation> {
        let today = DateFormatterUtil.yyyyMMdd.string(from: Date())
        let endDate = DateFormatterUtil.yyyyMMdd.string(from: Date().addingTimeInterval(30 * 24 * 60 * 60)) // 30일 후

        let input = FetchFestivalInput(
            startDate: today,
            endDate: endDate,
            maxCount: 10,
            sortOption: .date
        )

        return fetchFestivalUseCase
            .execute(input)
            .asObservable()
            .map { places -> Mutation in
                .setFestivals(places)
            }
            .catch { error in
                // 에러 발생 시 스켈레톤 제거 + 에러 메시지 표시
                Observable.concat([
                    Observable.just(.setFestivals([])),
                    Observable.just(.setError(LocalizedKeys.Error.fetchFestivalFailed.localized))
                ])
            }
    }

    func fetchNearbyPlacesIfLocationAvailable() -> Observable<Mutation> {
        guard let location = currentState.userLocation else {
            return Observable.empty()
        }
        return fetchNearbyPlaces(latitude: location.latitude, longitude: location.longitude)
    }

    func fetchNearbyPlaces(latitude: Double, longitude: Double) -> Observable<Mutation> {
        let input = FetchLocationBasedPlacesInput(
            latitude: latitude,
            longitude: longitude,
            radius: 1000,
            maxCount: 20,
            sortOption: .distance
        )

        return fetchLocationBasedPlacesUseCase
            .execute(input)
            .asObservable()
            .map { places -> Mutation in
                .setNearbyPlaces(places)
            }
            .catch { error in
                // 에러 발생 시 스켈레톤 제거 + 에러 메시지 표시
                Observable.concat([
                    Observable.just(.setNearbyPlaces([])),
                    Observable.just(.setError(LocalizedKeys.Error.fetchPlacesFailed.localized))
                ])
            }
    }

    private func buildSections(festivals: [Place], nearbyPlaces: [Place]) -> [HomeSectionModel] {
        var sections: [HomeSectionModel] = []

        // Festival Section - 데이터가 있을 때만 표시
        let festivalItems = festivals.map { HomeSectionItem.festival($0) }
        sections.append(HomeSectionModel(section: .festival, items: festivalItems))

        // Category Section (항상 표시)
        let categoryItems = Category.homeCategories.map { HomeSectionItem.category($0) }
        sections.append(HomeSectionModel(section: .category, items: categoryItems))

        // Theme Section (항상 표시)
        let themeItems = Theme.staticThemes.map { HomeSectionItem.theme($0) }
        sections.append(HomeSectionModel(section: .theme, items: themeItems))

        // Nearby Places Section - 데이터가 있을 때만 표시
        let placeItems = nearbyPlaces.map { HomeSectionItem.place($0) }
        sections.append(HomeSectionModel(section: .nearby, items: placeItems))

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
}

