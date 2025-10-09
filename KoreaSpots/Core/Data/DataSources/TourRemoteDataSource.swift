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
        areaCode: Int,
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
        numOfRows: Int,
        pageNo: Int,
        arrange: String
    ) -> Single<[Festival]>

    func fetchLocationBasedList(
        mapX: Double,
        mapY: Double,
        radius: Int,
        numOfRows: Int,
        pageNo: Int,
        arrange: String
    ) -> Single<[Place]>

    func fetchDetailCommon(
        contentId: String,
        contentTypeId: Int?
    ) -> Single<Place>

    func fetchDetailIntro(
        contentId: String,
        contentTypeId: Int
    ) -> Single<Place>

    func fetchDetailImages(
        contentId: String,
        numOfRows: Int,
        pageNo: Int
    ) -> Single<[PlaceImage]>
}