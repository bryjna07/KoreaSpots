//
//  PlaceDetailSectionModel.swift
//  KoreaSpots
//
//  Created by YoungJin on 9/29/25.
//

import Foundation
import RxDataSources

struct PlaceDetailSectionModel: Equatable {
    let section: Section
    var items: [PlaceDetailSectionItem]

    static func == (lhs: PlaceDetailSectionModel, rhs: PlaceDetailSectionModel) -> Bool {
        return lhs.section == rhs.section && lhs.items == rhs.items
    }
}

extension PlaceDetailSectionModel {
    enum Section: String, CaseIterable, Equatable {
        case imageCarousel
        case basicInfo
        case description
        case operatingInfo
        case location
        case nearbyPlaces

        var headerTitle: String? {
            switch self {
            case .imageCarousel, .basicInfo, .description:
                return nil
            case .operatingInfo:
                return LocalizedKeys.Section.operatingInfo.localized
            case .location:
                return LocalizedKeys.Section.location.localized
            case .nearbyPlaces:
                return LocalizedKeys.Section.nearbyPlaces.localized
            }
        }

        var identity: String {
            return rawValue
        }
    }
}

enum PlaceDetailSectionItem: IdentifiableType, Equatable {
    case image(PlaceImage)
    case basicInfo(Place)
    case description(String)
    case operatingInfo(OperatingInfo)
    case location(Place)
    case nearbyPlace(Place)

    var identity: String {
        switch self {
        case .image(let image):
            return "image_\(image.contentId)_\(image.originImageURL.hashValue)"
        case .basicInfo(let place):
            return "basicInfo_\(place.contentId)"
        case .description(let text):
            return "description_\(text.hashValue)"
        case .operatingInfo:
            return "operatingInfo"
        case .location(let place):
            return "location_\(place.contentId)"
        case .nearbyPlace(let place):
            return "nearbyPlace_\(place.contentId)"
        }
    }

    static func == (lhs: PlaceDetailSectionItem, rhs: PlaceDetailSectionItem) -> Bool {
        return lhs.identity == rhs.identity
    }
}

extension PlaceDetailSectionModel: AnimatableSectionModelType {

    var identity: String { section.identity }

    init(original: PlaceDetailSectionModel, items: [PlaceDetailSectionItem]) {
        self = PlaceDetailSectionModel(section: original.section, items: items)
    }
}