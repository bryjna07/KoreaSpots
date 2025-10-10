//
//  PlaceSelectorReactor.swift
//  KoreaSpots
//
//  Created by YoungJin on 10/10/25.
//

import Foundation
import ReactorKit
import RxSwift

enum PlaceSelectorTab {
    case favorites
    case search
}

final class PlaceSelectorReactor: Reactor {

    enum Action {
        case selectTab(PlaceSelectorTab)
        case loadFavorites
        case searchKeyword(String)
        case togglePlace(String, Place)
        case confirm
    }

    enum Mutation {
        case setTab(PlaceSelectorTab)
        case setFavorites([Place])
        case setSearchResults([Place])
        case toggleSelection(String, Place)
        case setLoading(Bool)
        case setError(String)
        case triggerConfirm([String])
    }

    struct State {
        var currentTab: PlaceSelectorTab = .favorites
        var favoritePlaces: [Place] = []
        var searchResults: [Place] = []
        var selectedPlaceIds: Set<String>
        var selectedPlaces: [String: Place] = [:] // Store actual Place objects
        var maxSelectionCount: Int
        var isLoading: Bool = false
        var errorMessage: String?

        @Pulse var confirmEvent: [String] = []

        var displayPlaces: [Place] {
            switch currentTab {
            case .favorites:
                return favoritePlaces
            case .search:
                return searchResults
            }
        }
    }

    let initialState: State

    private let tourRepository: TourRepository

    init(
        tourRepository: TourRepository,
        maxSelectionCount: Int,
        preSelectedPlaceIds: [String]
    ) {
        self.tourRepository = tourRepository
        self.initialState = State(
            selectedPlaceIds: Set(preSelectedPlaceIds),
            maxSelectionCount: maxSelectionCount
        )
    }

    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .selectTab(let tab):
            return .concat([
                .just(.setTab(tab)),
                tab == .favorites ? loadFavorites() : .empty()
            ])

        case .loadFavorites:
            return loadFavorites()

        case .searchKeyword(let keyword):
            guard !keyword.isEmpty, keyword.count >= 2 else {
                return .just(.setSearchResults([]))
            }

            return .concat([
                .just(.setLoading(true)),
                tourRepository.searchPlacesByKeyword(
                    keyword: keyword,
                    areaCode: nil,
                    sigunguCode: nil,
                    contentTypeId: nil,
                    cat1: nil,
                    cat2: nil,
                    cat3: nil,
                    numOfRows: 20,
                    pageNo: 1,
                    arrange: "A"
                )
                .asObservable()
                .map { Mutation.setSearchResults($0) }
                .catch { error in
                    print("❌ Search error: \(error)")
                    return .just(.setError("검색 중 오류가 발생했습니다."))
                }
            ])

        case .togglePlace(let contentId, let place):
            return .just(.toggleSelection(contentId, place))

        case .confirm:
            let selectedIds = Array(currentState.selectedPlaceIds)
            print("✅ Confirming selection: \(selectedIds)")
            return .just(.triggerConfirm(selectedIds))
        }
    }

    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state

        switch mutation {
        case .setTab(let tab):
            newState.currentTab = tab

        case .setFavorites(let places):
            newState.favoritePlaces = places
            newState.isLoading = false

        case .setSearchResults(let places):
            newState.searchResults = places
            newState.isLoading = false

        case .toggleSelection(let placeId, let place):
            print("🔄 Toggle place: \(placeId) - \(place.title)")
            if newState.selectedPlaceIds.contains(placeId) {
                newState.selectedPlaceIds.remove(placeId)
                newState.selectedPlaces.removeValue(forKey: placeId)
                print("  ➖ Removed")
            } else {
                // Check max selection count
                if newState.selectedPlaceIds.count >= newState.maxSelectionCount {
                    newState.errorMessage = "최대 \(newState.maxSelectionCount)개까지 선택 가능합니다."
                } else {
                    newState.selectedPlaceIds.insert(placeId)
                    newState.selectedPlaces[placeId] = place
                    print("  ➕ Added")
                }
            }
            print("  📊 Total selected: \(newState.selectedPlaceIds.count)")

        case .setLoading(let isLoading):
            newState.isLoading = isLoading

        case .setError(let error):
            newState.errorMessage = error
            newState.isLoading = false

        case .triggerConfirm(let selectedIds):
            newState.confirmEvent = selectedIds
        }

        return newState
    }

    // MARK: - Private Methods

    private func loadFavorites() -> Observable<Mutation> {
        return .concat([
            .just(.setLoading(true)),
            tourRepository.getFavoritePlaces()
                .asObservable()
                .map { Mutation.setFavorites($0) }
                .catch { error in
                    print("❌ Load favorites error: \(error)")
                    return .just(.setError("즐겨찾기를 불러오는 중 오류가 발생했습니다."))
                }
        ])
    }
}
