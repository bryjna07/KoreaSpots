//
//  ManageTripUseCase.swift
//  KoreaSpots
//
//  Created by YoungJin on 10/10/25.
//

import Foundation
import RxSwift

// MARK: - Create Trip UseCase
protocol CreateTripUseCase {
    func execute(_ trip: Trip) -> Single<Trip>
}

final class CreateTripUseCaseImpl: CreateTripUseCase {
    private let tripRepository: TripRepository

    init(tripRepository: TripRepository) {
        self.tripRepository = tripRepository
    }

    func execute(_ trip: Trip) -> Single<Trip> {
        // Validation
        guard !trip.title.isEmpty else {
            return .error(TripValidationError.emptyTitle)
        }

        guard trip.endDate >= trip.startDate else {
            return .error(TripValidationError.invalidDateRange)
        }

        guard !trip.visitedPlaces.isEmpty else {
            return .error(TripValidationError.noVisitedPlaces)
        }

        return tripRepository.createTrip(trip)
            .andThen(tripRepository.syncVisitIndex(for: trip))
            .andThen(.just(trip))
    }
}

// MARK: - Update Trip UseCase
protocol UpdateTripUseCase {
    func execute(_ trip: Trip) -> Completable
}

final class UpdateTripUseCaseImpl: UpdateTripUseCase {
    private let tripRepository: TripRepository

    init(tripRepository: TripRepository) {
        self.tripRepository = tripRepository
    }

    func execute(_ trip: Trip) -> Completable {
        // Validation
        guard !trip.title.isEmpty else {
            return .error(TripValidationError.emptyTitle)
        }

        guard trip.endDate >= trip.startDate else {
            return .error(TripValidationError.invalidDateRange)
        }

        guard !trip.visitedPlaces.isEmpty else {
            return .error(TripValidationError.noVisitedPlaces)
        }

        return tripRepository.updateTrip(trip)
            .andThen(tripRepository.syncVisitIndex(for: trip))
    }
}

// MARK: - Delete Trip UseCase
protocol DeleteTripUseCase {
    func execute(tripId: String) -> Completable
}

final class DeleteTripUseCaseImpl: DeleteTripUseCase {
    private let tripRepository: TripRepository

    init(tripRepository: TripRepository) {
        self.tripRepository = tripRepository
    }

    func execute(tripId: String) -> Completable {
        return tripRepository.deleteVisitIndex(for: tripId)
            .andThen(tripRepository.deleteTrip(id: tripId))
    }
}

// MARK: - Validation Errors
enum TripValidationError: Error, LocalizedError {
    case emptyTitle
    case invalidDateRange
    case noVisitedPlaces

    var errorDescription: String? {
        switch self {
        case .emptyTitle:
            return "여행 제목을 입력해주세요."
        case .invalidDateRange:
            return "종료일은 시작일 이후여야 합니다."
        case .noVisitedPlaces:
            return "최소 1개 이상의 관광지를 추가해주세요."
        }
    }
}
