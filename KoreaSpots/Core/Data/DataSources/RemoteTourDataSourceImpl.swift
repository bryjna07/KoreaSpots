//
//  RemoteTourDataSourceImpl.swift
//  KoreaSpots
//
//  Created by YoungJin on 9/27/25.
//

import Foundation
import Moya
import RxSwift
import RxMoya

final class RemoteTourDataSourceImpl: TourRemoteDataSource {
    
    private let provider: MoyaProvider<TourAPI>

    init(provider: MoyaProvider<TourAPI>) {
        self.provider = provider
    }

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
    ) -> Single<[Place]> {
        return provider.rx
            .request(.areaBasedList(
                areaCode: areaCode,
                sigunguCode: sigunguCode,
                contentTypeId: contentTypeId,
                cat1: cat1,
                cat2: cat2,
                cat3: cat3,
                numOfRows: numOfRows,
                pageNo: pageNo,
                arrange: arrange
            ))
            .map(TourAPIResponse.self)
            .map { response in
                response.toPlaces()
            }
    }

    func fetchFestivalList(
        eventStartDate: String,
        eventEndDate: String,
        numOfRows: Int,
        pageNo: Int,
        arrange: String
    ) -> Single<[Festival]> {
        return provider.rx
            .request(.searchFestival(
                eventStartDate: eventStartDate,
                eventEndDate: eventEndDate,
                numOfRows: numOfRows,
                pageNo: pageNo,
                arrange: arrange
            ))
            .map(TourAPIResponse.self)
            .map { response in
                response.toFestivals()
            }
    }

    func fetchLocationBasedList(
        mapX: Double,
        mapY: Double,
        radius: Int,
        numOfRows: Int,
        pageNo: Int,
        arrange: String
    ) -> Single<[Place]> {
        return provider.rx
            .request(.locationBasedList(
                mapX: mapX,
                mapY: mapY,
                radius: radius,
                numOfRows: numOfRows,
                pageNo: pageNo,
                arrange: arrange
            ))
            .map(TourAPIResponse.self)
            .map { response in
                response.toPlaces()
            }
    }

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
    ) -> Single<[Place]> {
        return provider.rx
            .request(.searchKeyword(
                keyword: keyword,
                areaCode: areaCode,
                sigunguCode: sigunguCode,
                contentTypeId: contentTypeId,
                cat1: cat1,
                cat2: cat2,
                cat3: cat3,
                numOfRows: numOfRows,
                pageNo: pageNo,
                arrange: arrange
            ))
            .map(TourAPIResponse.self)
            .map { response in
                response.toPlaces()
            }
    }

    func fetchDetailImages(contentId: String, numOfRows: Int, pageNo: Int) -> Single<[PlaceImage]> {
        return provider.rx.request(.detailImage(
            contentId: contentId,
            numOfRows: numOfRows,
            pageNo: pageNo
        ))
        .map(TourAPIImageResponse.self)
        .map { response in
            response.toPlaceImages()
        }
    }

    func fetchDetailCommon(
        contentId: String,
        contentTypeId: Int?
    ) -> Single<Place> {
        return provider.rx.request(.detailCommon(
            contentId: contentId,
            contentTypeId: contentTypeId
        ))
        .map(TourAPIResponse.self)
        .map { response in
            response.toPlaces().first ?? Place.empty
        }
    }

    func fetchDetailIntro(
        contentId: String,
        contentTypeId: Int
    ) -> Single<Place> {
        return provider.rx.request(.detailIntro(
            contentId: contentId,
            contentTypeId: contentTypeId
        ))
        .map(TourAPIResponse.self)
        .map { response in
            response.toPlaces().first ?? Place.empty
        }
    }
}

// MARK: - DataSource Errors
enum DataSourceError: Error, LocalizedError {
    case notImplemented
    case networkError(Error)
    case parseError
    case cacheError

    var errorDescription: String? {
        switch self {
        case .notImplemented:
            return "Feature not yet implemented"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .parseError:
            return "Failed to parse response"
        case .cacheError:
            return "Cache operation failed"
        }
    }
}
