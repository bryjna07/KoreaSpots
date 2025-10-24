//
//  TourLocalDataSourceImpl.swift
//  KoreaSpots
//
//  Created by YoungJin on 9/29/25.
//

import Foundation
import RxSwift
import RealmSwift

final class TourLocalDataSourceImpl: TourLocalDataSource {

    private static var didLogRealmPath = false
    
    init() {
        // Realm 인스턴스는 각 스레드에서 별도로 생성
    }

    // 스레드별 Realm 인스턴스 생성
    private func createRealm() throws -> Realm {
        let realm = try Realm()
        return try Realm()
    }

    // MARK: - Place Cache
    func getPlaces(areaCode: Int?, sigunguCode: Int?, contentTypeId: Int?) -> Single<[Place]> {
        return Single.create { [weak self] observer in
            guard let self = self else {
                observer(.success([]))
                return Disposables.create()
            }

            do {
                var predicates: [NSPredicate] = []

                // areaCode 필터링: nil이면 areaCode가 nil인 데이터만 조회 (전국 데이터)
                if let areaCode = areaCode {
                    predicates.append(NSPredicate(format: "areaCode == %d", areaCode))
                } else {
                    predicates.append(NSPredicate(format: "areaCode == nil"))
                }

                if let sigunguCode = sigunguCode {
                    predicates.append(NSPredicate(format: "sigunguCode == %d", sigunguCode))
                }

                if let contentTypeId = contentTypeId {
                    predicates.append(NSPredicate(format: "contentTypeId == %d", contentTypeId))
                }

                let realm = try self.createRealm()
                let finalPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
                let cachedPlaces = realm.objects(PlaceR.self).filter(finalPredicate)

                // AM 4:00 (KST) 기준으로 needsRefresh() 체크하여 유효한 캐시만 반환
                let validPlaces = Array(cachedPlaces).filter { !$0.needsRefresh() }
                let places = validPlaces.map { $0.toDomain() }
                observer(.success(places))
            } catch {
                observer(.failure(DataSourceError.cacheError))
            }

            return Disposables.create()
        }
        .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .background))
    }

    func savePlaces(_ places: [Place], areaCode: Int?, sigunguCode: Int?, contentTypeId: Int?) -> Completable {
        return Completable.create { [weak self] observer in
            guard let self = self else {
                observer(.completed)
                return Disposables.create()
            }

            do {
                let realm = try self.createRealm()
                try realm.write {
                    for place in places {
                        if let existing = realm.object(ofType: PlaceR.self, forPrimaryKey: place.contentId) {
                            // Update existing
                            existing.update(from: place)
                            existing.cachedAt = Date()
                        } else {
                            // Create new
                            let newPlace = PlaceR(place: place)
                            realm.add(newPlace, update: .modified)
                        }
                    }
                }
                observer(.completed)
            } catch {
                observer(.error(DataSourceError.cacheError))
            }

            return Disposables.create()
        }
        .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .background))
    }

    func getLocationBasedPlaces(mapX: Double, mapY: Double, radius: Int) -> Single<[Place]> {
        return Single.create { [weak self] observer in
            guard let self = self else {
                observer(.success([]))
                return Disposables.create()
            }

            do {
                // 위치 기반 캐시는 좌표 범위와 반경으로 검색
                let radiusInDegrees = Double(radius) / 111000.0 // 대략적인 도 변환 (1도 ≈ 111km)

                let realm = try self.createRealm()
                let predicate = NSPredicate(format: "mapX BETWEEN {%f, %f} AND mapY BETWEEN {%f, %f}",
                                          mapX - radiusInDegrees, mapX + radiusInDegrees,
                                          mapY - radiusInDegrees, mapY + radiusInDegrees)

                let cachedPlaces = realm.objects(PlaceR.self).filter(predicate)

                // AM 4:00 (KST) 기준으로 needsRefresh() 체크하여 유효한 캐시만 반환
                let validPlaces = Array(cachedPlaces).filter { !$0.needsRefresh() }
                let places = validPlaces.map { $0.toDomain() }
                observer(.success(places))
            } catch {
                observer(.failure(DataSourceError.cacheError))
            }

            return Disposables.create()
        }
        .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .background))
    }

    func saveLocationBasedPlaces(_ places: [Place], mapX: Double, mapY: Double, radius: Int) -> Completable {
        return savePlaces(places, areaCode: 0, sigunguCode: nil, contentTypeId: nil) // 위치 기반은 areaCode 0으로 저장
    }

    // MARK: - Detail Cache
    func getPlaceDetail(contentId: String) -> Single<Place?> {
        return Single.create { [weak self] observer in
            guard let self = self else {
                observer(.success(nil))
                return Disposables.create()
            }

            do {
                let realm = try self.createRealm()
                let predicate = NSPredicate(format: "contentId == %@", contentId)

                if let cachedPlace = realm.objects(PlaceR.self).filter(predicate).first {
                    // AM 4:00 (KST) 기준으로 needsRefresh() 체크
                    if !cachedPlace.needsRefresh() {
                        observer(.success(cachedPlace.toDomain()))
                    } else {
                        observer(.success(nil))
                    }
                } else {
                    observer(.success(nil))
                }
            } catch {
                observer(.failure(DataSourceError.cacheError))
            }

            return Disposables.create()
        }
        .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .background))
    }

    func savePlaceDetail(_ place: Place) -> Completable {
        return Completable.create { [weak self] observer in
            guard let self = self else {
                observer(.completed)
                return Disposables.create()
            }

            do {
                let realm = try self.createRealm()
                try realm.write {
                    if let existing = realm.object(ofType: PlaceR.self, forPrimaryKey: place.contentId) {
                        existing.update(from: place)
                        existing.cachedAt = Date()
                    } else {
                        let newPlace = PlaceR(place: place)
                        realm.add(newPlace, update: .modified)
                    }
                }
                observer(.completed)
            } catch {
                observer(.error(DataSourceError.cacheError))
            }

            return Disposables.create()
        }
        .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .background))
    }

    // MARK: - Operating Info Cache
    func getOperatingInfo(contentId: String) -> Single<OperatingInfo?> {
        return Single.create { [weak self] observer in
            guard let self = self else {
                observer(.success(nil))
                return Disposables.create()
            }

            do {
                let realm = try self.createRealm()

                if let cachedPlace = realm.object(ofType: PlaceR.self, forPrimaryKey: contentId),
                   let operatingInfoE = cachedPlace.operatingInfo {

                    // TTL 체크 (7일)
                    if operatingInfoE.isValid() {
                        observer(.success(operatingInfoE.toDomain()))
                    } else {
                        observer(.success(nil))
                    }
                } else {
                    observer(.success(nil))
                }
            } catch {
                observer(.failure(DataSourceError.cacheError))
            }

            return Disposables.create()
        }
        .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .background))
    }

    func saveOperatingInfo(_ operatingInfo: OperatingInfo, contentId: String, contentTypeId: Int) -> Completable {
        return Completable.create { [weak self] observer in
            guard let self = self else {
                observer(.completed)
                return Disposables.create()
            }

            do {
                let realm = try self.createRealm()
                try realm.write {
                    if let existing = realm.object(ofType: PlaceR.self, forPrimaryKey: contentId) {
                        // 기존 Place가 있으면 operatingInfo 업데이트
                        let operatingInfoE = OperatingInfoE(from: operatingInfo, contentTypeId: contentTypeId)
                        existing.operatingInfo = operatingInfoE
                        print("✅ OperatingInfo saved for contentId: \(contentId)")
                    } else {
                        // Place가 없으면 새로 생성
                        let newPlace = PlaceR()
                        newPlace.contentId = contentId
                        newPlace.contentTypeId = contentTypeId

                        let operatingInfoE = OperatingInfoE(from: operatingInfo, contentTypeId: contentTypeId)
                        newPlace.operatingInfo = operatingInfoE

                        realm.add(newPlace, update: .modified)
                        print("✅ New Place with OperatingInfo created for contentId: \(contentId)")
                    }
                }
                observer(.completed)
            } catch {
                print("❌ Failed to save OperatingInfo: \(error)")
                observer(.error(DataSourceError.cacheError))
            }

            return Disposables.create()
        }
        .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .background))
    }

    // MARK: - Cache Management
    func isCacheValid(for key: String, ttl: TimeInterval) -> Single<Bool> {
        return Single.create { [weak self] observer in
            guard let self = self else {
                observer(.success(false))
                return Disposables.create()
            }

            do {
                let realm = try self.createRealm()
                // contentId를 캐시 키로 사용하여 PlaceR에서 검색 (이벤트 포함)
                let expiryDate = Date().addingTimeInterval(-ttl)

                let hasValidPlace = realm.objects(PlaceR.self)
                    .filter("contentId == %@ AND cachedAt > %@", key, expiryDate as NSDate)
                    .count > 0

                observer(.success(hasValidPlace))
            } catch {
                observer(.failure(DataSourceError.cacheError))
            }

            return Disposables.create()
        }
        .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .background))
    }

    func clearExpiredCache() -> Completable {
        return Completable.create { [weak self] observer in
            guard let self = self else {
                observer(.completed)
                return Disposables.create()
            }

            do {
                let realm = try self.createRealm()
                try realm.write {
                    let now = Date()

                    // Place 캐시: 7일 TTL (이벤트성 콘텐츠 포함)
                    let expiredPlaceDate = now.addingTimeInterval(-7 * 24 * 60 * 60) as NSDate
                    let expiredPlaces = realm.objects(PlaceR.self)
                        .filter("cachedAt < %@ AND isFavorite == false", expiredPlaceDate)
                    realm.delete(expiredPlaces)

                    print("✅ Expired cache cleared - Places: \(expiredPlaces.count)")
                }
                observer(.completed)
            } catch {
                print("❌ Failed to clear expired cache: \(error)")
                observer(.error(DataSourceError.cacheError))
            }

            return Disposables.create()
        }
        .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .background))
    }

    func clearAllCache() -> Completable {
        return Completable.create { [weak self] observer in
            guard let self = self else {
                observer(.completed)
                return Disposables.create()
            }

            do {
                let realm = try self.createRealm()
                try realm.write {
                    // 즐겨찾기가 아닌 항목만 삭제 (이벤트성 콘텐츠 포함)
                    let nonFavoritePlaces = realm.objects(PlaceR.self).filter("isFavorite == false")
                    realm.delete(nonFavoritePlaces)

                    print("✅ All cache cleared (preserving favorites)")
                }
                observer(.completed)
            } catch {
                print("❌ Failed to clear all cache: \(error)")
                observer(.error(DataSourceError.cacheError))
            }

            return Disposables.create()
        }
        .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .background))
    }

    // MARK: - Recent Search Keywords

    func saveRecentKeyword(_ keyword: String) -> Completable {
        return Completable.create { [weak self] observer in
            guard let self = self else {
                observer(.completed)
                return Disposables.create()
            }

            do {
                let realm = try self.createRealm()
                try realm.write {
                    // Check if keyword already exists
                    if let existing = realm.object(ofType: RecentSearchKeywordR.self, forPrimaryKey: keyword) {
                        // Update timestamp
                        existing.searchedAt = Date()
                    } else {
                        // Insert new keyword
                        let newKeyword = RecentSearchKeywordR(keyword: keyword)
                        realm.add(newKeyword)

                        // Keep only latest 10 keywords
                        let allKeywords = realm.objects(RecentSearchKeywordR.self)
                            .sorted(byKeyPath: "searchedAt", ascending: false)

                        if allKeywords.count > 10 {
                            let toDelete = Array(allKeywords.dropFirst(10))
                            realm.delete(toDelete)
                        }
                    }
                }
                print("✅ Recent keyword saved: \(keyword)")
                observer(.completed)
            } catch {
                print("❌ Failed to save recent keyword: \(error)")
                observer(.error(DataSourceError.cacheError))
            }

            return Disposables.create()
        }
        .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .background))
    }

    func getRecentKeywords(limit: Int) -> Single<[String]> {
        return Single.create { [weak self] observer in
            guard let self = self else {
                observer(.success([]))
                return Disposables.create()
            }

            do {
                let realm = try self.createRealm()
                let keywords = realm.objects(RecentSearchKeywordR.self)
                    .sorted(byKeyPath: "searchedAt", ascending: false)
                    .map { $0.keyword }

                let result = Array(keywords.prefix(limit))
                observer(.success(result))
            } catch {
                observer(.failure(DataSourceError.cacheError))
            }

            return Disposables.create()
        }
        .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .background))
    }

    func deleteRecentKeyword(_ keyword: String) -> Completable {
        return Completable.create { [weak self] observer in
            guard let self = self else {
                observer(.completed)
                return Disposables.create()
            }

            do {
                let realm = try self.createRealm()
                try realm.write {
                    if let object = realm.object(ofType: RecentSearchKeywordR.self, forPrimaryKey: keyword) {
                        realm.delete(object)
                        print("✅ Recent keyword deleted: \(keyword)")
                    }
                }
                observer(.completed)
            } catch {
                print("❌ Failed to delete recent keyword: \(error)")
                observer(.error(DataSourceError.cacheError))
            }

            return Disposables.create()
        }
        .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .background))
    }

    func clearAllRecentKeywords() -> Completable {
        return Completable.create { [weak self] observer in
            guard let self = self else {
                observer(.completed)
                return Disposables.create()
            }

            do {
                let realm = try self.createRealm()
                try realm.write {
                    let allKeywords = realm.objects(RecentSearchKeywordR.self)
                    realm.delete(allKeywords)
                    print("✅ All recent keywords cleared")
                }
                observer(.completed)
            } catch {
                print("❌ Failed to clear recent keywords: \(error)")
                observer(.error(DataSourceError.cacheError))
            }

            return Disposables.create()
        }
        .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .background))
    }

    // MARK: - Favorites

    func getFavoritePlaces() -> Single<[Place]> {
        return Single.create { [weak self] observer in
            guard let self = self else {
                observer(.success([]))
                return Disposables.create()
            }

            do {
                let realm = try self.createRealm()
                let favoritePlaces = realm.objects(PlaceR.self)
                    .filter("isFavorite == true")
                    .sorted(byKeyPath: "cachedAt", ascending: false)

                let places = Array(favoritePlaces).map { $0.toDomain() }
                observer(.success(places))
            } catch {
                observer(.failure(DataSourceError.cacheError))
            }

            return Disposables.create()
        }
        .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .background))
    }

    func toggleFavorite(contentId: String) -> Completable {
        return Completable.create { [weak self] observer in
            guard let self = self else {
                observer(.completed)
                return Disposables.create()
            }

            do {
                let realm = try self.createRealm()
                try realm.write {
                    if let place = realm.object(ofType: PlaceR.self, forPrimaryKey: contentId) {
                        place.isFavorite.toggle()
                        print("✅ Favorite toggled for contentId: \(contentId), isFavorite: \(place.isFavorite)")
                    } else {
                        // Place가 Realm에 없으면 새로 생성하고 isFavorite = true로 설정
                        print("⚠️ Place not found for contentId: \(contentId), creating new entry")
                        let newPlace = PlaceR()
                        newPlace.contentId = contentId
                        newPlace.isFavorite = true
                        realm.add(newPlace, update: .modified)
                        print("✅ Created new favorite place: \(contentId)")
                    }
                }
                observer(.completed)
            } catch {
                print("❌ Failed to toggle favorite: \(error)")
                observer(.error(DataSourceError.cacheError))
            }

            return Disposables.create()
        }
        .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .background))
    }
}
