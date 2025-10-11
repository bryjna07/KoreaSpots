//
//  ManageFavoriteUseCase.swift
//  KoreaSpots
//
//  Created by YoungJin on 10/11/25.
//

import Foundation
import RxSwift

// MARK: - Toggle Favorite UseCase
protocol ToggleFavoriteUseCase {
    func execute(place: Place, isFavorite: Bool) -> Completable
}

final class ToggleFavoriteUseCaseImpl: ToggleFavoriteUseCase {
    private let favoriteRepository: FavoriteRepository

    init(favoriteRepository: FavoriteRepository) {
        self.favoriteRepository = favoriteRepository
    }

    func execute(place: Place, isFavorite: Bool) -> Completable {
        return favoriteRepository.toggleFavorite(place: place, isFavorite: isFavorite)
    }
}

// MARK: - Get Favorites UseCase
protocol GetFavoritesUseCase {
    func execute() -> Observable<[Place]>
}

final class GetFavoritesUseCaseImpl: GetFavoritesUseCase {
    private let favoriteRepository: FavoriteRepository

    init(favoriteRepository: FavoriteRepository) {
        self.favoriteRepository = favoriteRepository
    }

    func execute() -> Observable<[Place]> {
        return favoriteRepository.getFavorites()
    }
}

// MARK: - Check Favorite UseCase
protocol CheckFavoriteUseCase {
    func execute(contentId: String) -> Single<Bool>
}

final class CheckFavoriteUseCaseImpl: CheckFavoriteUseCase {
    private let favoriteRepository: FavoriteRepository

    init(favoriteRepository: FavoriteRepository) {
        self.favoriteRepository = favoriteRepository
    }

    func execute(contentId: String) -> Single<Bool> {
        return favoriteRepository.isFavorite(contentId: contentId)
    }
}

// MARK: - Get Favorite Count UseCase
protocol GetFavoriteCountUseCase {
    func execute() -> Single<Int>
}

final class GetFavoriteCountUseCaseImpl: GetFavoriteCountUseCase {
    private let favoriteRepository: FavoriteRepository

    init(favoriteRepository: FavoriteRepository) {
        self.favoriteRepository = favoriteRepository
    }

    func execute() -> Single<Int> {
        return favoriteRepository.getFavoriteCount()
    }
}
