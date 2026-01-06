//
//  ListFilterMode.swift
//  KoreaSpots
//
//  Created by YoungJin on 1/6/26.
//

import Foundation

/// 목록 필터 모드
enum ListFilterMode: Int, CaseIterable {
    case all = 0
    case byYear = 1
    case byMonth = 2

    var title: String {
        switch self {
        case .all: return "전체보기"
        case .byYear: return "연도별"
        case .byMonth: return "월별"
        }
    }
}
