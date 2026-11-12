//
//  APIErrorType.swift
//  KoreaSpots
//
//  Created by YoungJin on 11/12/25.
//

import Foundation
import Moya

// MARK: - API Error Classification
enum APIErrorType {
    case networkOffline           // 비행기 모드, 네트워크 끊김
    case apiKeyExpired            // API 키 만료 (코드 30, 31)
    case dailyLimitExceeded       // 일일 한도 초과 (코드 22)
    case serverError              // 서버 오류 (5xx)
    case noData                   // 데이터 없음 (코드 03)
    case unknown

    var shouldUseMockData: Bool {
        switch self {
        case .apiKeyExpired, .dailyLimitExceeded, .serverError:
            return true  // Mock 데이터 사용
        case .networkOffline:
            return false  // 신규 유저는 차단, 기존 유저는 캐시만
        case .noData:
            return false  // 빈 결과 반환
        case .unknown:
            return false
        }
    }

    var userMessage: String? {
        switch self {
        case .apiKeyExpired:
            return "API 서비스 점검 중입니다.\n임시 데이터로 표시됩니다."
        case .dailyLimitExceeded:
            return "일일 API 호출 한도 초과\n캐시 및 임시 데이터로 표시됩니다."
        case .serverError:
            return "서버 오류가 발생했습니다.\n임시 데이터로 표시됩니다."
        case .networkOffline:
            return "네트워크 연결이 필요합니다."
        case .noData:
            return nil
        case .unknown:
            return nil
        }
    }

    init(from error: Error) {
        print("🔍 APIErrorType.init - Analyzing error: \(error)")

        // Moya 에러 분석
        if let moyaError = error as? MoyaError {
            print("🔍 Detected MoyaError: \(moyaError)")

            switch moyaError {
            case .underlying(let nsError, _):
                print("🔍 MoyaError.underlying: \(nsError)")
                // URLError 체크 (네트워크 끊김)
                if let urlError = nsError as? URLError {
                    print("🔍 Detected URLError: \(urlError.code)")
                    switch urlError.code {
                    case .notConnectedToInternet, .networkConnectionLost, .timedOut:
                        print("✅ Classified as: networkOffline")
                        self = .networkOffline
                        return
                    default:
                        break
                    }
                }
            case .statusCode(let response):
                print("🔍 MoyaError.statusCode: \(response.statusCode)")
                // HTTP 상태 코드 체크
                switch response.statusCode {
                case 401, 403:
                    // 401 Unauthorized: 잘못된 API 키
                    // 403 Forbidden: 권한 없음 또는 일일 한도 초과
                    print("✅ Classified as: apiKeyExpired (status \(response.statusCode))")
                    self = .apiKeyExpired
                    return
                case 500...599:
                    // 5xx: 서버 오류
                    print("✅ Classified as: serverError (status \(response.statusCode))")
                    self = .serverError
                    return
                default:
                    print("⚠️ Unhandled status code: \(response.statusCode)")
                    break
                }

            case .objectMapping(_, let response):
                // JSON 파싱 실패 - 하지만 response에 status code가 있음
                print("🔍 MoyaError.objectMapping with statusCode: \(response.statusCode)")
                switch response.statusCode {
                case 401, 403:
                    // 401 Unauthorized: 잘못된 API 키 (JSON이 아닌 "Unauthorized" 텍스트 응답)
                    print("✅ Classified as: apiKeyExpired (objectMapping with status \(response.statusCode))")
                    self = .apiKeyExpired
                    return
                case 500...599:
                    print("✅ Classified as: serverError (objectMapping with status \(response.statusCode))")
                    self = .serverError
                    return
                default:
                    print("⚠️ Unhandled objectMapping status code: \(response.statusCode)")
                    break
                }

            default:
                print("🔍 Other MoyaError case: \(moyaError)")
                break
            }
        } else {
            print("🔍 Not a MoyaError")
        }

        // DataSourceError 체크
        if let dataSourceError = error as? DataSourceError {
            print("🔍 Detected DataSourceError: \(dataSourceError)")
            switch dataSourceError {
            case .networkError:
                print("✅ Classified as: networkOffline (DataSourceError)")
                self = .networkOffline
                return
            default:
                break
            }
        }

        print("⚠️ Classified as: unknown (no match found)")
        self = .unknown
    }
}
