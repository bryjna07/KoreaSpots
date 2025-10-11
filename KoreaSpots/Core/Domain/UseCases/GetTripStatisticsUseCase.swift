//
//  GetTripStatisticsUseCase.swift
//  KoreaSpots
//
//  Created by YoungJin on 10/10/25.
//

import Foundation
import RxSwift

// MARK: - UseCase Protocol
protocol GetTripStatisticsUseCase {
    func execute() -> Single<TripStatistics>
}

// MARK: - UseCase Implementation
final class GetTripStatisticsUseCaseImpl: GetTripStatisticsUseCase {
    private let tripRepository: TripRepository

    init(tripRepository: TripRepository) {
        self.tripRepository = tripRepository
    }

    func execute() -> Single<TripStatistics> {
        return tripRepository.getTripStatistics()
    }
}
