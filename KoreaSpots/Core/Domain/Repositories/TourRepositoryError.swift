//
//  TourRepositoryError.swift
//  KoreaSpots
//
//  Created by YoungJin on 11/12/25.
//

import Foundation

// MARK: - Repository Errors
enum TourRepositoryError: Error, LocalizedError {
    case dataSourceError(Error)
    case mappingError
    case networkUnavailable  // 네트워크 끊김 (신규 유저는 차단)
    case writeOperationBlocked  // Mock 모드에서 쓰기 작업 차단
    case unknown

    var errorDescription: String? {
        switch self {
        case .dataSourceError(let error):
            return "Data source error: \(error.localizedDescription)"
        case .mappingError:
            return "Failed to map data"
        case .networkUnavailable:
            return "네트워크 연결이 필요합니다"
        case .writeOperationBlocked:
            return "현재 서버 오류로 인해\n예시 데이터를 표시 중입니다.\n\n예시 데이터 사용 중에는\n이 기능을 사용할 수 없습니다."
        case .unknown:
            return "Unknown repository error"
        }
    }
}

