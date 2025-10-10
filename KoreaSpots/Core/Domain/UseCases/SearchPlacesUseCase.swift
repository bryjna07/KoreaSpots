//
//  SearchPlacesUseCase.swift
//  KoreaSpots
//
//  Created by YoungJin on 10/09/25.
//

import Foundation
import RxSwift

// MARK: - UseCase Input Model
struct SearchPlacesInput {
    let keyword: String
    let areaCode: Int?
    let sigunguCode: Int?
    let contentTypeId: Int?
    let cat1: String?
    let cat2: String?
    let cat3: String?
    let page: Int
    let sortOption: SearchSortOption?
    let shouldSaveToRecent: Bool
}

enum SearchSortOption {
    case title       // 제목순
    case recent      // 최신순
    case popularity  // 인기순
    case distance    // 거리순 (위치 기반)

    var arrangeCode: String {
        switch self {
        case .title: return "O"      // O (가나다순)
        case .recent: return "R"     // R (최근순)
        case .popularity: return "P" // P (인기순)
        case .distance: return "S"   // S (거리순)
        }
    }
}

// MARK: - UseCase Protocol
protocol SearchPlacesUseCase {
    func execute(_ input: SearchPlacesInput) -> Single<[Place]>
}

// MARK: - UseCase Implementation
final class SearchPlacesUseCaseImpl: SearchPlacesUseCase {

    private let tourRepository: TourRepository

    // MARK: - Business Policy Constants
    private let minKeywordLength = 2
    private let maxKeywordLength = 50
    private let defaultPageSize = 20
    private let maxPageSize = 100
    private let defaultSortOption: SearchSortOption = .title

    // 금칙어 리스트 (비즈니스 정책)
    private let blacklistedKeywords = ["성인", "19금", "도박", "불법"]

    init(tourRepository: TourRepository) {
        self.tourRepository = tourRepository
    }

    func execute(_ input: SearchPlacesInput) -> Single<[Place]> {
        // MARK: - Input Validation & Business Rules
        return validateAndNormalize(input)
            .flatMap { [weak self] normalizedInput -> Single<[Place]> in
                guard let self = self else { return .just([]) }

                // 검색 실행
                return self.tourRepository
                    .searchPlacesByKeyword(
                        keyword: normalizedInput.keyword,
                        areaCode: normalizedInput.areaCode,
                        sigunguCode: normalizedInput.sigunguCode,
                        contentTypeId: normalizedInput.contentTypeId,
                        cat1: normalizedInput.cat1,
                        cat2: normalizedInput.cat2,
                        cat3: normalizedInput.cat3,
                        numOfRows: self.defaultPageSize,
                        pageNo: normalizedInput.page,
                        arrange: normalizedInput.sortOption.arrangeCode
                    )
                    .flatMap { places -> Single<[Place]> in
                        // 최근 검색어 저장 (검색 성공 후)
                        if normalizedInput.shouldSaveToRecent {
                            return self.tourRepository.saveRecentKeyword(normalizedInput.keyword)
                                .andThen(Single.just(places))
                        } else {
                            return Single.just(places)
                        }
                    }
                    .map { places in
                        // MARK: - Post-processing Business Rules
                        return self.applyBusinessFilters(places, keyword: normalizedInput.keyword)
                    }
            }
    }

    // MARK: - Private Business Logic

    private func validateAndNormalize(_ input: SearchPlacesInput) -> Single<(keyword: String, areaCode: Int?, sigunguCode: Int?, contentTypeId: Int?, cat1: String?, cat2: String?, cat3: String?, page: Int, sortOption: SearchSortOption, shouldSaveToRecent: Bool)> {
        return Single.create { [weak self] observer in
            guard let self = self else {
                observer(.failure(UseCaseError.unknown))
                return Disposables.create()
            }

            // 1. 키워드 정규화 (앞뒤 공백 제거)
            let normalizedKeyword = input.keyword.trimmingCharacters(in: .whitespacesAndNewlines)

            // 2. 키워드 길이 검증
            guard normalizedKeyword.count >= self.minKeywordLength else {
                observer(.failure(SearchUseCaseError.keywordTooShort(min: self.minKeywordLength)))
                return Disposables.create()
            }

            guard normalizedKeyword.count <= self.maxKeywordLength else {
                observer(.failure(SearchUseCaseError.keywordTooLong(max: self.maxKeywordLength)))
                return Disposables.create()
            }

            // 3. 금칙어 검증
            let lowercasedKeyword = normalizedKeyword.lowercased()
            if self.blacklistedKeywords.contains(where: { lowercasedKeyword.contains($0) }) {
                observer(.failure(SearchUseCaseError.blacklistedKeyword))
                return Disposables.create()
            }

            // 4. 페이지 검증
            let validPage = max(1, input.page)

            // 5. 필터 조합 검증 (sigungu는 area가 있을 때만)
            if let sigunguCode = input.sigunguCode, input.areaCode == nil {
                observer(.failure(SearchUseCaseError.invalidFilterCombination(reason: "시군구 필터를 사용하려면 지역을 먼저 선택해야 합니다.")))
                return Disposables.create()
            }

            // 6. 정렬 옵션 기본값
            let sortOption = input.sortOption ?? self.defaultSortOption

            observer(.success((
                keyword: normalizedKeyword,
                areaCode: input.areaCode,
                sigunguCode: input.sigunguCode,
                contentTypeId: input.contentTypeId,
                cat1: input.cat1,
                cat2: input.cat2,
                cat3: input.cat3,
                page: validPage,
                sortOption: sortOption,
                shouldSaveToRecent: input.shouldSaveToRecent
            )))

            return Disposables.create()
        }
    }

    private func applyBusinessFilters(_ places: [Place], keyword: String) -> [Place] {
        return places
            // 1. 중복 제거 (contentId 기준)
            .removingDuplicates()
            // 2. 블랙리스트 필터링
            .filter { !self.isBlacklisted($0) }
            // 3. 관련도 정렬 (키워드가 제목에 포함된 것 우선)
            .sorted { (first: Place, second: Place) -> Bool in
                let firstTitleMatch = first.title.localizedCaseInsensitiveContains(keyword)
                let secondTitleMatch = second.title.localizedCaseInsensitiveContains(keyword)

                if firstTitleMatch && !secondTitleMatch {
                    return true
                } else if !firstTitleMatch && secondTitleMatch {
                    return false
                }
                // 둘 다 매칭되면 원래 순서 유지
                return false
            }
    }

    private func isBlacklisted(_ place: Place) -> Bool {
        let title = place.title.lowercased()
        return blacklistedKeywords.contains { title.contains($0) }
    }
}

// MARK: - UseCase Errors
enum SearchUseCaseError: Error, LocalizedError {
    case keywordTooShort(min: Int)
    case keywordTooLong(max: Int)
    case blacklistedKeyword
    case invalidFilterCombination(reason: String)

    var errorDescription: String? {
        switch self {
        case .keywordTooShort(let min):
            return "검색어는 최소 \(min)글자 이상 입력해주세요."
        case .keywordTooLong(let max):
            return "검색어는 최대 \(max)글자까지 입력 가능합니다."
        case .blacklistedKeyword:
            return "사용할 수 없는 검색어입니다."
        case .invalidFilterCombination(let reason):
            return reason
        }
    }
}

extension UseCaseError {
    static let unknown = UseCaseError.invalidCount // Placeholder
}

// MARK: - Array Extension for Deduplication
private extension Array where Element == Place {
    func removingDuplicates() -> [Place] {
        var seen: Set<String> = []
        return filter { place in
            if seen.contains(place.contentId) {
                return false
            } else {
                seen.insert(place.contentId)
                return true
            }
        }
    }
}
