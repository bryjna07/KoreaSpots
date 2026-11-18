//
//  Category.swift
//  KoreaSpots
//
//  Created by YoungJin on 9/30/25.
//

import UIKit

/// 홈 화면 카테고리 (ContentTypeID 기반)
struct Category {
    let id: String
    let title: String
    let icon: UIImage
    let contentType: ContentType
}

extension Category {

    /// 홈 화면에 표시할 8개 카테고리
    static let homeCategories: [Category] = [
        Category(
            id: "festival",
            title: LocalizedKeys.Category.festival.localized,
            icon: .festival,
            contentType: .festival
        ),
        Category(
            id: "performance",
            title: LocalizedKeys.Category.performance.localized,
            icon: .performance,
            contentType: .performance
        ),
        Category(
            id: "culture",
            title: LocalizedKeys.Category.culture.localized,
            icon: .culture,
            contentType: .culture
        ),
        Category(
            id: "course",
            title: LocalizedKeys.Category.course.localized,
            icon: .course,
            contentType: .course
        ),
        Category(
            id: "leisure",
            title: LocalizedKeys.Category.leisure.localized,
            icon: .leports,
            contentType: .leisure
        ),
        Category(
            id: "lodging",
            title: LocalizedKeys.Category.lodging.localized,
            icon: .accommodation,
            contentType: .lodging
        ),
        Category(
            id: "shopping",
            title: LocalizedKeys.Category.shopping.localized,
            icon: .shopping,
            contentType: .shopping
        ),
        Category(
            id: "food",
            title: LocalizedKeys.Category.food.localized,
            icon: .food,
            contentType: .food
        )
    ]
}

// MARK: - ContentType
extension Category {

    enum ContentType {
        case festival          // searchFestival2
        case performance       // areaBasedList2 + lclsSystm2=EV02,VE07
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

        /// 신 분류체계 중분류 (축제 EV01, 공연·전시 EV02+VE07: 쉼표로 구분하면 Repository가 병합 조회)
        var lclsSystm2: String? {
            switch self {
            case .festival:
                return "EV01"  // 축제
            case .performance:
                return "EV02,VE07"  // 공연 + 전시시설
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

// MARK: - Category Detail (lclsSystm 중분류-소분류 계층 구조)
/// 중분류 코드(lclsSystm2) 래퍼 (예: NA01)
struct LclsCategory: Hashable {
    let rawValue: String

    /// 대분류 코드 (코드북의 대분류 중 접두사가 일치하는 것. 예: NA01 -> NA, C0112 -> C01)
    var lcls1: String {
        CodeBookStore.Lcls.allLevel1Codes().first { rawValue.hasPrefix($0) } ?? String(rawValue.prefix(2))
    }

    var labelKo: String {
        CodeBookStore.Lcls.name(parentCode: lcls1, code: rawValue) ?? rawValue
    }
}

struct CategoryDetail {
    let cat2: LclsCategory
    let cat3Items: [String]
}

extension CategoryDetail {
    /// 카테고리 화면 대분류 노출 순서 (목록에 없는 대분류는 뒤에 코드순으로 붙는다)
    private static let level1Order = ["NA", "HS", "VE", "EX", "LS", "EV", "AC", "FD", "SH"]

    /// 모든 중분류-소분류 계층 구조를 반환 (CodeBookStore.Lcls 기반)
    static func allCategories() -> [CategoryDetail] {
        let all = CodeBookStore.Lcls.allLevel1Codes()
        let ordered = level1Order.filter(all.contains) + all.filter { !level1Order.contains($0) }

        return ordered.flatMap { level1 in
            CodeBookStore.Lcls.childCodes(of: level1).compactMap { level2 -> CategoryDetail? in
                let items = CodeBookStore.Lcls.childCodes(of: level2)
                guard !items.isEmpty else { return nil }
                return CategoryDetail(cat2: LclsCategory(rawValue: level2), cat3Items: items)
            }
        }
    }
}
