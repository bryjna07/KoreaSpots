//
//  TripRepository.swift
//  KoreaSpots
//
//  Created by YoungJin on 10/10/25.
//

import Foundation
import RxSwift

protocol TripRepository {
    // MARK: - CRUD
    func createTrip(_ trip: Trip) -> Completable
    func getTrip(id: String) -> Single<Trip?>
    func getAllTrips(sortedBy sortOption: TripSortOption) -> Single<[Trip]>
    func getTrips(forMonth month: Date) -> Single<[Trip]>
    func updateTrip(_ trip: Trip) -> Completable
    func deleteTrip(id: String) -> Completable

    // MARK: - Statistics
    func getTripStatistics() -> Single<TripStatistics>
    func getVisitedAreasSummary() -> Single<[VisitedArea]>

    // MARK: - Visit Index
    func syncVisitIndex(for trip: Trip) -> Completable
    func deleteVisitIndex(for tripId: String) -> Completable
}

// MARK: - Sort Options
enum TripSortOption {
    case newest        // 최신순
    case oldest        // 오래된순
    case titleAsc      // 제목 오름차순
}
