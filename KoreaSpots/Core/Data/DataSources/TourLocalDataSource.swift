//
//  TourLocalDataSource.swift
//  KoreaSpots
//
//  Created by YoungJin on 9/29/25.
//

import Foundation
import RxSwift

protocol TourLocalDataSource {
    // MARK: - Festival Cache
    func getFestivals(startDate: String, endDate: String) -> Single<[Festival]>
    func saveFestivals(_ festivals: [Festival], startDate: String, endDate: String) -> Completable

    // MARK: - Place Cache
    func getPlaces(areaCode: Int, sigunguCode: Int?, contentTypeId: Int?) -> Single<[Place]>
    func savePlaces(_ places: [Place], areaCode: Int, sigunguCode: Int?, contentTypeId: Int?) -> Completable

    func getLocationBasedPlaces(mapX: Double, mapY: Double, radius: Int) -> Single<[Place]>
    func saveLocationBasedPlaces(_ places: [Place], mapX: Double, mapY: Double, radius: Int) -> Completable

    // MARK: - Detail Cache
    func getPlaceDetail(contentId: String) -> Single<Place?>
    func savePlaceDetail(_ place: Place) -> Completable

    // MARK: - Recent Search Keywords
    func saveRecentKeyword(_ keyword: String) -> Completable
    func getRecentKeywords(limit: Int) -> Single<[String]>
    func deleteRecentKeyword(_ keyword: String) -> Completable
    func clearAllRecentKeywords() -> Completable

    // MARK: - Cache Management
    func isCacheValid(for key: String, ttl: TimeInterval) -> Single<Bool>
    func clearExpiredCache() -> Completable
    func clearAllCache() -> Completable
}