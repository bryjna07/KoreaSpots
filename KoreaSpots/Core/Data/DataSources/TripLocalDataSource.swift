//
//  TripLocalDataSource.swift
//  KoreaSpots
//
//  Created by YoungJin on 10/10/25.
//

import Foundation
import RxSwift
import RealmSwift

// MARK: - Protocol
protocol TripLocalDataSource {
    // MARK: - Trip CRUD
    func saveTrip(_ trip: Trip) -> Completable
    func getTrip(id: String) -> Single<Trip?>
    func getAllTrips(sortedBy sortOption: TripSortOption) -> Single<[Trip]>
    func getTrips(forMonth month: Date) -> Single<[Trip]>
    func updateTrip(_ trip: Trip) -> Completable
    func deleteTrip(id: String) -> Completable

    // MARK: - Statistics
    func getTripCount() -> Single<Int>
    func getTotalPlaceCount() -> Single<Int>
    func getVisitedAreasSummary() -> Single<[VisitedArea]>

    // MARK: - Visit Index
    func saveVisitIndices(for trip: Trip) -> Completable
    func deleteVisitIndices(for tripId: String) -> Completable
}

// MARK: - Implementation
final class TripLocalDataSourceImpl: TripLocalDataSource {
    private let realmProvider: () -> Realm

    init(realmProvider: @escaping () -> Realm = { try! Realm() }) {
        self.realmProvider = realmProvider
    }

    // MARK: - Trip CRUD

    func saveTrip(_ trip: Trip) -> Completable {
        return Completable.create { [weak self] observer in
            guard let self = self else {
                observer(.completed)
                return Disposables.create()
            }

            do {
                let realm = self.realmProvider()
                let tripR = TripR(from: trip)

                try realm.write {
                    realm.add(tripR, update: .modified)
                }

                print("✅ Trip saved: \(trip.title)")
                observer(.completed)
            } catch {
                print("❌ Failed to save trip: \(error)")
                observer(.error(error))
            }

            return Disposables.create()
        }
        .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .background))
    }

    func getTrip(id: String) -> Single<Trip?> {
        return Single.create { [weak self] observer in
            guard let self = self else {
                observer(.success(nil))
                return Disposables.create()
            }

            do {
                let realm = self.realmProvider()
                let objectId = try ObjectId(string: id)

                if let tripR = realm.object(ofType: TripR.self, forPrimaryKey: objectId) {
                    observer(.success(tripR.toDomain()))
                } else {
                    observer(.success(nil))
                }
            } catch {
                print("❌ Failed to get trip: \(error)")
                observer(.error(error))
            }

            return Disposables.create()
        }
        .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .background))
    }

    func getAllTrips(sortedBy sortOption: TripSortOption) -> Single<[Trip]> {
        return Single.create { [weak self] observer in
            guard let self = self else {
                observer(.success([]))
                return Disposables.create()
            }

            let realm = self.realmProvider()
            var results = realm.objects(TripR.self)

            // Apply sorting
            switch sortOption {
            case .newest:
                results = results.sorted(byKeyPath: "createdAt", ascending: false)
            case .oldest:
                results = results.sorted(byKeyPath: "createdAt", ascending: true)
            case .titleAsc:
                results = results.sorted(byKeyPath: "title", ascending: true)
            }

            let trips = Array(results).map { $0.toDomain() }
            observer(.success(trips))

            return Disposables.create()
        }
        .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .background))
    }

    func getTrips(forMonth month: Date) -> Single<[Trip]> {
        return Single.create { [weak self] observer in
            guard let self = self else {
                observer(.success([]))
                return Disposables.create()
            }

            let calendar = Calendar.current
            guard let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: month)),
                  let endOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth) else {
                observer(.success([]))
                return Disposables.create()
            }

            let realm = self.realmProvider()
            let results = realm.objects(TripR.self)
                .filter("startDate >= %@ AND startDate <= %@", startOfMonth, endOfMonth)
                .sorted(byKeyPath: "startDate", ascending: false)

            let trips = Array(results).map { $0.toDomain() }
            observer(.success(trips))

            return Disposables.create()
        }
        .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .background))
    }

    func updateTrip(_ trip: Trip) -> Completable {
        return saveTrip(trip) // Upsert
    }

    func deleteTrip(id: String) -> Completable {
        return Completable.create { [weak self] observer in
            guard let self = self else {
                observer(.completed)
                return Disposables.create()
            }

            do {
                let realm = self.realmProvider()
                let objectId = try ObjectId(string: id)

                if let tripR = realm.object(ofType: TripR.self, forPrimaryKey: objectId) {
                    try realm.write {
                        realm.delete(tripR)
                    }
                    print("✅ Trip deleted: \(id)")
                }

                observer(.completed)
            } catch {
                print("❌ Failed to delete trip: \(error)")
                observer(.error(error))
            }

            return Disposables.create()
        }
        .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .background))
    }

    // MARK: - Statistics

    func getTripCount() -> Single<Int> {
        return Single.create { [weak self] observer in
            guard let self = self else {
                observer(.success(0))
                return Disposables.create()
            }

            let realm = self.realmProvider()
            let count = realm.objects(TripR.self).count
            observer(.success(count))

            return Disposables.create()
        }
        .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .background))
    }

    func getTotalPlaceCount() -> Single<Int> {
        return Single.create { [weak self] observer in
            guard let self = self else {
                observer(.success(0))
                return Disposables.create()
            }

            let realm = self.realmProvider()
            let count = realm.objects(VisitIndexR.self).count
            observer(.success(count))

            return Disposables.create()
        }
        .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .background))
    }

    func getVisitedAreasSummary() -> Single<[VisitedArea]> {
        return Single.create { [weak self] observer in
            guard let self = self else {
                observer(.success([]))
                return Disposables.create()
            }

            let realm = self.realmProvider()
            let trips = realm.objects(TripR.self)

            // Aggregate all visited areas from all trips
            var areaMap: [Int: VisitedAreaE] = [:]

            for trip in trips {
                for area in trip.visitedAreas {
                    if let existing = areaMap[area.areaCode] {
                        // Merge counts
                        let merged = VisitedAreaE()
                        merged.areaCode = area.areaCode
                        merged.sigunguCode = area.sigunguCode
                        merged.count = existing.count + area.count
                        merged.firstVisitedAt = min(existing.firstVisitedAt, area.firstVisitedAt)
                        merged.lastVisitedAt = max(existing.lastVisitedAt, area.lastVisitedAt)
                        areaMap[area.areaCode] = merged
                    } else {
                        areaMap[area.areaCode] = area
                    }
                }
            }

            let sortedAreas = areaMap.values
                .sorted { $0.count > $1.count }
                .map { $0.toDomain() }

            observer(.success(sortedAreas))

            return Disposables.create()
        }
        .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .background))
    }

    // MARK: - Visit Index

    func saveVisitIndices(for trip: Trip) -> Completable {
        return Completable.create { [weak self] observer in
            guard let self = self else {
                observer(.completed)
                return Disposables.create()
            }

            do {
                let realm = self.realmProvider()

                // Delete existing indices for this trip
                let objectId = try ObjectId(string: trip.id)
                let existingIndices = realm.objects(VisitIndexR.self).filter("tripId == %@", objectId)

                try realm.write {
                    realm.delete(existingIndices)

                    // Create new indices
                    for visitedPlace in trip.visitedPlaces {
                        let index = VisitIndexR(from: trip, visitedPlace: visitedPlace)
                        realm.add(index)
                    }
                }

                print("✅ Visit indices synced for trip: \(trip.title)")
                observer(.completed)
            } catch {
                print("❌ Failed to save visit indices: \(error)")
                observer(.error(error))
            }

            return Disposables.create()
        }
        .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .background))
    }

    func deleteVisitIndices(for tripId: String) -> Completable {
        return Completable.create { [weak self] observer in
            guard let self = self else {
                observer(.completed)
                return Disposables.create()
            }

            do {
                let realm = self.realmProvider()
                let objectId = try ObjectId(string: tripId)
                let indices = realm.objects(VisitIndexR.self).filter("tripId == %@", objectId)

                try realm.write {
                    realm.delete(indices)
                }

                print("✅ Visit indices deleted for trip: \(tripId)")
                observer(.completed)
            } catch {
                print("❌ Failed to delete visit indices: \(error)")
                observer(.error(error))
            }

            return Disposables.create()
        }
        .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .background))
    }
}
