//
//  FavoriteRepositoryImpl.swift
//  KoreaSpots
//
//  Created by YoungJin on 10/11/25.
//

import Foundation
import RxSwift
import RealmSwift

final class FavoriteRepositoryImpl: FavoriteRepository {
    private let localDataSource: TourLocalDataSource

    init(localDataSource: TourLocalDataSource) {
        self.localDataSource = localDataSource
    }

    func addFavorite(place: Place) -> Completable {
        return Completable.create { single in
            do {
                let realm = try Realm()
                try realm.write {
                    let placeR = PlaceR(place: place)
                    placeR.isFavorite = true
                    realm.add(placeR, update: .modified)
                }
                single(.completed)
            } catch {
                single(.error(error))
            }
            return Disposables.create()
        }
    }

    func removeFavorite(contentId: String) -> Completable {
        return Completable.create { single in
            do {
                let realm = try Realm()
                try realm.write {
                    if let place = realm.object(ofType: PlaceR.self, forPrimaryKey: contentId) {
                        place.isFavorite = false
                    }
                }
                single(.completed)
            } catch {
                single(.error(error))
            }
            return Disposables.create()
        }
    }

    func toggleFavorite(place: Place, isFavorite: Bool) -> Completable {
        if isFavorite {
            return removeFavorite(contentId: place.contentId)
        } else {
            return addFavorite(place: place)
        }
    }

    func getFavorites() -> Observable<[Place]> {
        // Realm auto-update 활용: Results를 관찰
        return Observable.create { observer in
            do {
                let realm = try Realm()
                let results = realm.objects(PlaceR.self).where { $0.isFavorite == true }

                // Initial emission
                let places = results.map { $0.toDomain() }
                observer.onNext(Array(places))

                // Observe changes
                let token = results.observe { changes in
                    switch changes {
                    case .initial(let collection):
                        let places = collection.map { $0.toDomain() }
                        observer.onNext(Array(places))

                    case .update(let collection, _, _, _):
                        let places = collection.map { $0.toDomain() }
                        observer.onNext(Array(places))

                    case .error(let error):
                        observer.onError(error)
                    }
                }

                return Disposables.create {
                    token.invalidate()
                }
            } catch {
                observer.onError(error)
                return Disposables.create()
            }
        }
    }

    func isFavorite(contentId: String) -> Single<Bool> {
        return Single.create { single in
            do {
                let realm = try Realm()
                if let place = realm.object(ofType: PlaceR.self, forPrimaryKey: contentId) {
                    single(.success(place.isFavorite))
                } else {
                    single(.success(false))
                }
            } catch {
                single(.failure(error))
            }
            return Disposables.create()
        }
    }

    func getFavoriteCount() -> Single<Int> {
        return Single.create { single in
            do {
                let realm = try Realm()
                let count = realm.objects(PlaceR.self).where { $0.isFavorite == true }.count
                single(.success(count))
            } catch {
                single(.failure(error))
            }
            return Disposables.create()
        }
    }
}
