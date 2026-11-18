//
//  FetchLocationBasedPlacesUseCaseTests.swift
//  KoreaSpotsTests
//

import Testing
import RxSwift
@testable import KoreaSpots

struct FetchLocationBasedPlacesUseCaseTests {

    // 서울시청
    private let lat = 37.5665
    private let lon = 126.9780

    private func makeSUT(returning places: [Place] = []) -> (FetchLocationBasedPlacesUseCaseImpl, StubTourRepository) {
        let repository = StubTourRepository()
        repository.locationResult = .just(places)
        return (FetchLocationBasedPlacesUseCaseImpl(tourRepository: repository), repository)
    }

    private func input(radius: Int? = nil, maxCount: Int? = nil, lat: Double? = nil, lon: Double? = nil) -> FetchLocationBasedPlacesInput {
        FetchLocationBasedPlacesInput(
            latitude: lat ?? self.lat,
            longitude: lon ?? self.lon,
            radius: radius,
            contentTypeId: 12,
            maxCount: maxCount,
            sortOption: nil
        )
    }

    /// 임계값(5개) 이상이라 반경 확장이 일어나지 않는 장소 목록
    private func enoughPlaces() -> [Place] {
        (0..<5).map { PlaceFixture.make(id: "\($0)", title: "장소\($0)", lat: lat + Double($0) * 0.001, lon: lon) }
    }

    // MARK: - Distance (#21 회귀)
    @Test func recomputesDistanceFromCurrentLocation() async {
        // 캐시에 이전 위치 기준 거리(99999m)가 저장된 상황
        var places = enoughPlaces()
        places[0] = PlaceFixture.make(id: "0", title: "시청", lat: lat, lon: lon, distance: 99999)
        let (sut, _) = makeSUT(returning: places)

        let result = await sut.execute(input()).awaitResult()
        let first = try? result.get().first(where: { $0.contentId == "0" })

        #expect(first?.distance == 0)
    }

    @Test func sortsByDistanceAscending() async throws {
        let places = [
            PlaceFixture.make(id: "far", title: "먼곳", lat: lat + 0.02, lon: lon),
            PlaceFixture.make(id: "near", title: "가까운곳", lat: lat + 0.001, lon: lon),
            PlaceFixture.make(id: "mid", title: "중간", lat: lat + 0.01, lon: lon),
            PlaceFixture.make(id: "a", title: "가", lat: lat + 0.015, lon: lon),
            PlaceFixture.make(id: "b", title: "나", lat: lat + 0.005, lon: lon)
        ]
        let (sut, _) = makeSUT(returning: places)

        let ids = try await sut.execute(input()).awaitResult().get().map(\.contentId)

        #expect(ids == ["near", "b", "mid", "a", "far"])
    }

    // MARK: - Filters
    @Test func filtersBlacklistedAndEmptyTitles() async throws {
        var places = enoughPlaces()
        places.append(PlaceFixture.make(id: "x1", title: "성인 용품점", lat: lat, lon: lon))
        places.append(PlaceFixture.make(id: "x2", title: "ADULT shop", lat: lat, lon: lon))
        places.append(PlaceFixture.make(id: "x3", title: "폐업한 식당", lat: lat, lon: lon))
        places.append(PlaceFixture.make(id: "x4", title: "", lat: lat, lon: lon))
        let (sut, _) = makeSUT(returning: places)

        let ids = try await sut.execute(input()).awaitResult().get().map(\.contentId)

        #expect(ids.count == 5)
        #expect(!ids.contains(where: { $0.hasPrefix("x") }))
    }

    @Test func removesDuplicates() async throws {
        let places = enoughPlaces() + enoughPlaces()
        let (sut, _) = makeSUT(returning: places)

        let result = try await sut.execute(input()).awaitResult().get()

        #expect(result.count == 5)
    }

    // MARK: - Validation
    @Test func rejectsCoordinateOutsideKorea() async {
        let (sut, repository) = makeSUT()

        let result = await sut.execute(input(lat: 48.8566, lon: 2.3522)).awaitResult() // 파리

        guard case .failure(let error) = result, case UseCaseError.invalidLocation = error else {
            Issue.record("invalidLocation 에러가 와야 함: \(result)")
            return
        }
        #expect(repository.locationCalls.isEmpty)
    }

    @Test func rejectsZeroMaxCount() async {
        let (sut, repository) = makeSUT()

        let result = await sut.execute(input(maxCount: 0)).awaitResult()

        guard case .failure(let error) = result, case UseCaseError.invalidCount = error else {
            Issue.record("invalidCount 에러가 와야 함: \(result)")
            return
        }
        #expect(repository.locationCalls.isEmpty)
    }

    @Test func clampsRadiusAndCount() async {
        let (sut, repository) = makeSUT(returning: enoughPlaces())

        _ = await sut.execute(input(radius: 100, maxCount: 500)).awaitResult()
        _ = await sut.execute(input(radius: 50000)).awaitResult()

        #expect(repository.locationCalls[0].radius == 500)       // 최소 500m
        #expect(repository.locationCalls[0].numOfRows == 100)    // 최대 100개
        #expect(repository.locationCalls[1].radius == 20000)     // 최대 20km
        #expect(repository.locationCalls[1].numOfRows == 20)     // 기본 20개
    }

    // MARK: - Radius expansion
    @Test func expandsRadiusWhenResultsAreSparse() async throws {
        let (sut, repository) = makeSUT(returning: [PlaceFixture.make(id: "1", title: "하나", lat: lat, lon: lon)])

        let result = try await sut.execute(input()).awaitResult().get()

        // 1000 -> 3000 -> 5000 -> 7000 (최초 1회 + 확장 3회)
        #expect(repository.locationCalls.map(\.radius) == [1000, 3000, 5000, 7000])
        #expect(result.count == 1)
    }

    @Test func doesNotExpandWhenResultsAreEnough() async {
        let (sut, repository) = makeSUT(returning: enoughPlaces())

        _ = await sut.execute(input()).awaitResult()

        #expect(repository.locationCalls.count == 1)
    }

    @Test func passesArrangeCodeToRepository() async {
        let (sut, repository) = makeSUT(returning: enoughPlaces())

        _ = await sut.execute(input()).awaitResult()

        #expect(repository.locationCalls.first?.arrange == "S") // 기본 정렬: 거리순
    }
}
