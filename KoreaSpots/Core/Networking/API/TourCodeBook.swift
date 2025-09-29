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
    
    public var labelKo: String {
        switch self {
        case .A0101: return "자연관광지"
        case .A0102: return "관광자원"
        case .A0201: return "역사관광지"
        case .A0202: return "휴양관광지"
        case .A0203: return "체험관광지"
        case .A0204: return "산업관광지"
        case .A0205: return "건축/조형물"
        case .A0206: return "문화시설"
        case .A0207: return "축제"
        case .A0208: return "공연/행사"
        }
    }
}

public enum Cat3: String, CaseIterable {
    // A0101 자연관광지 상세
    case A01010100 // 국립공원
    case A01010200 // 도립공원
    case A01010300 // 군립공원
    case A01010400 // 산
    case A01010500 // 자연생태관광지
    case A01010600 // 자연휴양림
    case A01010700 // 수목원
    case A01010800 // 폭포
    case A01010900 // 계곡
    case A01011000 // 약수터
    case A01011100 // 해안절경
    case A01011200 // 해수욕장
    case A01011300 // 섬
    case A01011400 // 항구/포구
    case A01011600 // 등대
    case A01011700 // 호수
    case A01011800 // 강
    case A01011900 // 동굴

    // A0102 관광자원 상세
    case A01020100 // 희귀동.식물
    case A01020200 // 기암괴석

    // A0201 역사관광지 상세
    case A02010100 // 고궁
    case A02010200 // 성
    case A02010300 // 문
    case A02010400 // 고택
    case A02010500 // 생가
    case A02010600 // 민속마을
    case A02010700 // 유적지/사적지
    case A02010800 // 사찰
    case A02010900 // 종교성지
    case A02011000 // 안보관광

    // A0202 휴양관광지 상세
    case A02020200 // 관광단지
    case A02020300 // 온천/욕장/스파
    case A02020400 // 이색찜질방
    case A02020500 // 헬스투어
    case A02020600 // 테마공원
    case A02020700 // 공원
    case A02020800 // 유람선/잠수함관광

    // A0203 체험관광지 상세
    case A02030100 // 농,산,어촌 체험
    case A02030200 // 전통체험
    case A02030300 // 산사체험
    case A02030400 // 이색체험
    case A02030500 // 이색거리

    // A0204 산업관광지 상세
    case A02040400 // 발전소
    case A02040600 // 식음료
    case A02040800 // 기타
    case A02040900 // 전자-반도체
    case A02041000 // 자동차

    // A0205 건축/조형물 상세
    case A02050100 // 다리/대교
    case A02050200 // 기념탑/기념비/전망대
    case A02050300 // 분수
    case A02050400 // 동상
    case A02050500 // 터널
    case A02050600 // 유명건물

    // A0206 문화시설 상세 (문서 상 분기 존재)
    case A02060100 // 박물관
    case A02060200 // 기념관
    case A02060300 // 전시관
    case A02060400 // 컨벤션센터
    case A02060500 // 미술관/화랑
    case A02060600 // 공연장
    case A02060700 // 문화원
    case A02060800 // 외국문화원
    case A02060900 // 도서관
    case A02061000 // 대형서점
    case A02061100 // 문화전수시설
    case A02061200 // 영화관
    case A02061300 // 어학당
    case A02061400 // 학교

    // A0207 축제 상세
    case A02070100 // 문화관광축제
    case A02070200 // 일반축제

    // A0208 공연/행사 상세
    case A02080100 // 전통공연
    case A02080200 // 연극
    case A02080300 // 뮤지컬
    case A02080400 // 오페라
    case A02080500 // 전시회
    case A02080600 // 박람회
    case A02080800 // 무용
    case A02080900 // 클래식음악회
    case A02081000 // 대중콘서트
    case A02081100 // 영화
    case A02081200 // 스포츠경기
    case A02081300 // 기타행사
    case A02081400 // 넌버벌
}

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
        public let cat3Filters: Set<Cat3>
        public init(cat1: Cat1, cat2: Cat2, cat3Filters: Set<Cat3>) {
            self.cat1 = cat1; self.cat2 = cat2; self.cat3Filters = cat3Filters
        }
    }
    
    public var query: Query {
        switch self {
        case .mountain:
            return .init(
                cat1: .A01, cat2: .A0101,
                cat3Filters: [.A01010400, .A01010100, .A01010200, .A01010300]
            )
        case .ocean:
            return .init(
                cat1: .A01, cat2: .A0101,
                cat3Filters: [.A01011200, .A01011100, .A01011600, .A01011400, .A01011300]
            )
        case .valley:
            return .init(cat1: .A01, cat2: .A0101, cat3Filters: [.A01010900, .A01010800])
        case .river:
            return .init(cat1: .A01, cat2: .A0101, cat3Filters: [.A01011800, .A01011700])
        case .forest:
            return .init(cat1: .A01, cat2: .A0101, cat3Filters: [.A01010600, .A01010700])
        case .cave:
            return .init(cat1: .A01, cat2: .A0101, cat3Filters: [.A01011900])
        case .park:
            return .init(cat1: .A02, cat2: .A0202, cat3Filters: [.A02020700])
        case .themePark:
            return .init(cat1: .A02, cat2: .A0202, cat3Filters: [.A02020600])
        case .spa:
            return .init(cat1: .A02, cat2: .A0202, cat3Filters: [.A02020300])
        case .tradition:
            return .init(cat1: .A02, cat2: .A0203, cat3Filters: [.A02030100, .A02030200, .A02030300])
        case .history:
            return .init(cat1: .A02, cat2: .A0201, cat3Filters: [.A02010100, .A02010200, .A02010300, .A02010400, .A02010500, .A02010600, .A02010700, .A02010800, .A02010900, .A02011000])
        case .etc:
            return .init(cat1: .A01, cat2: .A0102, cat3Filters: [.A01020100, .A01020200])
        }
    }
}
// MARK: - 시군구 코드 로딩 (토큰 절약: JSON 리소스로 번들링 권장)
/// 방대한 시군구 테이블은 Swift 코드로 박아두기보다, 번들 JSON으로 두고 필요 시 메모리 캐시하는 방식을 권장합니다.
/// /// JSON 스키마(양방향 라벨 지원):
/// {
///   "1": {                                  // AreaCode(rawValue)
///     "110": { "ko": "강남구", "en": "Gangnam-gu" },
///     "140": { "ko": "노원구", "en": "Nowon-gu" }
///   },
///   "6": {
///     "210": { "ko": "중구", "en": "Jung-gu" }
///   }
/// }
public struct SigunguNameRecord: Codable {
    public let ko: String
    public let en: String?
}

public enum LanguageTag: String {
    case ko, en
}

public enum SigunguStore {
    // cache: areaCode -> (sigunguCode -> name record)
    private static var cache: [String: [String: SigunguNameRecord]] = [:]
    private static let syncQueue = DispatchQueue(label: "kr.koreaspots.sigungu.store", attributes: .concurrent)

    /// 동기 로딩 (이미 data를 확보한 경우)
    public static func load(from data: Data) throws {
        let decoded = try JSONDecoder().decode([String: [String: SigunguNameRecord]].self, from: data)
        syncQueue.async(flags: .barrier) {
            cache = decoded
        }
    }
    
    /// 번들 JSON에서 비동기 로딩
    public static func loadFromBundleAsync(fileName: String = "sigungu_codes",
                                           ext: String = "json",
                                           in bundle: Bundle = .main,
                                           completion: @escaping (Bool) -> Void) {
        DispatchQueue.global(qos: .utility).async {
            guard let url = bundle.url(forResource: fileName, withExtension: ext),
                  let data = try? Data(contentsOf: url),
                  let decoded = try? JSONDecoder().decode([String: [String: SigunguNameRecord]].self, from: data) else {
                DispatchQueue.main.async { completion(false) }
                return
            }
            syncQueue.async(flags: .barrier) { cache = decoded }
            DispatchQueue.main.async { completion(true) }
        }
    }
    
    /// 현재 메모리 캐시에 데이터가 있는지
    public static var isLoaded: Bool {
        var result = false
        syncQueue.sync { result = !cache.isEmpty }
        return result
    }

    /// 조회: 언어 우선순위(ko → en)로 반환
    public static func name(areaCode: AreaCode,
                            sigunguCode: Int,
                            preferred: LanguageTag = .ko) -> String? {
        var record: SigunguNameRecord?
        syncQueue.sync {
            record = cache["\(areaCode.rawValue)"]?["\(sigunguCode)"]
        }
        guard let rec = record else { return nil }
        switch preferred {
        case .ko: return rec.ko
        case .en: return rec.en ?? rec.ko
        }
    }

    /// 외부에서 런타임 병합(디버그 하이드레이션 등)
    public static func merge(areaCode: AreaCode, entries: [Int: SigunguNameRecord]) {
        syncQueue.async(flags: .barrier) {
            var areaMap = cache["\(areaCode.rawValue)"] ?? [:]
            for (code, rec) in entries {
                areaMap["\(code)"] = rec
            }
            cache["\(areaCode.rawValue)"] = areaMap
        }
    }
}
