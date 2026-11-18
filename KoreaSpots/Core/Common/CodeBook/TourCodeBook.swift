//
//  TourCodeBook.swift
//  KoreaSpots
//
//  Created by YoungJin on 9/26/25.
//

import Foundation

// MARK: - 광역 지역 코드 (시/도)
/// rawValue = TourAPI 법정동 시도 코드(lDongRegnCd). 2026-01 API 개편 이전의 areaCode(1~39)와 다름
/// 광주(5) + 전남(38)은 전남광주통합특별시(12)로 통합, 세종은 5자리(36110)
public enum AreaCode: Int, CaseIterable {
    case seoul = 11
    case incheon = 28
    case daejeon = 30
    case daegu = 27
    case busan = 26
    case ulsan = 31
    case sejong = 36110
    case gyeonggi = 41
    case gangwon = 51
    case chungbuk = 43
    case chungnam = 44
    case gyeongbuk = 47
    case gyeongnam = 48
    case jeonbuk = 52
    case jeonnamGwangju = 12
    case jeju = 50

    public var displayName: String {
        switch self {
        case .seoul: return LocalizedKeys.Area.seoul.localized
        case .incheon: return LocalizedKeys.Area.incheon.localized
        case .daejeon: return LocalizedKeys.Area.daejeon.localized
        case .daegu: return LocalizedKeys.Area.daegu.localized
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
        case .jeonnamGwangju: return LocalizedKeys.Area.jeonnam.localized
        case .jeju: return LocalizedKeys.Area.jeju.localized
        }
    }
    
    public var labelEn: String {
        switch self {
        case .seoul: return "Seoul"
        case .incheon: return "Incheon"
        case .daejeon: return "Daejeon"
        case .daegu: return "Daegu"
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
        case .jeonnamGwangju: return "Jeonnam-Gwangju"
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
        case .jeonnamGwangju: return Constants.Icon.Area.jeonnam
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
        case "광주", "광주광역시", "전남", "전라남도", "전남광주", "전남광주통합특별시":
            return .jeonnamGwangju
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
        if normalized.contains("gwangju") { return .jeonnamGwangju }
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
        if normalized.contains("jeollanam") || normalized.contains("jeonnam") { return .jeonnamGwangju }
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
}
