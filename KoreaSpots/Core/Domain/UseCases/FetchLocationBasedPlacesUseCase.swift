//
//  FetchLocationBasedPlacesUseCase.swift
//  KoreaSpots
//
//  Created by YoungJin on 9/25/25.
//

import Foundation
import RxSwift

// MARK: - UseCase Input/Output Models
struct FetchLocationBasedPlacesInput {
    let latitude: Double
    let longitude: Double
    let radius: Int?
    let contentTypeId: Int?  // 12: 관광지, 14: 문화시설, 15: 축제, 38: 쇼핑, 39: 음식점
    let maxCount: Int?
    let sortOption: PlaceSortOption?
}

enum PlaceSortOption {
    case distance    // 거리순
    case title       // 제목순

    var arrangeCode: String {
        switch self {
        case .distance: return "S"
        case .title: return "O"
        }
    }
}

protocol FetchLocationBasedPlacesUseCase {
    func execute(_ input: FetchLocationBasedPlacesInput) -> Single<[Place]>
}

final class FetchLocationBasedPlacesUseCaseImpl: FetchLocationBasedPlacesUseCase {

    private let tourRepository: TourRepository

    // MARK: - Business Policy Constants
    private let defaultRadius = 1000          // 1km
    private let minRadius = 500               // 최소 500m
    private let maxRadius = 20000            // 최대 20km
    private let radiusExpansionStep = 2000   // 결과 없을 때 2km씩 확장
    private let maxRadiusExpansions = 3      // 최대 3회 확장
    private let defaultMaxCount = 20
    private let maxAllowedCount = 100
    private let minResultsThreshold = 5      // 최소 결과 개수 임계값

    init(tourRepository: TourRepository) {
        self.tourRepository = tourRepository
    }

    func execute(_ input: FetchLocationBasedPlacesInput) -> Single<[Place]> {
        // MARK: - Input Validation & Normalization
        return validateAndNormalize(input)
            .flatMap { [weak self] normalizedInput -> Single<[Place]> in
                guard let self = self else { return .just([]) }

                // MARK: - Auto Radius Expansion Strategy
                return self.fetchWithRadiusExpansion(
                    latitude: normalizedInput.latitude,
                    longitude: normalizedInput.longitude,
                    initialRadius: normalizedInput.radius,
                    contentTypeId: normalizedInput.contentTypeId,
                    maxCount: normalizedInput.maxCount,
                    sortOption: normalizedInput.sortOption
                )
            }
    }

    // MARK: - Private Business Logic
    private func validateAndNormalize(_ input: FetchLocationBasedPlacesInput) -> Single<(latitude: Double, longitude: Double, radius: Int, contentTypeId: Int?, maxCount: Int, sortOption: PlaceSortOption)> {
        return Single.create { observer in
            // 좌표 검증 (한국 영역)
            let latitude = input.latitude
            let longitude = input.longitude

            guard self.isValidKoreanCoordinate(latitude: latitude, longitude: longitude) else {
                observer(.failure(UseCaseError.invalidLocation))
                return Disposables.create()
            }

            // 반경 검증 및 정규화
            let radius = max(min(input.radius ?? self.defaultRadius, self.maxRadius), self.minRadius)

            // 개수 검증 및 정규화
            let maxCount = min(input.maxCount ?? self.defaultMaxCount, self.maxAllowedCount)
            guard maxCount > 0 else {
                observer(.failure(UseCaseError.invalidCount))
                return Disposables.create()
            }

            let sortOption = input.sortOption ?? .distance
            let contentTypeId = input.contentTypeId

            observer(.success((latitude: latitude, longitude: longitude, radius: radius, contentTypeId: contentTypeId, maxCount: maxCount, sortOption: sortOption)))
            return Disposables.create()
        }
    }

    private func fetchWithRadiusExpansion(
        latitude: Double,
        longitude: Double,
        initialRadius: Int,
        contentTypeId: Int?,
        maxCount: Int,
        sortOption: PlaceSortOption
    ) -> Single<[Place]> {

        return fetchPlaces(
            latitude: latitude,
            longitude: longitude,
            radius: initialRadius,
            contentTypeId: contentTypeId,
            maxCount: maxCount,
            sortOption: sortOption,
            attempt: 1
        )
    }

    private func fetchPlaces(
        latitude: Double,
        longitude: Double,
        radius: Int,
        contentTypeId: Int?,
        maxCount: Int,
        sortOption: PlaceSortOption,
        attempt: Int
    ) -> Single<[Place]> {

        return tourRepository
            .getLocationBasedPlaces(
                mapX: longitude, // API에서 mapX는 경도
                mapY: latitude,  // mapY는 위도
                radius: radius,
                contentTypeId: contentTypeId,
                numOfRows: maxCount,
                pageNo: 1,
                arrange: sortOption.arrangeCode
            )
            .map { [weak self] places -> [Place] in
                guard let self = self else { return places }
                return self.applyBusinessFilters(places, userLocation: (latitude, longitude))
            }
            .flatMap { [weak self] filteredPlaces -> Single<[Place]> in
                guard let self = self else { return .just(filteredPlaces) }

                // 결과가 충분하고, 최대 확장 시도에 도달하지 않았으면 반경 확장 시도
                if filteredPlaces.count < self.minResultsThreshold &&
                   attempt <= self.maxRadiusExpansions &&
                   radius < self.maxRadius {

                    let expandedRadius = min(radius + self.radiusExpansionStep, self.maxRadius)
                    print("🔍 Auto-expanding search radius: \(radius)m → \(expandedRadius)m (attempt \(attempt + 1))")

                    return self.fetchPlaces(
                        latitude: latitude,
                        longitude: longitude,
                        radius: expandedRadius,
                        contentTypeId: contentTypeId,
                        maxCount: maxCount,
                        sortOption: sortOption,
                        attempt: attempt + 1
                    )
                }

                return .just(filteredPlaces)
            }
    }

    private func applyBusinessFilters(_ places: [Place], userLocation: (latitude: Double, longitude: Double)) -> [Place] {
        return places
            .filter { place in
                // 블랙리스트 필터링 및 기본 검증
                !self.isBlacklisted(place) && !place.title.isEmpty
            }
            .removingDuplicates() // 중복 제거
            .map { place -> Place in
                // 캐시된 distance는 저장 당시 요청 위치 기준이므로 현재 위치 기준으로 다시 계산
                guard let lat = place.mapY, let lon = place.mapX else { return place }
                var updated = place
                updated.distance = Int(self.calculateDistance(from: userLocation, to: (latitude: lat, longitude: lon)).rounded())
                return updated
            }
            .sorted { (first: Place, second: Place) -> Bool in
                // 영업중인 장소 우선, 그 다음 거리순
                let firstOpen = self.isCurrentlyOpen(first)
                let secondOpen = self.isCurrentlyOpen(second)

                if firstOpen != secondOpen {
                    return firstOpen
                }

                // 거리로 2차 정렬
                let firstHasCoords = first.mapY != nil && first.mapX != nil
                let secondHasCoords = second.mapY != nil && second.mapX != nil

                // 좌표가 있는 장소를 우선 정렬
                if firstHasCoords != secondHasCoords {
                    return firstHasCoords
                }

                // 둘 다 좌표가 있는 경우에만 거리 비교
                guard let firstLat = first.mapY, let firstLon = first.mapX,
                      let secondLat = second.mapY, let secondLon = second.mapX else {
                    return false // 둘 다 좌표가 없으면 순서 유지
                }

                let firstDistance = self.calculateDistance(
                    from: userLocation,
                    to: (latitude: firstLat, longitude: firstLon)
                )
                let secondDistance = self.calculateDistance(
                    from: userLocation,
                    to: (latitude: secondLat, longitude: secondLon)
                )

                return firstDistance < secondDistance
            }
    }

    private func isBlacklisted(_ place: Place) -> Bool {
        let blacklistedKeywords = ["성인", "19금", "adult", "폐업"]
        let title = place.title.lowercased()
        return blacklistedKeywords.contains { title.contains($0) }
    }

    private func isCurrentlyOpen(_ place: Place) -> Bool {
        // 영업시간 정보가 있다면 현재 시간과 비교
        // 임시로 항상 true 반환 (실제로는 place.operatingHours 정보 활용)
        return true
    }

    private func calculateDistance(from: (latitude: Double, longitude: Double), to: (latitude: Double, longitude: Double)) -> Double {
        let earthRadius = 6371000.0 // 지구 반지름 (미터)

        let lat1Rad = from.latitude * .pi / 180
        let lat2Rad = to.latitude * .pi / 180
        let deltaLatRad = (to.latitude - from.latitude) * .pi / 180
        let deltaLonRad = (to.longitude - from.longitude) * .pi / 180

        let a = sin(deltaLatRad/2) * sin(deltaLatRad/2) +
                cos(lat1Rad) * cos(lat2Rad) *
                sin(deltaLonRad/2) * sin(deltaLonRad/2)
        let c = 2 * atan2(sqrt(a), sqrt(1-a))

        return earthRadius * c
    }

    private func isValidKoreanCoordinate(latitude: Double, longitude: Double) -> Bool {
        // 대한민국 영역 대략적 좌표 범위
        let latRange = 33.0...39.0
        let lonRange = 124.0...132.0

        return latRange.contains(latitude) && lonRange.contains(longitude)
    }
}

// MARK: - Array Extension for Deduplication
private extension Array where Element == Place {
    func removingDuplicates() -> [Place] {
        var seen: Set<String> = []
        return filter { place in
            let key = "\(place.contentId)-\(place.title)"
            if seen.contains(key) {
                return false
            } else {
                seen.insert(key)
                return true
            }
        }
    }
}
