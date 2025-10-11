//
//  FavoriteRepository.swift
//  KoreaSpots
//
//  Created by YoungJin on 10/11/25.
//

import Foundation
import RxSwift

protocol FavoriteRepository {
    /// Add a place to favorites
    func addFavorite(place: Place) -> Completable

    /// Remove a place from favorites
    func removeFavorite(contentId: String) -> Completable

    /// Toggle favorite (with place info for creating if needed)
    func toggleFavorite(place: Place, isFavorite: Bool) -> Completable

    /// Get all favorite places (with Realm auto-update)
    func getFavorites() -> Observable<[Place]>

    /// Check if a place is favorited
    func isFavorite(contentId: String) -> Single<Bool>

    /// Get favorite count
    func getFavoriteCount() -> Single<Int>
}
