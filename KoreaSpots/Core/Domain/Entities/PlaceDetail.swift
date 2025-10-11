//
//  PlaceDetail.swift
//  KoreaSpots
//
//  Created by YoungJin on 9/29/25.
//

import Foundation

struct PlaceDetail {
    let place: Place
    let images: [PlaceImage]
    let operatingInfo: OperatingInfo?
    let nearbyPlaces: [Place]
}

struct PlaceImage {
    let contentId: String
    let originImageURL: String
    let imageName: String?
    let smallImageURL: String?
}

struct OperatingInfo {
    let useTime: String?
    let restDate: String?
    let useFee: String?
    let homepage: String?
}

extension PlaceDetail {
    var hasOperatingInfo: Bool {
        return operatingInfo?.useTime != nil ||
               operatingInfo?.restDate != nil ||
               operatingInfo?.useFee != nil
    }

    var hasImages: Bool {
        return !images.isEmpty
    }

    var hasNearbyPlaces: Bool {
        return !nearbyPlaces.isEmpty
    }
}