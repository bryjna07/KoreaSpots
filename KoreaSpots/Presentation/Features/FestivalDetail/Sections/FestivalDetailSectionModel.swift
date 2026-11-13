//
//  FestivalDetailSectionModel.swift
//  KoreaSpots
//
//  Created by YoungJin on 11/13/26.
//

import Foundation
import RxDataSources

// MARK: - Display Models
/// 축제 진행 상태 (배지 표시용)
enum FestivalStatus: Equatable {
    case ongoing
    case upcoming(daysLeft: Int)
    case ended
}

/// 상단 헤더(제목/기간/장소/상태) 표시용 모델
struct FestivalHeaderInfo: Equatable {
    let contentId: String
    let title: String
    let period: String?
    let place: String?
    let status: FestivalStatus?
}

/// 정보 한 줄 (아이콘 + 제목 + 내용). action이 있으면 탭 가능
struct FestivalInfoRow: Equatable {
    enum Action: Equatable {
        case call(String)       // 전화번호
        case openURL(URL)       // 홈페이지/예매처
    }

    let id: String
    let symbol: String          // SF Symbol 이름
    let title: String
    let content: String
    let action: Action?
}

// MARK: - Section Model
struct FestivalDetailSectionModel: Equatable {
    let section: Section
    var items: [FestivalDetailSectionItem]
}

extension FestivalDetailSectionModel {
    enum Section: String, Equatable {
        case imageCarousel
        case header
        case info
        case description
        case program
        case contact
        case location

        var headerTitle: String? {
            switch self {
            case .imageCarousel, .header, .description:
                return nil
            case .info:
                return LocalizedKeys.FestivalDetail.sectionInfo.localized
            case .program:
                return LocalizedKeys.FestivalDetail.sectionProgram.localized
            case .contact:
                return LocalizedKeys.FestivalDetail.sectionContact.localized
            case .location:
                return LocalizedKeys.Section.location.localized
            }
        }
    }
}

enum FestivalDetailSectionItem: IdentifiableType, Equatable {
    case image(PlaceImage)
    case header(FestivalHeaderInfo)
    case infoRow(FestivalInfoRow)
    case description(String)
    case location(Place)

    var identity: String {
        switch self {
        case .image(let image):
            return "image_\(image.contentId)_\(image.originImageURL.hashValue)"
        case .header(let info):
            return "header_\(info.contentId)"
        case .infoRow(let row):
            return "row_\(row.id)"
        case .description(let text):
            return "description_\(text.hashValue)"
        case .location(let place):
            return "location_\(place.contentId)"
        }
    }

    static func == (lhs: FestivalDetailSectionItem, rhs: FestivalDetailSectionItem) -> Bool {
        lhs.identity == rhs.identity
    }
}

extension FestivalDetailSectionModel: AnimatableSectionModelType {
    var identity: String { section.rawValue }

    init(original: FestivalDetailSectionModel, items: [FestivalDetailSectionItem]) {
        self = FestivalDetailSectionModel(section: original.section, items: items)
    }
}
