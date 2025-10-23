//
//  TourAPIResponse+Mapping.swift
//  KoreaSpots
//
//  Created by YoungJin on 9/27/25.
//

import Foundation

// MARK: - TourAPIResponse to Domain Entity Mapping
extension TourAPIResponse {
    /// Festival API 응답을 Place로 변환 (eventMeta 포함)
    func toFestivalPlaces() -> [Place] {
        return response.body?.items?.item.compactMap { $0.toPlaceFromFestival() } ?? []
    }

    func toPlaces() -> [Place] {
        return response.body?.items?.item.compactMap { $0.toPlace() } ?? []
    }
}

extension TourAPIImageResponse {
    func toPlaceImages() -> [PlaceImage] {
        return response.body?.items?.item.compactMap { $0.toPlaceImage() } ?? []
    }
}

// MARK: - TourAPIDetailIntroResponse to Domain Entity Mapping
extension TourAPIDetailIntroResponse {
    /// detailIntro2 응답을 OperatingInfo로 변환
    func toOperatingInfo() -> OperatingInfo {
        guard let firstItem = items.first else {
            return OperatingInfo(
                useTime: nil,
                restDate: nil,
                useFee: nil,
                homepage: nil,
                infoCenter: nil,
                parking: nil,
                specificInfo: nil
            )
        }
        return firstItem.detail.toOperatingInfo()
    }
}

// MARK: - TourAPIImageItem to Domain Entity Mapping
extension TourAPIImageItem {
    func toPlaceImage() -> PlaceImage? {
        guard !contentid.isEmpty,
              !originimgurl.isEmpty else { return nil }

        return PlaceImage(
            contentId: contentid,
            originImageURL: originimgurl,
            imageName: imgname?.isEmpty == true ? nil : imgname,
            smallImageURL: smallimageurl?.isEmpty == true ? nil : smallimageurl
        )
    }
}

