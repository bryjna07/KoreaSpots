//
//  SkeletonDataIdentifiable.swift
//  KoreaSpots
//
//  Created by YoungJin on 10/14/25.
//

import Foundation

/// 스켈레톤뷰를 표시할 수 있는 데이터 모델
protocol SkeletonDataIdentifiable {
    var contentId: String { get }

    /// 더미 데이터인지 확인
    var isSkeletonData: Bool { get }
}

extension SkeletonDataIdentifiable {
    var isSkeletonData: Bool {
        return contentId.hasPrefix("skeleton")
    }
}

// MARK: - Place Model 확장
extension Place: SkeletonDataIdentifiable {
    // contentId 프로퍼티가 이미 존재하므로 자동으로 프로토콜 준수
}
