//
//  TourCodeBook.swift
//  KoreaSpots
//
//  Created by YoungJin on 9/26/25.
//

import Foundation

// MARK: - 광역 지역 코드 (시/도)
public enum AreaCode: Int, CaseIterable {
    case seoul = 1
    case incheon = 2
    case daejeon = 3
    case daegu = 4
    case gwangju = 5
    case busan = 6
    case ulsan = 7
    case sejong = 8
    case gyeonggi = 31
    case gangwon = 32
    case chungbuk = 33
    case chungnam = 34
    case gyeongbuk = 35
    case gyeongnam = 36
    case jeonbuk = 37
    case jeonnam = 38
    case jeju = 39
    
    public var displayName: String {
        switch self {
        case .seoul: return LocalizedKeys.Area.seoul.localized
        case .incheon: return LocalizedKeys.Area.incheon.localized
        case .daejeon: return LocalizedKeys.Area.daejeon.localized
        case .daegu: return LocalizedKeys.Area.daegu.localized
        case .gwangju: return LocalizedKeys.Area.gwangju.localized
        case .busan: return LocalizedKeys.Area.busan.localized
        case .ulsan: return LocalizedKeys.Area.ulsan.localized
        case .sejong: return LocalizedKeys.Area.sejong.localized
        case .gyeonggi: return LocalizedKeys.Area.gyeonggi.localized
        case .gangwon: return LocalizedKeys.Area.gangwon.localized
        case .chungbuk: return LocalizedKeys.Area.chungbuk.localized
        case .chungnam: return LocalizedKeys.Area.chungnam.localized
        case .gyeongbuk: return LocalizedKeys.Area.gyeongbuk.localized
        case .gyeongnam: return LocalizedKeys.Area.gyeongnam.localized
        case .jeonbuk: return LocalizedKeys.Area.jeonbuk.localized
        case .jeonnam: return LocalizedKeys.Area.jeonnam.localized
        case .jeju: return LocalizedKeys.Area.jeju.localized
        }
    }
    
    public var labelEn: String {
        switch self {
        case .seoul: return "Seoul"
        case .incheon: return "Incheon"
        case .daejeon: return "Daejeon"
        case .daegu: return "Daegu"
        case .gwangju: return "Gwangju"
        case .busan: return "Busan"
        case .ulsan: return "Ulsan"
        case .sejong: return "Sejong"
        case .gyeonggi: return "Gyeonggi-do"
        case .gangwon: return "Gangwon-do"
        case .chungbuk: return "Chungcheongbuk-do"
        case .chungnam: return "Chungcheongnam-do"
        case .gyeongbuk: return "Gyeongsangbuk-do"
        case .gyeongnam: return "Gyeongsangnam-do"
        case .jeonbuk: return "Jeollabuk-do"
        case .jeonnam: return "Jeollanam-do"
        case .jeju: return "Jeju"
        }
    }

    public func label(for languageCode: String) -> String {
        // Use simple language prefix matching: "ko", "en" ...
        if languageCode.hasPrefix("en") { return labelEn }
        return displayName
    }

    public var iconName: String {
        switch self {
        case .seoul: return Constants.Icon.Area.seoul
        case .incheon: return Constants.Icon.Area.incheon
        case .daejeon: return Constants.Icon.Area.daejeon
        case .daegu: return Constants.Icon.Area.daegu
        case .gwangju: return Constants.Icon.Area.gwangju
        case .busan: return Constants.Icon.Area.busan
        case .ulsan: return Constants.Icon.Area.ulsan
        case .sejong: return Constants.Icon.Area.sejong
        case .gyeonggi: return Constants.Icon.Area.gyeonggi
        case .gangwon: return Constants.Icon.Area.gangwon
        case .chungbuk: return Constants.Icon.Area.chungbuk
        case .chungnam: return Constants.Icon.Area.chungnam
        case .gyeongbuk: return Constants.Icon.Area.gyeongbuk
        case .gyeongnam: return Constants.Icon.Area.gyeongnam
        case .jeonbuk: return Constants.Icon.Area.jeonbuk
        case .jeonnam: return Constants.Icon.Area.jeonnam
        case .jeju: return Constants.Icon.Area.jeju
        }
    }

    /// CLPlacemark의 administrativeArea로부터 AreaCode 추출 (Reverse Geocoding용)
    /// - 한국어 및 영어 지역명 모두 지원
    public static func from(administrativeArea: String?) -> AreaCode? {
        guard let area = administrativeArea else { return nil }

        // 공백 제거 및 소문자 변환 (영문 대응)
        let normalized = area.replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "-", with: "")
            .lowercased()

        // 한글 매칭
        switch normalized {
        case "서울", "서울특별시", "서울시":
            return .seoul
        case "인천", "인천광역시":
            return .incheon
        case "대전", "대전광역시":
            return .daejeon
        case "대구", "대구광역시":
            return .daegu
        case "광주", "광주광역시":
            return .gwangju
        case "부산", "부산광역시":
            return .busan
        case "울산", "울산광역시":
            return .ulsan
        case "세종", "세종특별자치시", "세종시":
            return .sejong
        case "경기", "경기도":
            return .gyeonggi
        case "강원", "강원도", "강원특별자치도":
            return .gangwon
        case "충북", "충청북도":
            return .chungbuk
        case "충남", "충청남도":
            return .chungnam
        case "경북", "경상북도":
            return .gyeongbuk
        case "경남", "경상남도":
            return .gyeongnam
        case "전북", "전라북도", "전북특별자치도":
            return .jeonbuk
        case "전남", "전라남도":
            return .jeonnam
        case "제주", "제주도", "제주특별자치도":
            return .jeju
        default:
            break
        }

        // 영문 매칭
        if normalized.contains("seoul") { return .seoul }
        if normalized.contains("incheon") { return .incheon }
        if normalized.contains("daejeon") { return .daejeon }
        if normalized.contains("daegu") { return .daegu }
        if normalized.contains("gwangju") { return .gwangju }
        if normalized.contains("busan") || normalized.contains("pusan") { return .busan }
        if normalized.contains("ulsan") { return .ulsan }
        if normalized.contains("sejong") { return .sejong }
        if normalized.contains("gyeonggi") || normalized.contains("gyeonggido") { return .gyeonggi }
        if normalized.contains("gangwon") { return .gangwon }
        if normalized.contains("chungcheongbuk") || normalized.contains("chungbuk") { return .chungbuk }
        if normalized.contains("chungcheongnam") || normalized.contains("chungnam") { return .chungnam }
        if normalized.contains("gyeongsangbuk") || normalized.contains("gyeongbuk") { return .gyeongbuk }
        if normalized.contains("gyeongsangnam") || normalized.contains("gyeongnam") { return .gyeongnam }
        if normalized.contains("jeollabuk") || normalized.contains("jeonbuk") { return .jeonbuk }
        if normalized.contains("jeollanam") || normalized.contains("jeonnam") { return .jeonnam }
        if normalized.contains("jeju") { return .jeju }

        return nil
    }
}

// MARK: - 콘텐츠 타입 ID (TourAPI contentTypeId)
public enum ContentTypeID: Int, CaseIterable {
    case attraction = 12      // 관광지
    case culture = 14         // 문화시설
    case festival = 15        // 축제공연행사
    case course = 25          // 여행코스
    case leisure = 28         // 레포츠
    case lodging = 32         // 숙박
    case shopping = 38        // 쇼핑
    case food = 39            // 음식점
}

// MARK: - 카테고리: cat1 / cat2 / cat3 (문서 코드)
public enum Cat1: String, CaseIterable {
    case A01  // 자연
    case A02  // 인문(문화/예술/역사)
    case A03  // 레포츠
    case A04  // 쇼핑
    case A05  // 음식
    case B02  // 숙박
    case C01  // 추천코스
    
    public var displayName: String {
        switch self {
        case .A01: return LocalizedKeys.Category.nature.localized
        case .A02: return LocalizedKeys.Category.culture.localized
        case .A03: return LocalizedKeys.Category.sports.localized
        case .A04: return LocalizedKeys.Category.shopping.localized
        case .A05: return LocalizedKeys.Category.food.localized
        case .B02: return LocalizedKeys.Category.accommodation.localized
        case .C01: return LocalizedKeys.Category.course.localized
        }
    }
}

public enum Cat2: String, CaseIterable {
    // A01 자연
    case A0101 // 자연관광지
    case A0102 // 관광자원
    
    // A02 인문
    case A0201 // 역사관광지
    case A0202 // 휴양관광지
    case A0203 // 체험관광지
    case A0204 // 산업관광지
    case A0205 // 건축/조형물
    case A0206 // 문화시설
    case A0207 // 축제
    case A0208 // 공연/행사
    
    // A03 레포츠
    case A0301 // 레포츠소개
    case A0302 // 육상레포츠
    case A0303 // 수상레포츠
    case A0304 // 항공레포츠
    case A0305 // 복합레포츠
    
    // A04 쇼핑
    case A0401 // 쇼핑
    
    // A05 음식점
    case A0502 // 음식점
    
    // B02 숙박
    case B0201 // 숙박시설
    
    // C01 추천코스
    case C0112 // 가족코스
    case C0113 // 나홀로코스
    case C0114 // 힐링코스
    case C0115 // 도보코스
    case C0116 // 캠핑코스
    case C0117 // 맛코스
    
    public var labelKo: String {
        switch self {
        // A01 자연
        case .A0101: return "자연관광지"
        case .A0102: return "관광자원"
        // A02 인문
        case .A0201: return "역사관광지"
        case .A0202: return "휴양관광지"
        case .A0203: return "체험관광지"
        case .A0204: return "산업관광지"
        case .A0205: return "건축/조형물"
        case .A0206: return "문화시설"
        case .A0207: return "축제"
        case .A0208: return "공연/행사"
        // A03 레포츠
        case .A0301: return "레포츠소개"
        case .A0302: return "육상 레포츠"
        case .A0303: return "수상 레포츠"
        case .A0304: return "항공 레포츠"
        case .A0305: return "복합 레포츠"
        // A04 쇼핑
        case .A0401: return "쇼핑"
        // A05 음식점
        case .A0502: return "음식점"
        // B02 숙박
        case .B0201: return "숙박시설"
        // C01 추천코스
        case .C0112: return "가족코스"
        case .C0113: return "나홀로코스"
        case .C0114: return "힐링코스"
        case .C0115: return "도보코스"
        case .C0116: return "캠핑코스"
        case .C0117: return "맛코스"
        }
    }

    /// Cat2에서 Cat1 추출 (앞 3자리)
    public var cat1: String {
        return String(rawValue.prefix(3))
    }
}

// MARK: - Cat3 코드는 JSON 리소스로 관리 (CodeBookStore.Cat3 사용)
/// cat3_codes.json 파일 참조
/// 사용법: CodeBookStore.Cat3.name(cat2Code: "A0101", cat3Code: "A01010100")

// MARK: - 12개 사용자 테마 (앱 노출용)
public enum Theme12: CaseIterable {
    case ocean        // 바다
    case mountain     // 산
    case valley       // 계곡
    case river        // 강/호수 분리 운영 시: river, lake로 쪼갤 수 있음
    case forest       // 휴양림/수목원
    case cave         // 동굴
    case park         // 공원
    case themePark    // 테마파크
    case spa          // 온천/스파
    case tradition    // 전통/체험
    case history      // 역사/사찰 등
    case etc          // 기타(보조)
    
    public var displayName: String {
        switch self {
        case .ocean: return LocalizedKeys.Theme.ocean.localized
        case .mountain: return LocalizedKeys.Theme.mountain.localized
        case .valley: return LocalizedKeys.Theme.valley.localized
        case .river: return LocalizedKeys.Theme.river.localized
        case .forest: return LocalizedKeys.Theme.forest.localized
        case .cave: return LocalizedKeys.Theme.cave.localized
        case .park: return LocalizedKeys.Theme.park.localized
        case .themePark: return LocalizedKeys.Theme.themePark.localized
        case .spa: return LocalizedKeys.Theme.spa.localized
        case .tradition: return LocalizedKeys.Theme.tradition.localized
        case .history: return LocalizedKeys.Theme.history.localized
        case .etc: return LocalizedKeys.Theme.etc.localized
        }
    }
    
    /// 요청 최적화 전략:
    /// - 서버엔 넓은 cat1/cat2로 조회(1콜)
    /// - 클라이언트에서 cat3로 정밀 필터링 → **카테고리 코드 조회 API 추가 호출 불필요**
    public struct Query {
        public let cat1: Cat1
        public let cat2: Cat2
        public let cat3Filters: Set<String>
        public init(cat1: Cat1, cat2: Cat2, cat3Filters: Set<String>) {
            self.cat1 = cat1; self.cat2 = cat2; self.cat3Filters = cat3Filters
        }
    }

    public var query: Query {
        switch self {
        case .mountain:
            return .init(
                cat1: .A01, cat2: .A0101,
                cat3Filters: ["A01010400", "A01010100", "A01010200", "A01010300"]
            )
        case .ocean:
            return .init(
                cat1: .A01, cat2: .A0101,
                cat3Filters: ["A01011200", "A01011100", "A01011600", "A01011400", "A01011300"]
            )
        case .valley:
            return .init(cat1: .A01, cat2: .A0101, cat3Filters: ["A01010900", "A01010800"])
        case .river:
            return .init(cat1: .A01, cat2: .A0101, cat3Filters: ["A01011800", "A01011700"])
        case .forest:
            return .init(cat1: .A01, cat2: .A0101, cat3Filters: ["A01010600", "A01010700"])
        case .cave:
            return .init(cat1: .A01, cat2: .A0101, cat3Filters: ["A01011900"])
        case .park:
            return .init(cat1: .A02, cat2: .A0202, cat3Filters: ["A02020700"])
        case .themePark:
            return .init(cat1: .A02, cat2: .A0202, cat3Filters: ["A02020600"])
        case .spa:
            return .init(cat1: .A02, cat2: .A0202, cat3Filters: ["A02020300"])
        case .tradition:
            return .init(cat1: .A02, cat2: .A0203, cat3Filters: ["A02030100", "A02030200", "A02030300"])
        case .history:
            return .init(cat1: .A02, cat2: .A0201, cat3Filters: [])
        case .etc:
            return .init(cat1: .A01, cat2: .A0102, cat3Filters: ["A01020100", "A01020200"])
        }
    }
}
// MARK: - 시군구 코드는 JSON 리소스로 관리 (CodeBookStore.Sigungu 사용)
/// sigungu_codes.json 파일 참조
/// 사용법: CodeBookStore.Sigungu.name(areaCode: 1, sigunguCode: 1)
