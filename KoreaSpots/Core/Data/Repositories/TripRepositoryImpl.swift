//
//  TripRepositoryImpl.swift
//  KoreaSpots
//
//  Created by YoungJin on 10/10/25.
//

import Foundation
import RxSwift

final class TripRepositoryImpl: TripRepository {
    private let localDataSource: TripLocalDataSource

    init(localDataSource: TripLocalDataSource) {
        self.localDataSource = localDataSource
    }

    // MARK: - CRUD

    func createTrip(_ trip: Trip) -> Single<Trip> {
        return localDataSource.saveTrip(trip)
    }

    func getTrip(id: String) -> Single<Trip?> {
        return localDataSource.getTrip(id: id)
    }

    func getAllTrips(sortedBy sortOption: TripSortOption) -> Single<[Trip]> {
        return localDataSource.getAllTrips(sortedBy: sortOption)
    }

    func getTrips(forMonth month: Date) -> Single<[Trip]> {
        return localDataSource.getTrips(forMonth: month)
    }

    func updateTrip(_ trip: Trip) -> Completable {
        return localDataSource.updateTrip(trip)
    }

    func deleteTrip(id: String) -> Completable {
        return localDataSource.deleteTrip(id: id)
    }

    // MARK: - Statistics

    func getTripStatistics() -> Single<TripStatistics> {
        return Single.zip(
            localDataSource.getTripCount(),
            localDataSource.getTotalPlaceCount(),
            localDataSource.getVisitedAreasSummary()
        )
        .map { tripCount, placeCount, areas in
            let topAreas = Array(areas.prefix(3))
            return TripStatistics(
                totalTripCount: tripCount,
                totalPlaceCount: placeCount,
                mostVisitedAreas: topAreas
            )
        }
    }

    func getVisitedAreasSummary() -> Single<[VisitedArea]> {
        return localDataSource.getVisitedAreasSummary()
    }

    // MARK: - Visit Index

    func syncVisitIndex(for trip: Trip) -> Completable {
        return localDataSource.saveVisitIndices(for: trip)
    }

    func deleteVisitIndex(for tripId: String) -> Completable {
        return localDataSource.deleteVisitIndices(for: tripId)
    }
}
