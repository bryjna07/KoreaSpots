//
//  TourRepositoryImpl+ErrorHandling.swift
//  KoreaSpots
//
//  Created by YoungJin on 11/12/25.
//

// 역할: API 오류 분류 후 mock 폴백/오프라인 처리, modifiedTime 기반 변경 감지
// 의존: APIErrorType, NetworkMonitor, AppStateManager
// 사용처: AppContainer (TourRepository 프로토콜로 주입)

import Foundation
import RxSwift
import Moya

extension TourRepositoryImpl {

    // MARK: - Helper: Fallback Handler
    func handleAPIError<T>(
        _ error: Error,
        mockFallback: @escaping () -> Single<T>,
        emptyValue: T
    ) -> Single<T> {
        print("🚨 handleAPIError called with error: \(error)")
        print("🚨 Error type: \(type(of: error))")

        let errorType = APIErrorType(from: error)
        print("⚠️ API ErrorType classified as: \(errorType)")
        print("⚠️ shouldUseMockData: \(errorType.shouldUseMockData)")

        // 네트워크 연결 상태 확인 (NWPathMonitor)
        if !networkMonitor.isConnectedValue {
            print("❌ Network offline detected")
            AppStateManager.shared.enterOfflineMode()
            return .error(TourRepositoryError.networkUnavailable)
        }

        // API 키 문제/한도 초과/서버 오류 → Mock 데이터로 폴백
        if errorType.shouldUseMockData {
            print("🔄 Using Mock fallback for: \(errorType)")
            print("🔄 Current AppState mode BEFORE: \(AppStateManager.shared.currentMode)")

            // Mock 모드 진입 (쓰기 작업 시도 시 Alert 표시됨)
            AppStateManager.shared.enterMockMode(reason: errorType.userMessage ?? "API Error")

            print("🔄 Current AppState mode AFTER: \(AppStateManager.shared.currentMode)")

            return mockFallback()
                .do(onSuccess: { _ in
                    print("✅ Mock Fallback Success")
                })
        }

        // 기타 에러 → 빈 값 반환
        print("⚠️ Returning empty value for errorType: \(errorType)")
        return .just(emptyValue)
    }

    // MARK: - Helper: modifiedTime 기반 스마트 갱신
    /// API에서 받은 Place들의 modifiedTime을 확인하여 변경된 경우에만 캐시 업데이트
    /// - Parameters:
    ///   - apiPlaces: API 응답으로 받은 Place 배열
    ///   - cachedPlaces: 기존 캐시된 Place 배열
    /// - Returns: 실제로 변경이 필요한 Place 배열
    private func filterChangedPlaces(_ apiPlaces: [Place], cachedPlaces: [Place]) -> [Place] {
        let cachedDict = Dictionary(uniqueKeysWithValues: cachedPlaces.map { ($0.contentId, $0) })

        return apiPlaces.filter { apiPlace in
            guard let cached = cachedDict[apiPlace.contentId] else {
                // 캐시에 없는 새로운 데이터
                return true
            }

            // modifiedTime 비교
            if let apiModifiedTime = apiPlace.modifiedTime,
               let cachedModifiedTime = cached.modifiedTime {
                return apiModifiedTime != cachedModifiedTime
            }

            // modifiedTime이 없는 경우 (detailIntro2, detailImage2 등) 무조건 갱신
            return true
        }
    }
}
