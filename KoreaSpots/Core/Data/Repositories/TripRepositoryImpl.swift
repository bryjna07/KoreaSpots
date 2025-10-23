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
        // Mock 모드에서는 쓰기 작업 차단
        guard AppStateManager.shared.canPerformWriteOperation() else {
            return .error(TripRepositoryError.writeOperationBlocked)
        }
        return localDataSource.saveTrip(trip)
    }

    func getTrip(id: String) -> Single<Trip?> {
        // 읽기 작업은 항상 허용 (유저가 작성한 기존 데이터)
        return localDataSource.getTrip(id: id)
    }

    func getAllTrips(sortedBy sortOption: TripSortOption) -> Single<[Trip]> {
        // 읽기 작업은 항상 허용
        return localDataSource.getAllTrips(sortedBy: sortOption)
    }

    func getTrips(forMonth month: Date) -> Single<[Trip]> {
        // 읽기 작업은 항상 허용
        return localDataSource.getTrips(forMonth: month)
    }

    func updateTrip(_ trip: Trip) -> Completable {
        // Mock 모드에서는 쓰기 작업 차단
        guard AppStateManager.shared.canPerformWriteOperation() else {
            return .error(TripRepositoryError.writeOperationBlocked)
        }
        return localDataSource.updateTrip(trip)
    }

    func deleteTrip(id: String) -> Completable {
        // Mock 모드에서는 쓰기 작업 차단
        guard AppStateManager.shared.canPerformWriteOperation() else {
            return .error(TripRepositoryError.writeOperationBlocked)
        }
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

// MARK: - Repository Errors
enum TripRepositoryError: Error, LocalizedError {
    case writeOperationBlocked  // Mock 모드에서 쓰기 작업 차단
    case notFound
    case unknown

    var errorDescription: String? {
        switch self {
        case .writeOperationBlocked:
            return "현재 서버 오류로 인해\n예시 데이터를 표시 중입니다.\n\n예시 데이터 사용 중에는\n이 기능을 사용할 수 없습니다."
        case .notFound:
            return "여행 기록을 찾을 수 없습니다."
        case .unknown:
            return "알 수 없는 오류가 발생했습니다."
        }
    }
}
