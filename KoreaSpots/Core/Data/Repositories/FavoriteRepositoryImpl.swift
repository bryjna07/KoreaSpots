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
        // Mock 모드에서는 쓰기 작업 차단
        guard AppStateManager.shared.canPerformWriteOperation() else {
            print("❌ addFavorite blocked - Mock mode active")
            return .error(FavoriteRepositoryError.writeOperationBlocked)
        }

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
        // Mock 모드에서는 쓰기 작업 차단
        guard AppStateManager.shared.canPerformWriteOperation() else {
            print("❌ removeFavorite blocked - Mock mode active")
            return .error(FavoriteRepositoryError.writeOperationBlocked)
        }

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
        // Mock 모드에서는 쓰기 작업 차단
        guard AppStateManager.shared.canPerformWriteOperation() else {
            print("❌ toggleFavorite blocked - Mock mode active")
            return .error(FavoriteRepositoryError.writeOperationBlocked)
        }

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

// MARK: - Repository Errors
enum FavoriteRepositoryError: Error, LocalizedError {
    case writeOperationBlocked  // Mock 모드에서 쓰기 작업 차단

    var errorDescription: String? {
        switch self {
        case .writeOperationBlocked:
            return "현재 서버 오류로 인해\n예시 데이터를 표시 중입니다.\n\n예시 데이터 사용 중에는\n이 기능을 사용할 수 없습니다."
        }
    }
}
