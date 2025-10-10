//
//  PlaceListReactor.swift
//  KoreaSpots
//
//  Created by YoungJin on 10/08/25.
//

import Foundation
import ReactorKit
import RxSwift

final class PlaceListReactor: Reactor {

    enum Action {
        case viewDidLoad
        case selectArea(AreaCode?)
        case selectSigungu(Int?)
        case refresh
        case loadNextPage
        case toggleFavorite(Place, Bool) // place, currentIsFavorite
    }

    enum Mutation {
        case setArea(AreaCode?)
        case setSigungu(Int?)
        case setPlaces([Place])
        case appendPlaces([Place])
        case setLoading(Bool)
        case setError(String?)
        case setCurrentPage(Int)
        case setFavorites([String: Bool]) // contentId: isFavorite
        case showToast(String)
    }

    struct State {
        var selectedArea: AreaCode?
        var selectedSigungu: Int?
        var contentTypeId: Int?
        var cat1: String?
        var cat2: String?
        var cat3: String?
        var places: [Place] = []
        var favorites: [String: Bool] = [:] // contentId: isFavorite
        var isLoading: Bool = false
        var error: String?
        var currentPage: Int = 1
        var hasMorePages: Bool = true
        @Pulse var toastMessage: String?
    }

    let initialState: State

    // MARK: - Dependencies
    private let fetchAreaBasedPlacesUseCase: FetchAreaBasedPlacesUseCase
    private let checkFavoriteUseCase: CheckFavoriteUseCase
    private let toggleFavoriteUseCase: ToggleFavoriteUseCase
    private let itemsPerPage: Int = 20

    init(
        initialArea: AreaCode? = nil,
        contentTypeId: Int? = nil,
        cat1: String? = nil,
        cat2: String? = nil,
        cat3: String? = nil,
        fetchAreaBasedPlacesUseCase: FetchAreaBasedPlacesUseCase,
        checkFavoriteUseCase: CheckFavoriteUseCase,
        toggleFavoriteUseCase: ToggleFavoriteUseCase
    ) {
        self.fetchAreaBasedPlacesUseCase = fetchAreaBasedPlacesUseCase
        self.checkFavoriteUseCase = checkFavoriteUseCase
        self.toggleFavoriteUseCase = toggleFavoriteUseCase
        self.initialState = State(
            selectedArea: initialArea,
            selectedSigungu: nil,
            contentTypeId: contentTypeId,
            cat1: cat1,
            cat2: cat2,
            cat3: cat3,
            places: [],
            favorites: [:],
            isLoading: false,
            error: nil,
            currentPage: 1,
            hasMorePages: true
        )
    }

    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewDidLoad:
            let area = currentState.selectedArea
            let sigungu = currentState.selectedSigungu
            let contentTypeId = currentState.contentTypeId

            return Observable.concat([
                Observable.just(.setLoading(true)),
                Observable.just(.setCurrentPage(1)),
                fetchPlaces(area: area, sigungu: sigungu, contentTypeId: contentTypeId, page: 1)
                    .map { Mutation.setPlaces($0) }
                    .catch { error in
                        Observable.just(Mutation.setError(error.localizedDescription))
                    },
                Observable.just(.setLoading(false))
            ])

        case let .selectArea(area):
            return Observable.concat([
                Observable.just(.setArea(area)),
                Observable.just(.setSigungu(nil)),
                Observable.just(.setLoading(true)),
                Observable.just(.setCurrentPage(1)),
                fetchPlaces(area: area, sigungu: nil, contentTypeId: currentState.contentTypeId, page: 1)
                    .map { Mutation.setPlaces($0) }
                    .catch { error in
                        Observable.just(Mutation.setError(error.localizedDescription))
                    },
                Observable.just(.setLoading(false))
            ])

        case let .selectSigungu(sigungu):
            let area = currentState.selectedArea
            let contentTypeId = currentState.contentTypeId

            return Observable.concat([
                Observable.just(.setSigungu(sigungu)),
                Observable.just(.setLoading(true)),
                Observable.just(.setCurrentPage(1)),
                fetchPlaces(area: area, sigungu: sigungu, contentTypeId: contentTypeId, page: 1)
                    .map { Mutation.setPlaces($0) }
                    .catch { error in
                        Observable.just(Mutation.setError(error.localizedDescription))
                    },
                Observable.just(.setLoading(false))
            ])

        case .refresh:
            let area = currentState.selectedArea
            let sigungu = currentState.selectedSigungu
            let contentTypeId = currentState.contentTypeId

            return Observable.concat([
                Observable.just(.setLoading(true)),
                Observable.just(.setCurrentPage(1)),
                fetchPlaces(area: area, sigungu: sigungu, contentTypeId: contentTypeId, page: 1)
                    .map { Mutation.setPlaces($0) }
                    .catch { error in
                        Observable.just(Mutation.setError(error.localizedDescription))
                    },
                Observable.just(.setLoading(false))
            ])

        case .loadNextPage:
            guard currentState.hasMorePages, !currentState.isLoading else {
                return Observable.empty()
            }

            let area = currentState.selectedArea
            let sigungu = currentState.selectedSigungu
            let contentTypeId = currentState.contentTypeId
            let nextPage = currentState.currentPage + 1

            return Observable.concat([
                Observable.just(.setLoading(true)),
                fetchPlaces(area: area, sigungu: sigungu, contentTypeId: contentTypeId, page: nextPage)
                    .map { places in
                        // 페이징된 아이템이 itemsPerPage보다 적으면 마지막 페이지
                        if places.count < self.itemsPerPage {
                            return .appendPlaces(places)
                        }
                        return .appendPlaces(places)
                    }
                    .catch { error in
                        Observable.just(Mutation.setError(error.localizedDescription))
                    },
                Observable.just(.setCurrentPage(nextPage)),
                Observable.just(.setLoading(false))
            ])

        case .toggleFavorite(let place, let isFavorite):
            let placeName = place.title

            return toggleFavoriteUseCase.execute(place: place, isFavorite: isFavorite)
                .andThen(Observable.just(()))
                .flatMap { _ -> Observable<Mutation> in
                    let toastMessage = isFavorite ? "" : "\(placeName)이(가) 즐겨찾기에 추가되었습니다."
                    return Observable.concat([
                        self.checkFavoriteStatus(contentId: place.contentId),
                        isFavorite ? .empty() : .just(.showToast(toastMessage))
                    ])
                }
                .catch { error in
                    print("❌ Toggle favorite error: \(error)")
                    return .just(.setError("좋아요 변경 중 오류가 발생했습니다."))
                }
        }
    }

    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state

        switch mutation {
        case let .setArea(area):
            newState.selectedArea = area
            newState.selectedSigungu = nil

        case let .setSigungu(sigungu):
            newState.selectedSigungu = sigungu

        case let .setPlaces(places):
            newState.places = places
            newState.hasMorePages = places.count >= itemsPerPage
            newState.error = nil

        case let .appendPlaces(places):
            newState.places.append(contentsOf: places)
            newState.hasMorePages = places.count >= itemsPerPage
            newState.error = nil

        case let .setLoading(isLoading):
            newState.isLoading = isLoading

        case let .setError(error):
            newState.error = error

        case let .setCurrentPage(page):
            newState.currentPage = page

        case let .setFavorites(favorites):
            newState.favorites = favorites

        case let .showToast(message):
            newState.toastMessage = message
        }

        return newState
    }

    func transform(mutation: Observable<Mutation>) -> Observable<Mutation> {
        // Places가 변경될 때마다 좋아요 상태 체크
        let favoritesUpdate = mutation
            .compactMap { mutation -> [Place]? in
                switch mutation {
                case .setPlaces(let places), .appendPlaces(let places):
                    return places
                default:
                    return nil
                }
            }
            .flatMap { places -> Observable<Mutation> in
                let contentIds = places.map { $0.contentId }
                return self.checkFavoritesStatus(contentIds: contentIds)
            }

        return Observable.merge(mutation, favoritesUpdate)
    }

    // MARK: - Private Methods

    private func checkFavoriteStatus(contentId: String) -> Observable<Mutation> {
        return checkFavoriteUseCase.execute(contentId: contentId)
            .asObservable()
            .map { isFavorite in
                var favorites = self.currentState.favorites
                favorites[contentId] = isFavorite
                return Mutation.setFavorites(favorites)
            }
            .catch { error in
                print("❌ Check favorite error: \(error)")
                return .empty()
            }
    }

    private func checkFavoritesStatus(contentIds: [String]) -> Observable<Mutation> {
        guard !contentIds.isEmpty else {
            return .empty()
        }

        let checks = contentIds.map { contentId in
            checkFavoriteUseCase.execute(contentId: contentId)
                .map { (contentId, $0) }
        }

        return Single.zip(checks)
            .asObservable()
            .map { results in
                var favorites: [String: Bool] = [:]
                results.forEach { contentId, isFavorite in
                    favorites[contentId] = isFavorite
                }
                return Mutation.setFavorites(favorites)
            }
            .catch { error in
                print("❌ Check favorites error: \(error)")
                return .empty()
            }
    }

    private func fetchPlaces(
        area: AreaCode?,
        sigungu: Int?,
        contentTypeId: Int?,
        page: Int
    ) -> Observable<[Place]> {
        // 지역 우선, 없으면 카테고리/테마 필터링으로 전국 검색
        let areaCode: Int
        if let area = area {
            areaCode = area.rawValue
        } else if currentState.cat1 != nil || currentState.cat2 != nil || currentState.cat3 != nil {
            // 카테고리/테마 필터가 있으면 전국 검색
            areaCode = 0
        } else if contentTypeId != nil {
            // contentTypeId만 있어도 전국 검색
            areaCode = 0
        } else {
            return Observable.just([])
        }

        return fetchAreaBasedPlacesUseCase
            .execute(
                areaCode: areaCode,
                sigunguCode: sigungu,
                contentTypeId: contentTypeId,
                cat1: currentState.cat1,
                cat2: currentState.cat2,
                cat3: currentState.cat3,
                maxCount: itemsPerPage
            )
            .asObservable()
            .observe(on: MainScheduler.instance)
    }
}
