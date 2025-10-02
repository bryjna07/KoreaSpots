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

// MARK: - Category Detail (Cat1, Cat2, Cat3 계층 구조)
struct CategoryDetail {
    let cat1: Cat1
    let cat2: Cat2
    let cat3Items: [Cat3]
}

extension CategoryDetail {
    /// Cat1별 모든 Cat2-Cat3 계층 구조를 반환
    /// TODO: 추후 실제 API Cat3 데이터로 교체 필요 (A03, A04, A05, B02, C01)
    static func allCategories() -> [CategoryDetail] {
        let result: [CategoryDetail] = [
            // A01 자연
            CategoryDetail(cat1: .A01, cat2: .A0101, cat3Items: [
                .A01010100, .A01010200, .A01010300, .A01010400, .A01010500, .A01010600,
                .A01010700, .A01010800, .A01010900, .A01011000, .A01011100, .A01011200,
                .A01011300, .A01011400, .A01011600, .A01011700, .A01011800, .A01011900
            ]),
            CategoryDetail(cat1: .A01, cat2: .A0102, cat3Items: [
                .A01020100, .A01020200
            ]),

            // A02 인문(문화)
            CategoryDetail(cat1: .A02, cat2: .A0201, cat3Items: [
                .A02010100, .A02010200, .A02010300, .A02010400, .A02010500, .A02010600,
                .A02010700, .A02010800, .A02010900, .A02011000
            ]),
            CategoryDetail(cat1: .A02, cat2: .A0202, cat3Items: [
                .A02020200, .A02020300, .A02020400, .A02020500, .A02020600, .A02020700, .A02020800
            ]),
            CategoryDetail(cat1: .A02, cat2: .A0203, cat3Items: [
                .A02030100, .A02030200, .A02030300, .A02030400, .A02030500
            ]),
            CategoryDetail(cat1: .A02, cat2: .A0204, cat3Items: [
                .A02040400, .A02040600, .A02040800, .A02040900, .A02041000
            ]),
            CategoryDetail(cat1: .A02, cat2: .A0205, cat3Items: [
                .A02050100, .A02050200, .A02050300, .A02050400, .A02050500, .A02050600
            ]),
            CategoryDetail(cat1: .A02, cat2: .A0206, cat3Items: [
                .A02060100, .A02060200, .A02060300, .A02060400, .A02060500, .A02060600,
                .A02060700, .A02060800, .A02060900, .A02061000, .A02061100, .A02061200,
                .A02061300, .A02061400
            ]),
            CategoryDetail(cat1: .A02, cat2: .A0207, cat3Items: [
                .A02070100, .A02070200
            ]),
            CategoryDetail(cat1: .A02, cat2: .A0208, cat3Items: [
                .A02080100, .A02080200, .A02080300, .A02080400, .A02080500, .A02080600,
                .A02080800, .A02080900, .A02081000, .A02081100, .A02081200, .A02081300, .A02081400
            ]),

            // A03 레포츠 (임시 데이터 - 추후 실제 Cat3로 교체)
            CategoryDetail(cat1: .A03, cat2: .A0201, cat3Items: [
                .A02010100, .A02010200, .A02010300, .A02010400, .A02010500, .A02010600,
                .A02010700, .A02010800
            ]),
            CategoryDetail(cat1: .A03, cat2: .A0202, cat3Items: [
                .A02020200, .A02020300, .A02020400, .A02020500, .A02020600
            ]),

            // A04 쇼핑 (임시 데이터 - 추후 실제 Cat3로 교체)
            CategoryDetail(cat1: .A04, cat2: .A0206, cat3Items: [
                .A02060100, .A02060200, .A02060300, .A02060400, .A02060500, .A02060600,
                .A02061000, .A02061200
            ]),
            CategoryDetail(cat1: .A04, cat2: .A0205, cat3Items: [
                .A02050100, .A02050200, .A02050600
            ]),

            // A05 음식 (임시 데이터 - 추후 실제 Cat3로 교체)
            CategoryDetail(cat1: .A05, cat2: .A0203, cat3Items: [
                .A02030100, .A02030200, .A02030300, .A02030400, .A02030500
            ]),
            CategoryDetail(cat1: .A05, cat2: .A0204, cat3Items: [
                .A02040400, .A02040600, .A02040800
            ]),

            // B02 숙박 (임시 데이터 - 추후 실제 Cat3로 교체)
            CategoryDetail(cat1: .B02, cat2: .A0202, cat3Items: [
                .A02020200, .A02020300, .A02020400, .A02020600, .A02020700
            ]),
            CategoryDetail(cat1: .B02, cat2: .A0201, cat3Items: [
                .A02010600, .A02010800
            ]),

            // C01 추천코스 (임시 데이터 - 추후 실제 Cat3로 교체)
            CategoryDetail(cat1: .C01, cat2: .A0201, cat3Items: [
                .A02010100, .A02010700, .A02010800, .A02010900
            ]),
            CategoryDetail(cat1: .C01, cat2: .A0203, cat3Items: [
                .A02030100, .A02030200, .A02030300
            ])
        ]
        return result
    }

    /// Cat1별로 그룹화된 CategoryDetail 배열 반환
    static func categoriesByCat1(_ cat1: Cat1) -> [CategoryDetail] {
        return allCategories().filter { $0.cat1 == cat1 }
    }
}