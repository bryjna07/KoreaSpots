//
//  FavoriteReactor.swift
//  KoreaSpots
//
//  Created by YoungJin on 10/11/25.
//

import Foundation
import ReactorKit
import RxSwift

final class FavoriteReactor: Reactor {

    enum Action {
        case viewDidLoad
        case refresh
        case toggleFavorite(Place, Bool) // place, currentIsFavorite
    }

    enum Mutation {
        case setFavorites([Place])
        case setFavoriteCount(Int)
        case setError(String)
    }

    struct State {
        var favorites: [Place] = []
        var favoriteCount: Int = 0
        var error: String?
    }

    let initialState = State()

    private let getFavoritesUseCase: GetFavoritesUseCase
    private let toggleFavoriteUseCase: ToggleFavoriteUseCase
    private let getFavoriteCountUseCase: GetFavoriteCountUseCase
    private let disposeBag = DisposeBag()

    init(
        getFavoritesUseCase: GetFavoritesUseCase,
        toggleFavoriteUseCase: ToggleFavoriteUseCase,
        getFavoriteCountUseCase: GetFavoriteCountUseCase
    ) {
        self.getFavoritesUseCase = getFavoritesUseCase
        self.toggleFavoriteUseCase = toggleFavoriteUseCase
        self.getFavoriteCountUseCase = getFavoriteCountUseCase
    }

    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewDidLoad, .refresh:
            return loadFavorites()

        case .toggleFavorite(let place, let isFavorite):
            return toggleFavoriteUseCase.execute(place: place, isFavorite: isFavorite)
                .andThen(Observable.just(()))
                .flatMap { _ -> Observable<Mutation> in
                    // Realm auto-update will handle list update
                    return self.loadFavoriteCount()
                }
                .catch { error in
                    print("❌ Toggle favorite error: \(error)")
                    return .just(.setError("즐겨찾기 변경 중 오류가 발생했습니다."))
                }
        }
    }

    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state

        switch mutation {
        case .setFavorites(let favorites):
            newState.favorites = favorites
            newState.favoriteCount = favorites.count

        case .setFavoriteCount(let count):
            newState.favoriteCount = count

        case .setError(let error):
            newState.error = error
        }

        return newState
    }

    // MARK: - Transform

    func transform(mutation: Observable<Mutation>) -> Observable<Mutation> {
        // Realm auto-update를 통한 favorites 관찰
        let favoritesObservation = getFavoritesUseCase.execute()
            .map { Mutation.setFavorites($0) }
            .catch { error in
                print("❌ Favorites observation error: \(error)")
                return .just(.setError("즐겨찾기 목록을 불러오는 중 오류가 발생했습니다."))
            }

        return Observable.merge(mutation, favoritesObservation)
    }

    // MARK: - Private Methods

    private func loadFavorites() -> Observable<Mutation> {
        return Observable.concat([
            loadFavoriteCount()
        ])
    }

    private func loadFavoriteCount() -> Observable<Mutation> {
        return getFavoriteCountUseCase.execute()
            .asObservable()
            .map { Mutation.setFavoriteCount($0) }
            .catch { error in
                print("❌ Load favorite count error: \(error)")
                return .empty()
            }
    }
}
