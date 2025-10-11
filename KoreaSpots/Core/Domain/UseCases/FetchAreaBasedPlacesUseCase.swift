//
//  FetchAreaBasedPlacesUseCase.swift
//  KoreaSpots
//
//  Created by YoungJin on 9/27/25.
//

import Foundation
import RxSwift

protocol FetchAreaBasedPlacesUseCase {
    func execute(areaCode: Int, sigunguCode: Int?, contentTypeId: Int?, cat1: String?, cat2: String?, cat3: String?, maxCount: Int) -> Single<[Place]>
}

final class FetchAreaBasedPlacesUseCaseImpl: FetchAreaBasedPlacesUseCase {

    private let tourRepository: TourRepository

    init(tourRepository: TourRepository) {
        self.tourRepository = tourRepository
    }

    func execute(areaCode: Int, sigunguCode: Int?, contentTypeId: Int?, cat1: String?, cat2: String?, cat3: String?, maxCount: Int) -> Single<[Place]> {
        return tourRepository
            .getAreaBasedPlaces(
                areaCode: areaCode,
                sigunguCode: sigunguCode,
                contentTypeId: contentTypeId,
                cat1: cat1,
                cat2: cat2,
                cat3: cat3,
                numOfRows: maxCount,
                pageNo: 1,
                arrange: "A" // 제목순
            )
    }
}
