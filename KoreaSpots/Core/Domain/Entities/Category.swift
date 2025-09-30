//
//  Category.swift
//  KoreaSpots
//
//  Created by YoungJin on 9/30/25.
//

import Foundation

/// 홈 화면 카테고리 (ContentTypeID 기반)
struct Category {
    let id: String
    let title: String
    let iconName: String
    let contentType: ContentType
}

extension Category {

    /// 홈 화면에 표시할 8개 카테고리
    static let homeCategories: [Category] = [
        Category(
            id: "festival",
            title: LocalizedKeys.Category.festival.localized,
            iconName: "party.popper.fill",
            contentType: .festival
        ),
        Category(
            id: "performance",
            title: LocalizedKeys.Category.performance.localized,
            iconName: "theatermasks.fill",
            contentType: .performance
        ),
        Category(
            id: "culture",
            title: LocalizedKeys.Category.culture.localized,
            iconName: "building.columns.fill",
            contentType: .culture
        ),
        Category(
            id: "course",
            title: LocalizedKeys.Category.course.localized,
            iconName: "map.fill",
            contentType: .course
        ),
        Category(
            id: "leisure",
            title: LocalizedKeys.Category.leisure.localized,
            iconName: "figure.surfing",
            contentType: .leisure
        ),
        Category(
            id: "lodging",
            title: LocalizedKeys.Category.lodging.localized,
            iconName: "bed.double.fill",
            contentType: .lodging
        ),
        Category(
            id: "shopping",
            title: LocalizedKeys.Category.shopping.localized,
            iconName: "bag.fill",
            contentType: .shopping
        ),
        Category(
            id: "food",
            title: LocalizedKeys.Category.food.localized,
            iconName: "fork.knife",
            contentType: .food
        )
    ]
}

// MARK: - ContentType
extension Category {

    enum ContentType {
        case festival          // searchFestival2
        case performance       // searchFestival2 + cat2=A0208
        case culture          // areaBasedList2 + contentTypeId=14
        case course           // areaBasedList2 + contentTypeId=25
        case leisure          // areaBasedList2 + contentTypeId=28
        case lodging          // searchStay2
        case shopping         // areaBasedList2 + contentTypeId=38
        case food             // areaBasedList2 + contentTypeId=39

        var contentTypeId: ContentTypeID? {
            switch self {
            case .festival, .performance:
                return .festival
            case .culture:
                return .culture
            case .course:
                return .course
            case .leisure:
                return .leisure
            case .lodging:
                return .lodging
            case .shopping:
                return .shopping
            case .food:
                return .food
            }
        }

        var cat2: Cat2? {
            switch self {
            case .performance:
                return .A0208  // 공연/행사
            default:
                return nil
            }
        }

        var apiType: APIType {
            switch self {
            case .festival, .performance:
                return .searchFestival
            case .lodging:
                return .searchStay
            default:
                return .areaBasedList
            }
        }

        enum APIType {
            case searchFestival  // searchFestival2
            case searchStay      // searchStay2
            case areaBasedList   // areaBasedList2
        }
    }
}

// MARK: - Equatable
extension Category: Equatable {
    static func == (lhs: Category, rhs: Category) -> Bool {
        return lhs.id == rhs.id
    }
}