//
//  TripRecordSegment.swift
//  KoreaSpots
//
//  Created by Watson22_YJ on 1/5/26.
//

import Foundation

enum TripRecordSegment: Int, CaseIterable {
    case list = 0
    case calendar = 1

    var title: String {
        switch self {
        case .list: return "목록"
        case .calendar: return "달력"
        }
    }
}
