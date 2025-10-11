//
//  TourAPI+Builder.swift
//  KoreaSpots
//
//  Created by YoungJin on 9/29/25.
//

import Foundation

// MARK: - TourAPI Builder Extension
extension TourAPI {

    static func makeAreaBasedList(
        areaCode: AreaCode,
        sigunguCode: Int? = nil,
        contentTypeId: Int? = nil,
        cat1: String? = nil,
        cat2: String? = nil,
        cat3: String? = nil,
        numOfRows: Int = 20,
        pageNo: Int = 1,
        arrange: String = "A"
    ) -> TourAPI {
        return .areaBasedList(
            areaCode: areaCode.rawValue,
            sigunguCode: sigunguCode,
            contentTypeId: contentTypeId,
            cat1: cat1,
            cat2: cat2,
            cat3: cat3,
            numOfRows: numOfRows,
            pageNo: pageNo,
            arrange: arrange
        )
    }

    static func makeFestivalList(
        startDate: String,
        endDate: String,
        numOfRows: Int = 20,
        pageNo: Int = 1,
        arrange: String = "B"
    ) -> TourAPI {
        return .searchFestival(
            eventStartDate: startDate,
            eventEndDate: endDate,
            numOfRows: numOfRows,
            pageNo: pageNo,
            arrange: arrange
        )
    }

    static func makeLocationBasedList(
        mapX: Double,
        mapY: Double,
        radius: Int = 1000,
        numOfRows: Int = 20,
        pageNo: Int = 1,
        arrange: String = "E"
    ) -> TourAPI {
        return .locationBasedList(
            mapX: mapX,
            mapY: mapY,
            radius: radius,
            numOfRows: numOfRows,
            pageNo: pageNo,
            arrange: arrange
        )
    }
}
