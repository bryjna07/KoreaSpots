//
//  PlaceSpecificInfo.swift
//  KoreaSpots
//
//  Created by YoungJin on 10/16/25.
//

import Foundation

/// contentTypeId별 특화 정보
enum PlaceSpecificInfo: Codable {
    case festival(FestivalSpecificInfo)
    case touristSpot(TouristSpotSpecificInfo)
    case culturalFacility(CulturalFacilitySpecificInfo)
    case leisureSports(LeisureSportsSpecificInfo)
    case accommodation(AccommodationSpecificInfo)
    case shopping(ShoppingSpecificInfo)
    case restaurant(RestaurantSpecificInfo)
    case travelCourse(TravelCourseSpecificInfo)

    enum CodingKeys: String, CodingKey {
        case type, data
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)

        switch type {
        case "festival":
            let data = try container.decode(FestivalSpecificInfo.self, forKey: .data)
            self = .festival(data)
        case "touristSpot":
            let data = try container.decode(TouristSpotSpecificInfo.self, forKey: .data)
            self = .touristSpot(data)
        case "culturalFacility":
            let data = try container.decode(CulturalFacilitySpecificInfo.self, forKey: .data)
            self = .culturalFacility(data)
        case "leisureSports":
            let data = try container.decode(LeisureSportsSpecificInfo.self, forKey: .data)
            self = .leisureSports(data)
        case "accommodation":
            let data = try container.decode(AccommodationSpecificInfo.self, forKey: .data)
            self = .accommodation(data)
        case "shopping":
            let data = try container.decode(ShoppingSpecificInfo.self, forKey: .data)
            self = .shopping(data)
        case "restaurant":
            let data = try container.decode(RestaurantSpecificInfo.self, forKey: .data)
            self = .restaurant(data)
        case "travelCourse":
            let data = try container.decode(TravelCourseSpecificInfo.self, forKey: .data)
            self = .travelCourse(data)
        default:
            throw DecodingError.dataCorruptedError(forKey: .type, in: container, debugDescription: "Unknown type")
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case .festival(let info):
            try container.encode("festival", forKey: .type)
            try container.encode(info, forKey: .data)
        case .touristSpot(let info):
            try container.encode("touristSpot", forKey: .type)
            try container.encode(info, forKey: .data)
        case .culturalFacility(let info):
            try container.encode("culturalFacility", forKey: .type)
            try container.encode(info, forKey: .data)
        case .leisureSports(let info):
            try container.encode("leisureSports", forKey: .type)
            try container.encode(info, forKey: .data)
        case .accommodation(let info):
            try container.encode("accommodation", forKey: .type)
            try container.encode(info, forKey: .data)
        case .shopping(let info):
            try container.encode("shopping", forKey: .type)
            try container.encode(info, forKey: .data)
        case .restaurant(let info):
            try container.encode("restaurant", forKey: .type)
            try container.encode(info, forKey: .data)
        case .travelCourse(let info):
            try container.encode("travelCourse", forKey: .type)
            try container.encode(info, forKey: .data)
        }
    }
}

// MARK: - 축제 (contentTypeId: 15)

struct FestivalSpecificInfo: Codable {
    let sponsor1: String?  // 주최자
    let sponsor1tel: String?  // 주최자 전화
    let sponsor2: String?  // 주관사
    let sponsor2tel: String?  // 주관사 전화
    let eventenddate: String?  // 종료일
    let playtime: String?  // 공연시간
    let eventplace: String?  // 행사장소
    let eventhomepage: String?  // 행사 홈페이지
    let agelimit: String?  // 관람연령
    let bookingplace: String?  // 예매처
    let placeinfo: String?  // 위치안내
    let subevent: String?  // 부대행사
    let program: String?  // 프로그램
    let eventstartdate: String?  // 시작일
    let usetimefestival: String?  // 이용요금
    let discountinfofestival: String?  // 할인정보
    let spendtimefestival: String?  // 소요시간
}

// MARK: - 관광지 (contentTypeId: 12)

struct TouristSpotSpecificInfo: Codable {
    let heritage1: String?  // 세계문화유산
    let heritage2: String?  // 세계자연유산
    let heritage3: String?  // 세계기록유산
    let infocenter: String?  // 문의
    let opendate: String?  // 개장일
    let restdate: String?  // 쉬는날
    let expguide: String?  // 체험안내
    let expagerange: String?  // 체험연령
    let accomcount: String?  // 수용인원
    let useseason: String?  // 이용시기
    let usetime: String?  // 이용시간
    let parking: String?  // 주차
    let chkbabycarriage: String?  // 유모차
    let chkpet: String?  // 반려동물
    let chkcreditcard: String?  // 신용카드
}

// MARK: - 문화시설 (contentTypeId: 14)

struct CulturalFacilitySpecificInfo: Codable {
    let scale: String?  // 규모
    let usefee: String?  // 입장료
    let discountinfo: String?  // 할인
    let spendtime: String?  // 소요시간
    let parkingfee: String?  // 주차요금
    let infocenterculture: String?  // 문의
    let accomcountculture: String?  // 수용인원
    let usetimeculture: String?  // 이용시간
    let restdateculture: String?  // 쉬는날
    let parkingculture: String?  // 주차
    let chkbabycarriageculture: String?  // 유모차
    let chkpetculture: String?  // 반려동물
    let chkcreditcardculture: String?  // 신용카드
}

// MARK: - 레포츠 (contentTypeId: 28)

struct LeisureSportsSpecificInfo: Codable {
    let openperiod: String?  // 개장기간
    let reservation: String?  // 예약
    let infocenterleports: String?  // 문의
    let scaleleports: String?  // 규모
    let accomcountleports: String?  // 수용인원
    let restdateleports: String?  // 쉬는날
    let usetimeleports: String?  // 이용시간
    let usefeeleports: String?  // 입장료
    let expagerangeleports: String?  // 체험연령
    let parkingleports: String?  // 주차
    let parkingfeeleports: String?  // 주차요금
    let chkbabycarriageleports: String?  // 유모차
    let chkpetleports: String?  // 반려동물
    let chkcreditcardleports: String?  // 신용카드
}

// MARK: - 숙박 (contentTypeId: 32)

struct AccommodationSpecificInfo: Codable {
    let roomcount: String?  // 객실수
    let roomtype: String?  // 객실유형
    let refundregulation: String?  // 환불규정
    let checkintime: String?  // 체크인
    let checkouttime: String?  // 체크아웃
    let chkcooking: String?  // 취사
    let seminar: String?  // 세미나실
    let sports: String?  // 스포츠시설
    let sauna: String?  // 사우나
    let beauty: String?  // 뷰티
    let beverage: String?  // 식음료장
    let karaoke: String?  // 노래방
    let barbecue: String?  // 바비큐
    let campfire: String?  // 캠프파이어
    let bicycle: String?  // 자전거
    let fitness: String?  // 휘트니스
    let publicpc: String?  // 공용PC
    let publicbath: String?  // 공용샤워실
    let subfacility: String?  // 부대시설
    let foodplace: String?  // 식음료장
    let reservationurl: String?  // 예약URL
    let pickup: String?  // 픽업
    let infocenterlodging: String?  // 문의
    let parkinglodging: String?  // 주차
    let reservationlodging: String?  // 예약안내
    let scalelodging: String?  // 규모
    let accomcountlodging: String?  // 수용인원
}

// MARK: - 쇼핑 (contentTypeId: 38)

struct ShoppingSpecificInfo: Codable {
    let saleitem: String?  // 판매품목
    let saleitemcost: String?  // 가격
    let fairday: String?  // 장서는날
    let opendateshopping: String?  // 개장일
    let shopguide: String?  // 매장안내
    let culturecenter: String?  // 문화센터
    let restroom: String?  // 화장실
    let infocentershopping: String?  // 문의
    let scaleshopping: String?  // 규모
    let restdateshopping: String?  // 쉬는날
    let parkingshopping: String?  // 주차
    let chkbabycarriageshopping: String?  // 유모차
    let chkpetshopping: String?  // 반려동물
    let chkcreditcardshopping: String?  // 신용카드
    let opentime: String?  // 영업시간
}

// MARK: - 음식점 (contentTypeId: 39)

struct RestaurantSpecificInfo: Codable {
    let seat: String?  // 좌석수
    let kidsfacility: String?  // 놀이방
    let firstmenu: String?  // 대표메뉴
    let treatmenu: String?  // 취급메뉴
    let smoking: String?  // 흡연
    let packing: String?  // 포장
    let infocenterfood: String?  // 문의
    let scalefood: String?  // 규모
    let parkingfood: String?  // 주차
    let opendatefood: String?  // 개업일
    let opentimefood: String?  // 영업시간
    let restdatefood: String?  // 쉬는날
    let discountinfofood: String?  // 할인
    let chkcreditcardfood: String?  // 신용카드
    let reservationfood: String?  // 예약
    let lcnsno: String?  // 인허가번호
}

// MARK: - 여행코스 (contentTypeId: 25)

struct TravelCourseSpecificInfo: Codable {
    let distance: String?  // 거리
    let schedule: String?  // 일정
    let taketime: String?  // 소요시간
    let theme: String?  // 테마
}
