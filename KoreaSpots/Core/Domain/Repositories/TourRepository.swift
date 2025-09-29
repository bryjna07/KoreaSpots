//
//  TourRepository.swift
//  KoreaSpots
//
//  Created by YoungJin on 9/25/25.
//

import Foundation
import RxSwift

protocol TourRepository {
    // MARK: - Festival Operations
    func getFestivals(
        eventStartDate: String,
        eventEndDate: String,
        numOfRows: Int,
        pageNo: Int,
        arrange: String
    ) -> Single<[Festival]>

    // MARK: - Place Operations
    func getLocationBasedPlaces(
        mapX: Double,
        mapY: Double,
        radius: Int,
        numOfRows: Int,
        pageNo: Int,
        arrange: String
    ) -> Single<[Place]>

    func getAreaBasedPlaces(
        areaCode: Int,
        sigunguCode: Int?,
        contentTypeId: Int?,
        numOfRows: Int,
        pageNo: Int,
        arrange: String
    ) -> Single<[Place]>

    // MARK: - Detail Operations
    func getPlaceDetail(contentId: String, contentTypeId: Int?) -> Single<Place>

    // MARK: - Cache Management
    func clearExpiredCache() -> Completable
}