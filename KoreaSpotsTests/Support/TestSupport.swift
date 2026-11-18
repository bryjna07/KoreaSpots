//
//  TestSupport.swift
//  KoreaSpotsTests
//

import Foundation
import RxSwift
@testable import KoreaSpots

// MARK: - Single -> async 변환
extension PrimitiveSequence where Trait == SingleTrait {
    /// Single의 결과를 async로 받아 테스트에서 await 할 수 있게 한다
    func awaitResult() async -> Result<Element, Error> {
        await withCheckedContinuation { continuation in
            _ = self.subscribe(
                onSuccess: { continuation.resume(returning: .success($0)) },
                onFailure: { continuation.resume(returning: .failure($0)) }
            )
        }
    }
}

// MARK: - Place 팩토리
enum PlaceFixture {
    static func make(
        id: String,
        title: String = "장소",
        lat: Double? = nil,
        lon: Double? = nil,
        distance: Int? = nil
    ) -> Place {
        Place(
            contentId: id,
            title: title,
            address: "",
            imageURL: nil,
            mapX: lon,
            mapY: lat,
            tel: nil,
            overview: nil,
            contentTypeId: 12,
            areaCode: nil,
            sigunguCode: nil,
            distance: distance,
            modifiedTime: nil,
            eventMeta: nil,
            isCustom: false,
            customPlaceId: nil,
            userProvidedImagePath: nil
        )
    }
}

// MARK: - TourRepository Stub
/// getLocationBasedPlaces만 구현한 스텁. 호출 인자를 기록하고 정해진 응답을 반환한다
final class StubTourRepository: TourRepository {
    struct LocationCall: Equatable {
        let radius: Int
        let numOfRows: Int
        let arrange: String
    }

    var locationResult: Single<[Place]> = .just([])
    private(set) var locationCalls: [LocationCall] = []

    func getLocationBasedPlaces(mapX: Double, mapY: Double, radius: Int, contentTypeId: Int?, numOfRows: Int, pageNo: Int, arrange: String) -> Single<[Place]> {
        locationCalls.append(LocationCall(radius: radius, numOfRows: numOfRows, arrange: arrange))
        return locationResult
    }

    // MARK: 사용하지 않는 메서드
    private enum StubError: Error { case unused }

    func getFestivals(eventStartDate: String, eventEndDate: String, areaCode: Int?, numOfRows: Int, pageNo: Int, arrange: String) -> Single<[Place]> { .error(StubError.unused) }
    func getAreaBasedPlaces(areaCode: Int?, sigunguCode: Int?, contentTypeId: Int?, cat1: String?, cat2: String?, cat3: String?, numOfRows: Int, pageNo: Int, arrange: String) -> Single<[Place]> { .error(StubError.unused) }
    func searchPlacesByKeyword(keyword: String, areaCode: Int?, sigunguCode: Int?, contentTypeId: Int?, cat1: String?, cat2: String?, cat3: String?, numOfRows: Int, pageNo: Int, arrange: String) -> Single<[Place]> { .error(StubError.unused) }
    func getPlaceDetail(contentId: String) -> Single<Place> { .error(StubError.unused) }
    func getPlaceOperatingInfo(contentId: String, contentTypeId: Int) -> Single<OperatingInfo> { .error(StubError.unused) }
    func getPlaceImages(contentId: String) -> Single<[PlaceImage]> { .error(StubError.unused) }
    func getTravelCourseDetails(contentId: String, contentTypeId: Int) -> Single<[CourseDetail]> { .error(StubError.unused) }
}

// MARK: - TripRepository Stub
/// getTripStatistics만 구현한 스텁
final class StubTripRepository: TripRepository {
    var statisticsResult: Single<TripStatistics> = .error(StubError.unused)
    private(set) var statisticsCallCount = 0

    func getTripStatistics() -> Single<TripStatistics> {
        statisticsCallCount += 1
        return statisticsResult
    }

    // MARK: 사용하지 않는 메서드
    enum StubError: Error { case unused }

    func createTrip(_ trip: Trip) -> Single<Trip> { .error(StubError.unused) }
    func getTrip(id: String) -> Single<Trip?> { .error(StubError.unused) }
    func getAllTrips(sortedBy sortOption: TripSortOption) -> Single<[Trip]> { .error(StubError.unused) }
    func getTrips(forMonth month: Date) -> Single<[Trip]> { .error(StubError.unused) }
    func updateTrip(_ trip: Trip) -> Completable { .error(StubError.unused) }
    func deleteTrip(id: String) -> Completable { .error(StubError.unused) }
    func getVisitedAreasSummary() -> Single<[VisitedArea]> { .error(StubError.unused) }
    func syncVisitIndex(for trip: Trip) -> Completable { .error(StubError.unused) }
    func deleteVisitIndex(for tripId: String) -> Completable { .error(StubError.unused) }
}
