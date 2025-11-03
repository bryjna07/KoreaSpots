//
//  TourRepository.swift
//  KoreaSpots
//
//  Created by YoungJin on 9/25/25.
//

import Foundation
import RxSwift

protocol TourRepository {
    // MARK: - Festival Operations (Place with eventMeta)
    func getFestivals(
        eventStartDate: String,
        eventEndDate: String,
        areaCode: Int?,
        numOfRows: Int,
        pageNo: Int,
        arrange: String
    ) -> Single<[Place]>

    // MARK: - Place Operations
    func getLocationBasedPlaces(
        mapX: Double,
        mapY: Double,
        radius: Int,
        contentTypeId: Int?,
        numOfRows: Int,
        pageNo: Int,
        arrange: String
    ) -> Single<[Place]>

    func getAreaBasedPlaces(
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

    func searchPlacesByKeyword(
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

    // MARK: - Detail Operations
    func getPlaceDetail(contentId: String) -> Single<Place>
    func getPlaceOperatingInfo(contentId: String, contentTypeId: Int) -> Single<OperatingInfo>
    func getPlaceImages(contentId: String) -> Single<[PlaceImage]>
    func getTravelCourseDetails(contentId: String, contentTypeId: Int) -> Single<[CourseDetail]>

    // MARK: - Favorites
    func getFavoritePlaces() -> Single<[Place]>
    func toggleFavorite(contentId: String) -> Completable

    // MARK: - Recent Search Keywords
    func saveRecentKeyword(_ keyword: String) -> Completable
    func getRecentKeywords(limit: Int) -> Single<[String]>
    func deleteRecentKeyword(_ keyword: String) -> Completable
    func clearAllRecentKeywords() -> Completable

    // MARK: - Cache Management
    func clearExpiredCache() -> Completable
}