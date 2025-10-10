//
//  TripLocalDataSource.swift
//  KoreaSpots
//
//  Created by YoungJin on 10/10/25.
//

import Foundation
import RxSwift

protocol TripLocalDataSource {
    // MARK: - Trip CRUD
    func saveTrip(_ trip: Trip) -> Single<Trip>
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
