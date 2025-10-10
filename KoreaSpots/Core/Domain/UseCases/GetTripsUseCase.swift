//
//  GetTripsUseCase.swift
//  KoreaSpots
//
//  Created by YoungJin on 10/10/25.
//

import Foundation
import RxSwift

// MARK: - UseCase Protocol
protocol GetTripsUseCase {
    func execute(sortedBy sortOption: TripSortOption) -> Single<[Trip]>
    func execute(forMonth month: Date) -> Single<[Trip]>
}

// MARK: - UseCase Implementation
final class GetTripsUseCaseImpl: GetTripsUseCase {
    private let tripRepository: TripRepository

    init(tripRepository: TripRepository) {
        self.tripRepository = tripRepository
    }

    func execute(sortedBy sortOption: TripSortOption) -> Single<[Trip]> {
        return tripRepository.getAllTrips(sortedBy: sortOption)
    }

    func execute(forMonth month: Date) -> Single<[Trip]> {
        return tripRepository.getTrips(forMonth: month)
    }
}
