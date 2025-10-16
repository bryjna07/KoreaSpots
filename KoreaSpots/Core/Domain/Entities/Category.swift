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
            case .festival:
                return .A0207  // 축제
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

// MARK: - Category Detail (Cat1, Cat2, Cat3 계층 구조)
struct CategoryDetail {
    let cat1: Cat1
    let cat2: Cat2
    let cat3Items: [String]
}

extension CategoryDetail {
    /// Cat1별 모든 Cat2-Cat3 계층 구조를 반환
    /// CodeBookStore.Cat3에서 동적으로 cat3 코드를 로드합니다
    static func allCategories() -> [CategoryDetail] {
        // Cat2 전체 케이스 순회
        let allCat2Cases = Cat2.allCases

        var result: [CategoryDetail] = []

        for cat2 in allCat2Cases {
            // CodeBookStore에서 해당 Cat2의 모든 Cat3 코드 가져오기
            let cat3Codes = CodeBookStore.Cat3.allCat3Codes(for: cat2.rawValue)

            // Cat3 코드가 있는 경우에만 CategoryDetail 생성
            guard !cat3Codes.isEmpty else { continue }

            // Cat2에서 Cat1 추출 (앞 3자리)
            guard let cat1 = Cat1(rawValue: cat2.cat1) else { continue }

            result.append(CategoryDetail(
                cat1: cat1,
                cat2: cat2,
                cat3Items: cat3Codes
            ))
        }

        return result
    }

    /// Cat1별로 그룹화된 CategoryDetail 배열 반환
    static func categoriesByCat1(_ cat1: Cat1) -> [CategoryDetail] {
        return allCategories().filter { $0.cat1 == cat1 }
    }
}
