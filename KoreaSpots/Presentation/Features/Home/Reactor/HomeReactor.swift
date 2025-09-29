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
        case setFestivals([Festival])
        case setNearbyPlaces([Place])
        case setError(String?)
        case setUserLocation(latitude: Double, longitude: Double)
    }

    struct State {
        var isLoading: Bool = false
        var festivals: [Festival] = []
        var nearbyPlaces: [Place] = []
        var error: String?
        var userLocation: (latitude: Double, longitude: Double)?
        var sections: [HomeSectionModel] = []
    }

    let initialState: State = {
        let festivalItems = (0..<3).map { HomeSectionItem.placeholder("축제 정보를 불러오는 중...", index: $0) }
        let nearbyItems = (0..<4).map { HomeSectionItem.placeholder("주변 관광지를 불러오는 중...", index: $0) }
        let areaItems = AreaCode.allCases.map { HomeSectionItem.areaCode($0) }

        let initialSections = [
            HomeSectionModel(section: .festival, items: festivalItems),
            HomeSectionModel(section: .nearby, items: nearbyItems),
            HomeSectionModel(section: .theme, items: Theme.staticThemes.map { HomeSectionItem.theme($0) }),
            HomeSectionModel(section: .areaQuickLink, items: areaItems),
            HomeSectionModel(section: .placeholder, items: [HomeSectionItem.placeholder("추가 기능이 여기에 표시됩니다", index: 0)])
        ]
        return State(sections: initialSections)
    }()

    // MARK: - Dependencies
    private let fetchFestivalUseCase: FetchFestivalUseCase
    private let fetchLocationBasedPlacesUseCase: FetchLocationBasedPlacesUseCase
    private let locationService: LocationService

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
            newState.sections = buildSections(festivals: festivals, nearbyPlaces: newState.nearbyPlaces)

        case let .setNearbyPlaces(places):
            newState.nearbyPlaces = places
            newState.error = nil
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
            .map { festivals -> Mutation in
                .setFestivals(festivals)
            }
            .catch { error in
                Observable.just(.setError(LocalizedKeys.Error.fetchFestivalFailed.localized))
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
                Observable.just(.setError(LocalizedKeys.Error.fetchPlacesFailed.localized))
            }
    }

    private func buildSections(festivals: [Festival], nearbyPlaces: [Place]) -> [HomeSectionModel] {
        var sections: [HomeSectionModel] = []

        // Festival Section (Always show - with placeholder if empty)
        let festivalItems: [HomeSectionItem] = festivals.isEmpty
            ? (0..<3).map { HomeSectionItem.placeholder("축제 정보를 불러오는 중...", index: $0) }
            : festivals.map { HomeSectionItem.festival($0) }
        sections.append(HomeSectionModel(section: .festival, items: festivalItems))

        // Nearby Places Section (Show placeholder when empty)
        let placeItems: [HomeSectionItem] = nearbyPlaces.isEmpty
            ? (0..<4).map { HomeSectionItem.placeholder("주변 관광지를 불러오는 중...", index: $0) }
            : nearbyPlaces.map { HomeSectionItem.place($0) }
        sections.append(HomeSectionModel(section: .nearby, items: placeItems))

        // Theme Section (Always show)
        let themeItems = Theme.staticThemes.map { HomeSectionItem.theme($0) }
        sections.append(HomeSectionModel(section: .theme, items: themeItems))

        // Area QuickLink Section (Always show)
        let areaItems = AreaCode.allCases.map { HomeSectionItem.areaCode($0) }
        sections.append(HomeSectionModel(section: .areaQuickLink, items: areaItems))

        // Placeholder Section
        sections.append(HomeSectionModel(section: .placeholder, items: [.placeholder("추가 기능이 여기에 표시됩니다", index: 0)]))

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

