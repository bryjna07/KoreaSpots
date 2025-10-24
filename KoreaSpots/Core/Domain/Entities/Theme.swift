//
//  Theme.swift
//  KoreaSpots
//
//  Created by YoungJin on 9/25/25.
//

import Foundation

struct Theme {
    let id: String
    let title: String
    let imageName: String
    let description: String?
    let contentTypeId: Int?
    let theme12: Theme12
    let cat1: String
    let cat2: String
}

extension Theme {
    static let staticThemes: [Theme] = Theme12.allCases.map { theme12 in
        Theme(
            id: theme12.rawValue,
            title: theme12.displayName,
            imageName: theme12.imageURLString,
            description: theme12.description,
            contentTypeId: theme12.contentTypeId,
            theme12: theme12,
            cat1: theme12.query.cat1.rawValue,
            cat2: theme12.query.cat2.rawValue
        )
    }
}

// MARK: - Theme12 Extension
private extension Theme12 {
    var rawValue: String {
        switch self {
        case .ocean: return "ocean"
        case .mountain: return "mountain"
        case .valley: return "valley"
        case .river: return "river"
        case .forest: return "forest"
        case .cave: return "cave"
        case .park: return "park"
        case .themePark: return "themePark"
        case .spa: return "spa"
        case .tradition: return "tradition"
        case .history: return "history"
        case .etc: return "etc"
        }
    }

    var description: String? {
        switch self {
        case .ocean: return "해변과 바다 관련 명소"
        case .mountain: return "산악과 등산로"
        case .valley: return "계곡과 폭포"
        case .river: return "강과 호수"
        case .forest: return "휴양림과 수목원"
        case .cave: return "동굴과 지하 명소"
        case .park: return "공원과 정원"
        case .themePark: return "테마파크와 놀이시설"
        case .spa: return "온천과 스파"
        case .tradition: return "전통 체험 명소"
        case .history: return "역사와 문화재"
        case .etc: return "기타 명소"
        }
    }

    var contentTypeId: Int? {
        switch self {
        case .ocean, .mountain, .valley, .river, .forest, .cave, .park:
            return 12 // 관광지
        case .themePark:
            return 12 // 관광지
        case .spa:
            return 12 // 관광지
        case .tradition, .history:
            return 12 // 관광지
        case .etc:
            return 12
        }
    }
    
    var imageURLString: String {
        switch self {
        case .ocean:
            return "https://tong.visitkorea.or.kr/cms/resource/45/3534645_image2_1.jpg"
        case .mountain:
            return "https://tong.visitkorea.or.kr/cms/resource/57/3492857_image2_1.jpg"
        case .valley:
            return "https://tong.visitkorea.or.kr/cms/resource/62/3538262_image2_1.jpg"
        case .river:
            return "https://tong.visitkorea.or.kr/cms/resource/14/2656114_image2_1.jpg"
        case .forest:
            return "https://tong.visitkorea.or.kr/cms/resource/66/3511566_image2_1.jpg"
        case .cave:
            return "https://tong.visitkorea.or.kr/cms/resource/73/2649973_image2_1.jpg"
        case .park:
            return "https://tong.visitkorea.or.kr/cms/resource/78/3524778_image2_1.jpg"
        case .themePark:
            return "https://tong.visitkorea.or.kr/cms/resource/00/3304300_image2_1.jpg"
        case .spa:
            return "https://tong.visitkorea.or.kr/cms/resource/80/1591380_image2_1.jpg"
        case .tradition:
            return "https://tong.visitkorea.or.kr/cms/resource/47/2388347_image2_1.jpg"
        case .history:
            return "https://tong.visitkorea.or.kr/cms/resource/32/2678632_image2_1.jpg"
        case .etc:
            return "https://tong.visitkorea.or.kr/cms/resource/59/3351159_image2_1.jpg"
        }
    }
}
