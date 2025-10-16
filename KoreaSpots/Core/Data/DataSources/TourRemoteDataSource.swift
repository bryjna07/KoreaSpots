//
//  TourRemoteDataSource.swift
//  KoreaSpots
//
//  Created by YoungJin on 9/29/25.
//

import Foundation
import RxSwift

protocol TourRemoteDataSource {
    func fetchAreaBasedList(
        areaCode: Int?,
        sigunguCode: Int?,
        contentTypeId: Int?,
        cat1: String?,
        cat2: String?,
        cat3: String?,
        numOfRows: Int,
        pageNo: Int,
        arrange: String
    ) -> Single<[Place]>

    func fetchFestivalList(
        eventStartDate: String,
        eventEndDate: String,
        areaCode: Int?,
        numOfRows: Int,
        pageNo: Int,
        arrange: String
    ) -> Single<[Place]>  // Festival → Place (eventMeta 포함)

    func fetchLocationBasedList(
        mapX: Double,
        mapY: Double,
        radius: Int,
        contentTypeId: Int?,
        numOfRows: Int,
        pageNo: Int,
        arrange: String
    ) -> Single<[Place]>

    func fetchSearchKeyword(
        keyword: String,
        areaCode: Int?,
        sigunguCode: Int?,
        contentTypeId: Int?,
        cat1: String?,
        cat2: String?,
        cat3: String?,
        numOfRows: Int,
        pageNo: Int,
        arrange: String
    ) -> Single<[Place]>

    func fetchDetailCommon(
        contentId: String
    ) -> Single<Place>

    func fetchDetailIntro(
        contentId: String,
        contentTypeId: Int
    ) -> Single<OperatingInfo>

    func fetchDetailImages(
        contentId: String
    ) -> Single<[PlaceImage]>
}