//
//  AppEnvironment.swift
//  KoreaSpots
//
//  Created by YoungJin on 9/27/25.
//

import Foundation

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

    var shouldUseMockData: Bool {
        switch self {
        case .development:
            // 개발 중에는 서버 문제 대응을 위해 Mock 데이터 사용
            return true
        case .staging:
            // 스테이징 환경에서는 실제 API 사용
            return false
        case .production:
            // 프로덕션에서는 실제 API만 사용
            return false
        }
    }

    var apiBaseURL: String {
        switch self {
        case .development, .staging, .production:
            return "https://apis.data.go.kr"
        }
    }
}

// MARK: - UserDefaults를 통한 개발자 설정
extension AppEnvironment {
    private static let mockDataOverrideKey = "AppEnvironment.useMockData"

    /// 개발자가 런타임에 Mock 데이터 사용 여부를 오버라이드할 수 있음
    static var forceMockData: Bool? {
        get {
            let value = UserDefaults.standard.object(forKey: mockDataOverrideKey) as? Bool
            return value
        }
        set {
            if let newValue = newValue {
                UserDefaults.standard.set(newValue, forKey: mockDataOverrideKey)
            } else {
                UserDefaults.standard.removeObject(forKey: mockDataOverrideKey)
            }
        }
    }

    /// 최종적으로 Mock 데이터를 사용할지 결정
    static var shouldUseMockData: Bool {
        return forceMockData ?? current.shouldUseMockData
    }
}
