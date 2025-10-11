//
//  ManageRecentKeywordsUseCase.swift
//  KoreaSpots
//
//  Created by YoungJin on 10/09/25.
//

import Foundation
import RxSwift

// MARK: - UseCase Protocols

/// 최근 검색어 조회
protocol GetRecentKeywordsUseCase {
    func execute(limit: Int) -> Single<[String]>
}

/// 최근 검색어 개별 삭제
protocol DeleteRecentKeywordUseCase {
    func execute(keyword: String) -> Completable
}

/// 최근 검색어 전체 삭제
protocol ClearAllRecentKeywordsUseCase {
    func execute() -> Completable
}

// MARK: - UseCase Implementations

final class GetRecentKeywordsUseCaseImpl: GetRecentKeywordsUseCase {

    private let tourRepository: TourRepository
    private let maxAllowedLimit = 20
    private let defaultLimit = 10

    init(tourRepository: TourRepository) {
        self.tourRepository = tourRepository
    }

    func execute(limit: Int = 10) -> Single<[String]> {
        // 비즈니스 규칙: limit 검증 및 정규화
        let validLimit = min(max(1, limit), maxAllowedLimit)

        return tourRepository.getRecentKeywords(limit: validLimit)
            .map { keywords in
                // 후처리: 빈 문자열 필터링
                keywords.filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
            }
    }
}

final class DeleteRecentKeywordUseCaseImpl: DeleteRecentKeywordUseCase {

    private let tourRepository: TourRepository

    init(tourRepository: TourRepository) {
        self.tourRepository = tourRepository
    }

    func execute(keyword: String) -> Completable {
        // 비즈니스 검증: 빈 키워드는 삭제하지 않음
        let normalizedKeyword = keyword.trimmingCharacters(in: .whitespaces)

        guard !normalizedKeyword.isEmpty else {
            return .error(RecentKeywordUseCaseError.emptyKeyword)
        }

        return tourRepository.deleteRecentKeyword(normalizedKeyword)
    }
}

final class ClearAllRecentKeywordsUseCaseImpl: ClearAllRecentKeywordsUseCase {

    private let tourRepository: TourRepository

    init(tourRepository: TourRepository) {
        self.tourRepository = tourRepository
    }

    func execute() -> Completable {
        return tourRepository.clearAllRecentKeywords()
            .do(onCompleted: {
                print("✅ All recent keywords cleared")
            })
    }
}

// MARK: - UseCase Errors
enum RecentKeywordUseCaseError: Error, LocalizedError {
    case emptyKeyword
    case invalidLimit

    var errorDescription: String? {
        switch self {
        case .emptyKeyword:
            return "빈 검색어는 삭제할 수 없습니다."
        case .invalidLimit:
            return "유효하지 않은 조회 개수입니다."
        }
    }
}
