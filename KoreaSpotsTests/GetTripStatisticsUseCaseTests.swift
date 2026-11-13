//
//  GetTripStatisticsUseCaseTests.swift
//  KoreaSpotsTests
//

import Testing
import RxSwift
@testable import KoreaSpots

struct GetTripStatisticsUseCaseTests {

    @Test func returnsRepositoryStatistics() async throws {
        let repository = StubTripRepository()
        let expected = TripStatistics(totalTripCount: 3, totalPlaceCount: 12, mostVisitedAreas: [])
        repository.statisticsResult = .just(expected)
        let sut = GetTripStatisticsUseCaseImpl(tripRepository: repository)

        let result = try await sut.execute().awaitResult().get()

        #expect(result == expected)
        #expect(repository.statisticsCallCount == 1)
    }

    @Test func propagatesRepositoryError() async {
        let repository = StubTripRepository()
        repository.statisticsResult = .error(StubTripRepository.StubError.unused)
        let sut = GetTripStatisticsUseCaseImpl(tripRepository: repository)

        let result = await sut.execute().awaitResult()

        guard case .failure = result else {
            Issue.record("에러가 전달되어야 함")
            return
        }
    }
}
