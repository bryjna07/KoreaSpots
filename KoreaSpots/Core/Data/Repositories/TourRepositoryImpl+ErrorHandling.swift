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

    /// 빈 값을 만들 수 없는 타입(예: Place)용. Mock 폴백 대상이 아닌 에러는 그대로 전파한다.
    func handleAPIError<T>(
        _ error: Error,
        mockFallback: @escaping () -> Single<T>
    ) -> Single<T> {
        let errorType = APIErrorType(from: error)

        if !networkMonitor.isConnectedValue {
            AppStateManager.shared.enterOfflineMode()
            return .error(TourRepositoryError.networkUnavailable)
        }

        if errorType.shouldUseMockData {
            AppStateManager.shared.enterMockMode(reason: errorType.userMessage ?? "API Error")
            return mockFallback()
        }

        return .error(error)
    }
}
