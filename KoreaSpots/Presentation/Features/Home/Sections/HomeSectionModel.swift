//
//  HomeSectionModel.swift
//  KoreaSpots
//
//  Created by YoungJin on 9/25/25.
//

import Foundation
import RxDataSources

struct HomeSectionModel {
    let section: Section
    var items: [HomeSectionItem]
}

extension HomeSectionModel {
    enum Section: String, CaseIterable {
        case festival
        case category
        case theme
        case nearby
//        case placeholder

        var headerTitle: String {
            switch self {
            case .festival:
                return LocalizedKeys.Section.festival.localized
            case .category:
                return LocalizedKeys.Section.category.localized
            case .theme:
                return LocalizedKeys.Section.theme.localized
            case .nearby:
                return LocalizedKeys.Section.nearby.localized
//            case .placeholder:
//                return "준비중"
            }
        }

        var identity: String {
            return rawValue
        }
    }

    /// Backward‑compatible accessor if existing code expects `.header`
    var header: String {
        return section.headerTitle
    }
}

enum HomeSectionItem: IdentifiableType, Equatable {
    case festival(Place)
    case category(Category)
    case theme(Theme)
    case place(Place)
    /// TODO: - 주간날씨 섹션
//    case placeholder(String, index: Int = 0)

    var identity: String {
        switch self {
        case .festival(let f):
            return "festival_\(f.contentId)"
        case .category(let c):
            return "category_\(c.id)"
        case .theme(let t):
            return "theme_\(t.title)"
        case .place(let p):
            return "place_\(p.contentId)"
//        case .placeholder(let s, let index):
//            return "placeholder_\(s)_\(index)"
        }
    }

    static func == (lhs: HomeSectionItem, rhs: HomeSectionItem) -> Bool {
        return lhs.identity == rhs.identity
    }
}

extension HomeSectionModel: AnimatableSectionModelType {

    var identity: String { section.identity }

    init(original: HomeSectionModel, items: [HomeSectionItem]) {
        self = HomeSectionModel(section: original.section, items: items)
    }
}
