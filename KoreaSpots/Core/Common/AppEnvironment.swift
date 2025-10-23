//
//  AppEnvironment.swift
//  KoreaSpots
//
//  Created by YoungJin on 9/27/25.
//

import Foundation

// MARK: - Notification Names
extension Notification.Name {
    /// Mock 모드 진입 시 발송되는 Notification (1회만)
    static let mockModeEntered = Notification.Name("mockModeEntered")
}

enum AppEnvironment {
    case development
    case staging
    case production

    static var current: AppEnvironment {
        #if DEBUG
        return .development
        #else
        return .production
        #endif
    }

    var apiBaseURL: String {
        switch self {
        case .development, .staging, .production:
            return "https://apis.data.go.kr"
        }
    }
}

// MARK: - 데이터 소스 모드 (런타임 상태)
enum DataSourceMode {
    case normal              // 정상 API 동작
    case mockFallback        // API 오류로 Mock 데이터 사용 중
    case offline             // 네트워크 오프라인 (캐시 사용)

    var isUsingMockData: Bool {
        return self == .mockFallback
    }

    var userMessage: String? {
        switch self {
        case .mockFallback:
            return "예시 데이터가 표시되고 있습니다.\n실제와 다를 수 있습니다.\n서버 복구 시 정확한 데이터가 표시됩니다."
        case .offline:
            return "네트워크 연결이 필요합니다.\n저장된 데이터를 표시합니다."
        case .normal:
            return nil
        }
    }

    var shouldRestrictWriteOperations: Bool {
        switch self {
        case .mockFallback:
            return true  // Mock 데이터 사용 시 쓰기 작업 제한
        case .offline:
            return false  // 오프라인이어도 로컬 쓰기는 허용
        case .normal:
            return false
        }
    }
}

