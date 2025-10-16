//
//  DetailIntroItem.swift
//  KoreaSpots
//
//  Created by YoungJin on 10/16/25.
//

import Foundation

/// detailIntro2 API 응답의 contentTypeId별 상세 정보 프로토콜
protocol DetailIntroItem: Decodable {
    var contentTypeId: Int { get }
}

// MARK: - 축제 (contentTypeId: 15)

struct FestivalDetailIntro: DetailIntroItem {
    let contentTypeId: Int = 15

    let sponsor1: String?  // 주최자 정보
    let sponsor1tel: String?  // 주최자 전화번호
    let sponsor2: String?  // 주관사 정보
    let sponsor2tel: String?  // 주관사 전화번호
    let eventenddate: String?  // 행사 종료일
    let playtime: String?  // 공연시간
    let eventplace: String?  // 행사장소
    let eventhomepage: String?  // 행사 홈페이지
    let agelimit: String?  // 관람 가능연령
    let bookingplace: String?  // 예매처
    let placeinfo: String?  // 행사장 위치안내
    let subevent: String?  // 부대행사
    let program: String?  // 행사 프로그램
    let eventstartdate: String?  // 행사 시작일
    let usetimefestival: String?  // 이용요금
    let discountinfofestival: String?  // 할인정보
    let spendtimefestival: String?  // 관람 소요시간
    let festivalgrade: String?  // 축제등급
    let progresstype: String?  // 진행유형 (선택안함 등)
    let festivaltype: String?  // 축제유형 (선택안함 등)

    private enum CodingKeys: String, CodingKey {
        case sponsor1, sponsor1tel, sponsor2, sponsor2tel, eventenddate, playtime
        case eventplace, eventhomepage, agelimit, bookingplace, placeinfo, subevent
        case program, eventstartdate, usetimefestival, discountinfofestival
        case spendtimefestival, festivalgrade, progresstype, festivaltype
    }
}

// MARK: - 관광지 (contentTypeId: 12)

struct TouristSpotDetailIntro: DetailIntroItem {
    let contentTypeId: Int = 12

    let heritage1: String?  // 세계문화유산 유무
    let heritage2: String?  // 세계자연유산 유무
    let heritage3: String?  // 세계기록유산 유무
    let infocenter: String?  // 문의 및 안내
    let opendate: String?  // 개장일
    let restdate: String?  // 쉬는날
    let expguide: String?  // 체험 안내
    let expagerange: String?  // 체험가능연령
    let accomcount: String?  // 수용인원
    let useseason: String?  // 이용시기
    let usetime: String?  // 이용시간
    let parking: String?  // 주차시설
    let chkbabycarriage: String?  // 유모차 대여 여부
    let chkpet: String?  // 애완동물 동반 가능 여부
    let chkcreditcard: String?  // 신용카드 가능 여부

    private enum CodingKeys: String, CodingKey {
        case heritage1, heritage2, heritage3, infocenter, opendate, restdate
        case expguide, expagerange, accomcount, useseason, usetime, parking
        case chkbabycarriage, chkpet, chkcreditcard
    }
}

// MARK: - 문화시설 (contentTypeId: 14)

struct CulturalFacilityDetailIntro: DetailIntroItem {
    let contentTypeId: Int = 14

    let scale: String?  // 규모
    let usefee: String?  // 입장료
    let discountinfo: String?  // 할인정보
    let spendtime: String?  // 관람 소요시간
    let parkingfee: String?  // 주차요금
    let infocenterculture: String?  // 문의 및 안내
    let accomcountculture: String?  // 수용인원
    let usetimeculture: String?  // 이용시간
    let restdateculture: String?  // 쉬는날
    let parkingculture: String?  // 주차시설
    let chkbabycarriageculture: String?  // 유모차 대여 여부
    let chkpetculture: String?  // 애완동물 동반 가능 여부
    let chkcreditcardculture: String?  // 신용카드 가능 여부

    private enum CodingKeys: String, CodingKey {
        case scale, usefee, discountinfo, spendtime, parkingfee, infocenterculture
        case accomcountculture, usetimeculture, restdateculture, parkingculture
        case chkbabycarriageculture, chkpetculture, chkcreditcardculture
    }
}

// MARK: - 레포츠 (contentTypeId: 28)

struct LeisureSportsDetailIntro: DetailIntroItem {
    let contentTypeId: Int = 28

    let accomcountleports: String?  // 수용인원
    let chkbabycarriageleports: String?  // 유모차 대여 여부
    let chkcreditcardleports: String?  // 신용카드 가능 여부
    let chkpetleports: String?  // 애완동물 동반 가능 여부
    let expagerangeleports: String?  // 체험 가능연령
    let infocenterleports: String?  // 문의 및 안내
    let openperiod: String?  // 개장기간
    let parkingleports: String?  // 주차시설
    let parkingfeeleports: String?  // 주차요금
    let reservation: String?  // 예약안내
    let restdateleports: String?  // 쉬는날
    let scaleleports: String?  // 규모
    let usefeeleports: String?  // 입장료
    let usetimeleports: String?  // 이용시간

    private enum CodingKeys: String, CodingKey {
        case accomcountleports, chkbabycarriageleports, chkcreditcardleports
        case chkpetleports, expagerangeleports, infocenterleports, openperiod
        case parkingleports, parkingfeeleports, reservation, restdateleports
        case scaleleports, usefeeleports, usetimeleports
    }
}

// MARK: - 숙박 (contentTypeId: 32)

struct AccommodationDetailIntro: DetailIntroItem {
    let contentTypeId: Int = 32

    let roomcount: String?  // 객실수
    let roomtype: String?  // 객실유형
    let refundregulation: String?  // 환불규정
    let checkintime: String?  // 입실시간
    let checkouttime: String?  // 퇴실시간
    let chkcooking: String?  // 객실내 취사 여부
    let seminar: String?  // 세미나실 (0/1)
    let sports: String?  // 스포츠시설 (0/1)
    let sauna: String?  // 사우나 (0/1)
    let beauty: String?  // 뷰티시설 (0/1)
    let beverage: String?  // 식음료장 (0/1)
    let karaoke: String?  // 노래방 (0/1)
    let barbecue: String?  // 바비큐장 (0/1)
    let campfire: String?  // 캠프파이어 (0/1)
    let bicycle: String?  // 자전거대여 (0/1)
    let fitness: String?  // 휘트니스센터 (0/1)
    let publicpc: String?  // 공용PC (0/1)
    let publicbath: String?  // 공용샤워실 (0/1)
    let subfacility: String?  // 부대시설
    let foodplace: String?  // 식음료장
    let reservationurl: String?  // 예약안내 홈페이지
    let pickup: String?  // 픽업서비스
    let infocenterlodging: String?  // 문의 및 안내
    let parkinglodging: String?  // 주차시설
    let reservationlodging: String?  // 예약안내
    let scalelodging: String?  // 규모
    let accomcountlodging: String?  // 수용가능인원

    private enum CodingKeys: String, CodingKey {
        case roomcount, roomtype, refundregulation, checkintime, checkouttime, chkcooking
        case seminar, sports, sauna, beauty, beverage, karaoke, barbecue, campfire
        case bicycle, fitness, publicpc, publicbath, subfacility, foodplace
        case reservationurl, pickup, infocenterlodging, parkinglodging
        case reservationlodging, scalelodging, accomcountlodging
    }
}

// MARK: - 쇼핑 (contentTypeId: 38)

struct ShoppingDetailIntro: DetailIntroItem {
    let contentTypeId: Int = 38

    let saleitem: String?  // 판매 품목
    let saleitemcost: String?  // 판매 품목별 가격
    let fairday: String?  // 장서는 날
    let opendateshopping: String?  // 개장일
    let shopguide: String?  // 매장안내
    let culturecenter: String?  // 문화센터 바로가기
    let restroom: String?  // 화장실 설명
    let infocentershopping: String?  // 문의 및 안내
    let scaleshopping: String?  // 규모
    let restdateshopping: String?  // 쉬는날
    let parkingshopping: String?  // 주차시설
    let chkbabycarriageshopping: String?  // 유모차 대여 여부
    let chkpetshopping: String?  // 애완동물 동반 가능 여부
    let chkcreditcardshopping: String?  // 신용카드 가능 여부
    let opentime: String?  // 영업시간

    private enum CodingKeys: String, CodingKey {
        case saleitem, saleitemcost, fairday, opendateshopping, shopguide
        case culturecenter, restroom, infocentershopping, scaleshopping
        case restdateshopping, parkingshopping, chkbabycarriageshopping
        case chkpetshopping, chkcreditcardshopping, opentime
    }
}

// MARK: - 음식점 (contentTypeId: 39)

struct RestaurantDetailIntro: DetailIntroItem {
    let contentTypeId: Int = 39

    let seat: String?  // 좌석수
    let kidsfacility: String?  // 어린이 놀이방 여부 (0/1)
    let firstmenu: String?  // 대표메뉴
    let treatmenu: String?  // 취급메뉴
    let smoking: String?  // 금연/흡연 여부
    let packing: String?  // 포장 가능
    let infocenterfood: String?  // 문의 및 안내
    let scalefood: String?  // 규모
    let parkingfood: String?  // 주차시설
    let opendatefood: String?  // 개업일
    let opentimefood: String?  // 영업시간
    let restdatefood: String?  // 쉬는날
    let discountinfofood: String?  // 할인정보
    let chkcreditcardfood: String?  // 신용카드 가능 여부
    let reservationfood: String?  // 예약안내
    let lcnsno: String?  // 인허가번호

    private enum CodingKeys: String, CodingKey {
        case seat, kidsfacility, firstmenu, treatmenu, smoking, packing
        case infocenterfood, scalefood, parkingfood, opendatefood, opentimefood
        case restdatefood, discountinfofood, chkcreditcardfood, reservationfood, lcnsno
    }
}

// MARK: - 여행코스 (contentTypeId: 25)

struct TravelCourseDetailIntro: DetailIntroItem {
    let contentTypeId: Int = 25

    let distance: String?  // 거리
    let schedule: String?  // 일정
    let taketime: String?  // 소요시간
    let theme: String?  // 테마

    private enum CodingKeys: String, CodingKey {
        case distance, schedule, taketime, theme
    }
}

// MARK: - Unknown (미정의 타입)

struct UnknownDetailIntro: DetailIntroItem {
    let contentTypeId: Int = 0

    init(from decoder: Decoder) throws {
        // 빈 디코딩 - 알 수 없는 타입의 경우 무시
    }
}
