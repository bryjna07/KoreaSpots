//
//  FetchFestivalUseCase.swift
//  KoreaSpots
//
//  Created by YoungJin on 9/25/25.
//

import Foundation
import RxSwift

// MARK: - UseCase Input/Output Models
struct FetchFestivalInput {
    let startDate: String?
    let endDate: String?
    let maxCount: Int?
    let sortOption: FestivalSortOption?
}

enum FestivalSortOption {
    case title      // 제목순
    case date       // 날짜순
    case popularity // 인기순

    var arrangeCode: String {
        switch self {
        case .title: return "A"
        case .date: return "B"
        case .popularity: return "C"
        }
    }
}

protocol FetchFestivalUseCase {
    func execute(_ input: FetchFestivalInput) -> Single<[Festival]>
}

final class FetchFestivalUseCaseImpl: FetchFestivalUseCase {

    private let tourRepository: TourRepository

    // MARK: - Business Policy Constants
    private let defaultMaxCount = 20
    private let maxAllowedCount = 100
    private let defaultSortOption: FestivalSortOption = .date

    init(tourRepository: TourRepository) {
        self.tourRepository = tourRepository
    }

    func execute(_ input: FetchFestivalInput) -> Single<[Festival]> {
        // MARK: - Input Validation & Business Rules
        return validateAndNormalize(input)
            .flatMap { [weak self] normalizedInput -> Single<[Festival]> in
                guard let self = self else { return .just([]) }

                return self.tourRepository
                    .getFestivals(
                        eventStartDate: normalizedInput.startDate,
                        eventEndDate: normalizedInput.endDate,
                        numOfRows: normalizedInput.maxCount,
                        pageNo: 1,
                        arrange: normalizedInput.sortOption.arrangeCode
                    )
                    .map { festivals in
                        // MARK: - Post-processing Business Rules
                        return self.applyBusinessFilters(festivals)
                    }
            }
    }

    // MARK: - Private Business Logic
    private func validateAndNormalize(_ input: FetchFestivalInput) -> Single<(startDate: String, endDate: String, maxCount: Int, sortOption: FestivalSortOption)> {
        return Single.create { observer in
            // 날짜 검증 및 기본값 설정
            let today = DateFormatterUtil.yyyyMMdd.string(from: Date())
            let startDate = input.startDate ?? today

            // 종료일이 없으면 시작일로부터 3개월 후
            let endDate: String
            if let inputEndDate = input.endDate {
                endDate = inputEndDate
            } else {
                let calendar = Calendar.current
                let startDateObj = DateFormatterUtil.yyyyMMdd.date(from: startDate) ?? Date()
                let threeMonthsLater = calendar.date(byAdding: .month, value: 3, to: startDateObj) ?? Date()
                endDate = DateFormatterUtil.yyyyMMdd.string(from: threeMonthsLater)
            }

            // 날짜 순서 검증
            guard let start = DateFormatterUtil.yyyyMMdd.date(from: startDate),
                  let end = DateFormatterUtil.yyyyMMdd.date(from: endDate),
                  start <= end else {
                observer(.failure(UseCaseError.invalidDateRange))
                return Disposables.create()
            }

            // 개수 검증 및 정규화
            let maxCount = min(input.maxCount ?? self.defaultMaxCount, self.maxAllowedCount)
            guard maxCount > 0 else {
                observer(.failure(UseCaseError.invalidCount))
                return Disposables.create()
            }

            let sortOption = input.sortOption ?? self.defaultSortOption

            observer(.success((startDate: startDate, endDate: endDate, maxCount: maxCount, sortOption: sortOption)))
            return Disposables.create()
        }
    }

    private func applyBusinessFilters(_ festivals: [Festival]) -> [Festival] {
        return festivals
            .filter { festival in
                // 블랙리스트 필터링 (예: 성인 콘텐츠, 금칙어 등)
                !self.isBlacklisted(festival)
            }
            .removingDuplicates() // 중복 제거
            .sorted { (first: Festival, second: Festival) -> Bool in
                // 진행중인 축제를 우선순위로
                return self.isOngoing(first) && !self.isOngoing(second)
            }
    }

    private func isBlacklisted(_ festival: Festival) -> Bool {
        let blacklistedKeywords = ["성인", "19금", "adult"]
        let title = festival.title.lowercased()
        return blacklistedKeywords.contains { title.contains($0) }
    }

    private func isOngoing(_ festival: Festival) -> Bool {
        let today = Date()
        let todayString = DateFormatterUtil.yyyyMMdd.string(from: today)

        // 문자열 날짜 비교: "yyyyMMdd" 형식이므로 문자열 비교로 충분
        return festival.eventStartDate <= todayString && festival.eventEndDate >= todayString
    }
}

// MARK: - UseCase Errors
enum UseCaseError: Error, LocalizedError {
    case invalidDateRange
    case invalidCount
    case invalidLocation
    case invalidRadius

    var errorDescription: String? {
        switch self {
        case .invalidDateRange:
            return "Invalid date range provided"
        case .invalidCount:
            return "Invalid count value"
        case .invalidLocation:
            return "Invalid location coordinates"
        case .invalidRadius:
            return "Invalid radius value"
        }
    }
}

// MARK: - Array Extension for Deduplication
private extension Array where Element == Festival {
    func removingDuplicates() -> [Festival] {
        var seen: Set<String> = []
        return filter { festival in
            let key = "\(festival.contentId)-\(festival.title)"
            if seen.contains(key) {
                return false
            } else {
                seen.insert(key)
                return true
            }
        }
    }
}
