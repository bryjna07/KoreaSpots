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

    init() {
        // Realm 인스턴스는 각 스레드에서 별도로 생성
    }

    // 스레드별 Realm 인스턴스 생성
    private func createRealm() throws -> Realm {
        return try Realm()
    }

    // MARK: - Festival Cache
    func getFestivals(startDate: String, endDate: String) -> Single<[Festival]> {
        return Single.create { [weak self] observer in
            guard let self = self else {
                observer(.success([]))
                return Disposables.create()
            }

            do {
                let realm = try self.createRealm()
                let cachedFestivals = realm.objects(FestivalRealmObject.self)
                    .filter("eventStartDate >= %@ AND eventEndDate <= %@", startDate, endDate)
                    .filter("cachedAt > %@", Date().addingTimeInterval(-24 * 60 * 60) as NSDate) // 24시간 TTL

                let festivals = Array(cachedFestivals).map { $0.toDomain() }
                observer(.success(festivals))
            } catch {
                observer(.failure(DataSourceError.cacheError))
            }

            return Disposables.create()
        }
        .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .background))
    }

    func saveFestivals(_ festivals: [Festival], startDate: String, endDate: String) -> Completable {
        return Completable.create { [weak self] observer in
            guard let self = self else {
                observer(.completed)
                return Disposables.create()
            }

            do {
                let realm = try self.createRealm()
                try realm.write {
                    let realmObjects = festivals.map { festival in
                        let realmObject = FestivalRealmObject()
                        realmObject.configure(from: festival)
                        realmObject.cachedAt = Date()
                        return realmObject
                    }
                    realm.add(realmObjects, update: .modified)
                }
                observer(.completed)
            } catch {
                observer(.error(DataSourceError.cacheError))
            }

            return Disposables.create()
        }
        .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .background))
    }

    // MARK: - Place Cache
    func getPlaces(areaCode: Int, sigunguCode: Int?, contentTypeId: Int?) -> Single<[Place]> {
        return Single.create { [weak self] observer in
            guard let self = self else {
                observer(.success([]))
                return Disposables.create()
            }

            do {
                var predicate = NSPredicate(format: "areaCode == %d", areaCode)

                if let sigunguCode = sigunguCode {
                    let sigunguPredicate = NSPredicate(format: "sigunguCode == %d", sigunguCode)
                    predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate, sigunguPredicate])
                }

                if let contentTypeId = contentTypeId {
                    let contentTypePredicate = NSPredicate(format: "contentTypeId == %d", contentTypeId)
                    predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate, contentTypePredicate])
                }

                let realm = try self.createRealm()
                let ttlPredicate = NSPredicate(format: "cachedAt > %@", Date().addingTimeInterval(-3 * 60 * 60) as NSDate) // 3시간 TTL
                predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate, ttlPredicate])

                let cachedPlaces = realm.objects(PlaceRealmObject.self).filter(predicate)
                let places = Array(cachedPlaces).map { $0.toDomain() }
                observer(.success(places))
            } catch {
                observer(.failure(DataSourceError.cacheError))
            }

            return Disposables.create()
        }
        .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .background))
    }

    func savePlaces(_ places: [Place], areaCode: Int, sigunguCode: Int?, contentTypeId: Int?) -> Completable {
        return Completable.create { [weak self] observer in
            guard let self = self else {
                observer(.completed)
                return Disposables.create()
            }

            do {
                let realm = try self.createRealm()
                try realm.write {
                    let realmObjects = places.map { place in
                        let realmObject = PlaceRealmObject()
                        realmObject.configure(from: place)
                        realmObject.areaCode = areaCode
                        realmObject.sigunguCode = sigunguCode ?? 0
                        realmObject.contentTypeId = contentTypeId ?? 0
                        realmObject.cachedAt = Date()
                        return realmObject
                    }
                    realm.add(realmObjects, update: .modified)
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
                let predicate = NSPredicate(format: "mapX BETWEEN {%f, %f} AND mapY BETWEEN {%f, %f} AND cachedAt > %@",
                                          mapX - radiusInDegrees, mapX + radiusInDegrees,
                                          mapY - radiusInDegrees, mapY + radiusInDegrees,
                                          Date().addingTimeInterval(-1 * 60 * 60) as NSDate) // 1시간 TTL

                let cachedPlaces = realm.objects(PlaceRealmObject.self).filter(predicate)
                let places = Array(cachedPlaces).map { $0.toDomain() }
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
                let predicate = NSPredicate(format: "contentId == %@ AND cachedAt > %@",
                                          contentId,
                                          Date().addingTimeInterval(-7 * 24 * 60 * 60) as NSDate) // 7일 TTL

                if let cachedPlace = realm.objects(PlaceRealmObject.self).filter(predicate).first {
                    observer(.success(cachedPlace.toDomain()))
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
                    let realmObject = PlaceRealmObject()
                    realmObject.configure(from: place)
                    realmObject.cachedAt = Date()
                    realm.add(realmObject, update: .modified)
                }
                observer(.completed)
            } catch {
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
                let predicate = NSPredicate(format: "cacheKey == %@ AND cachedAt > %@",
                                          key,
                                          Date().addingTimeInterval(-ttl) as NSDate)

                let hasValidCache = realm.objects(CacheMetadataRealmObject.self).filter(predicate).count > 0
                observer(.success(hasValidCache))
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
                    let expiredDate = Date().addingTimeInterval(-7 * 24 * 60 * 60) as NSDate // 7일 전

                    let expiredFestivals = realm.objects(FestivalRealmObject.self)
                        .filter("cachedAt < %@", expiredDate)
                    realm.delete(expiredFestivals)

                    let expiredPlaces = realm.objects(PlaceRealmObject.self)
                        .filter("cachedAt < %@", expiredDate)
                    realm.delete(expiredPlaces)

                    let expiredMetadata = realm.objects(CacheMetadataRealmObject.self)
                        .filter("cachedAt < %@", expiredDate)
                    realm.delete(expiredMetadata)
                }
                observer(.completed)
            } catch {
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
                    realm.delete(realm.objects(FestivalRealmObject.self))
                    realm.delete(realm.objects(PlaceRealmObject.self))
                    realm.delete(realm.objects(CacheMetadataRealmObject.self))
                }
                observer(.completed)
            } catch {
                observer(.error(DataSourceError.cacheError))
            }

            return Disposables.create()
        }
        .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .background))
    }
}

// MARK: - Realm Objects (Temporary placeholders)
class FestivalRealmObject: Object {
    @Persisted var contentId: String = ""
    @Persisted var title: String = ""
    @Persisted var address: String = ""
    @Persisted var imageURL: String? = nil
    @Persisted var eventStartDate: String = ""
    @Persisted var eventEndDate: String = ""
    @Persisted var tel: String? = nil
    @Persisted var mapX: Double = 0.0
    @Persisted var mapY: Double = 0.0
    @Persisted var overview: String? = nil
    @Persisted var cachedAt: Date = Date()

    override static func primaryKey() -> String? {
        return "contentId"
    }

    func configure(from festival: Festival) {
        self.contentId = festival.contentId
        self.title = festival.title
        self.address = festival.address
        self.imageURL = festival.imageURL
        self.eventStartDate = festival.eventStartDate
        self.eventEndDate = festival.eventEndDate
        self.tel = festival.tel
        self.mapX = festival.mapX ?? 0.0
        self.mapY = festival.mapY ?? 0.0
        self.overview = festival.overview
    }

    func toDomain() -> Festival {
        return Festival(
            contentId: self.contentId,
            title: self.title,
            address: self.address,
            imageURL: self.imageURL,
            eventStartDate: self.eventStartDate,
            eventEndDate: self.eventEndDate,
            tel: self.tel,
            mapX: self.mapX == 0.0 ? nil : self.mapX,
            mapY: self.mapY == 0.0 ? nil : self.mapY,
            overview: self.overview
        )
    }
}

class PlaceRealmObject: Object {
    @Persisted var contentId: String = ""
    @Persisted var title: String = ""
    @Persisted var address: String = ""
    @Persisted var imageURL: String? = nil
    @Persisted var mapX: Double = 0.0
    @Persisted var mapY: Double = 0.0
    @Persisted var tel: String? = nil
    @Persisted var overview: String? = nil
    @Persisted var contentTypeId: Int = 0
    @Persisted var distance: Int = 0
    @Persisted var areaCode: Int = 0
    @Persisted var sigunguCode: Int = 0
    @Persisted var cat1: String? = nil
    @Persisted var cat2: String? = nil
    @Persisted var cat3: String? = nil
    @Persisted var cachedAt: Date = Date()

    override static func primaryKey() -> String? {
        return "contentId"
    }

    func configure(from place: Place) {
        self.contentId = place.contentId
        self.title = place.title
        self.address = place.address
        self.imageURL = place.imageURL
        self.mapX = place.mapX ?? 0.0
        self.mapY = place.mapY ?? 0.0
        self.tel = place.tel
        self.overview = place.overview
        self.contentTypeId = place.contentTypeId
        self.distance = place.distance ?? 0
    }

    func toDomain() -> Place {
        return Place(
            contentId: self.contentId,
            title: self.title,
            address: self.address,
            imageURL: self.imageURL,
            mapX: self.mapX == 0.0 ? nil : self.mapX,
            mapY: self.mapY == 0.0 ? nil : self.mapY,
            tel: self.tel,
            overview: self.overview,
            contentTypeId: self.contentTypeId,
            areaCode: self.areaCode,
            sigunguCode: self.sigunguCode,
            cat1: self.cat1,
            cat2: self.cat2,
            cat3: self.cat3,
            distance: self.distance == 0 ? nil : self.distance
        )
    }
}

class CacheMetadataRealmObject: Object {
    @Persisted var cacheKey: String = ""
    @Persisted var cachedAt: Date = Date()

    override static func primaryKey() -> String? {
        return "cacheKey"
    }
}
