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
    }

    enum Mutation {
        case setArea(AreaCode?)
        case setSigungu(Int?)
        case setPlaces([Place])
        case appendPlaces([Place])
        case setLoading(Bool)
        case setError(String?)
        case setCurrentPage(Int)
    }

    struct State {
        var selectedArea: AreaCode?
        var selectedSigungu: Int?
        var contentTypeId: Int?
        var cat1: String?
        var cat2: String?
        var cat3: String?
        var places: [Place] = []
        var isLoading: Bool = false
        var error: String?
        var currentPage: Int = 1
        var hasMorePages: Bool = true
    }

    let initialState: State

    // MARK: - Dependencies
    private let fetchAreaBasedPlacesUseCase: FetchAreaBasedPlacesUseCase
    private let itemsPerPage: Int = 20

    init(
        initialArea: AreaCode? = nil,
        contentTypeId: Int? = nil,
        cat1: String? = nil,
        cat2: String? = nil,
        cat3: String? = nil,
        fetchAreaBasedPlacesUseCase: FetchAreaBasedPlacesUseCase
    ) {
        self.fetchAreaBasedPlacesUseCase = fetchAreaBasedPlacesUseCase
        self.initialState = State(
            selectedArea: initialArea,
            selectedSigungu: nil,
            contentTypeId: contentTypeId,
            cat1: cat1,
            cat2: cat2,
            cat3: cat3,
            places: [],
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
        }

        return newState
    }

    // MARK: - Private Methods
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
