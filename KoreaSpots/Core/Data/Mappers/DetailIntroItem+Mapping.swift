//
//  DetailIntroItem+Mapping.swift
//  KoreaSpots
//
//  Created by YoungJin on 10/16/25.
//

import Foundation

// MARK: - DetailIntroItem to PlaceSpecificInfo Mapping

extension DetailIntroItem {
    /// DetailIntroItem을 PlaceSpecificInfo로 변환
    func toPlaceSpecificInfo() -> PlaceSpecificInfo? {
        switch self {
        case let festival as FestivalDetailIntro:
            return .festival(FestivalSpecificInfo(
                sponsor1: festival.sponsor1?.decodedHTML,
                sponsor1tel: festival.sponsor1tel?.decodedHTML,
                sponsor2: festival.sponsor2?.decodedHTML,
                sponsor2tel: festival.sponsor2tel?.decodedHTML,
                eventenddate: festival.eventenddate?.decodedHTML,
                playtime: festival.playtime?.decodedHTML,
                eventplace: festival.eventplace?.decodedHTML,
                eventhomepage: festival.eventhomepage?.decodedHTML,
                agelimit: festival.agelimit?.decodedHTML,
                bookingplace: festival.bookingplace?.decodedHTML,
                placeinfo: festival.placeinfo?.decodedHTML,
                subevent: festival.subevent?.decodedHTML,
                program: festival.program?.decodedHTML,
                eventstartdate: festival.eventstartdate?.decodedHTML,
                usetimefestival: festival.usetimefestival?.decodedHTML,
                discountinfofestival: festival.discountinfofestival?.decodedHTML,
                spendtimefestival: festival.spendtimefestival?.decodedHTML
            ))

        case let touristSpot as TouristSpotDetailIntro:
            return .touristSpot(TouristSpotSpecificInfo(
                heritage1: touristSpot.heritage1?.decodedHTML,
                heritage2: touristSpot.heritage2?.decodedHTML,
                heritage3: touristSpot.heritage3?.decodedHTML,
                infocenter: touristSpot.infocenter?.decodedHTML,
                opendate: touristSpot.opendate?.decodedHTML,
                restdate: touristSpot.restdate?.decodedHTML,
                expguide: touristSpot.expguide?.decodedHTML,
                expagerange: touristSpot.expagerange?.decodedHTML,
                accomcount: touristSpot.accomcount?.decodedHTML,
                useseason: touristSpot.useseason?.decodedHTML,
                usetime: touristSpot.usetime?.decodedHTML,
                parking: touristSpot.parking?.decodedHTML,
                chkbabycarriage: touristSpot.chkbabycarriage?.decodedHTML,
                chkpet: touristSpot.chkpet?.decodedHTML,
                chkcreditcard: touristSpot.chkcreditcard?.decodedHTML
            ))

        case let culturalFacility as CulturalFacilityDetailIntro:
            return .culturalFacility(CulturalFacilitySpecificInfo(
                scale: culturalFacility.scale?.decodedHTML,
                usefee: culturalFacility.usefee?.decodedHTML,
                discountinfo: culturalFacility.discountinfo?.decodedHTML,
                spendtime: culturalFacility.spendtime?.decodedHTML,
                parkingfee: culturalFacility.parkingfee?.decodedHTML,
                infocenterculture: culturalFacility.infocenterculture?.decodedHTML,
                accomcountculture: culturalFacility.accomcountculture?.decodedHTML,
                usetimeculture: culturalFacility.usetimeculture?.decodedHTML,
                restdateculture: culturalFacility.restdateculture?.decodedHTML,
                parkingculture: culturalFacility.parkingculture?.decodedHTML,
                chkbabycarriageculture: culturalFacility.chkbabycarriageculture?.decodedHTML,
                chkpetculture: culturalFacility.chkpetculture?.decodedHTML,
                chkcreditcardculture: culturalFacility.chkcreditcardculture?.decodedHTML
            ))

        case let leisureSports as LeisureSportsDetailIntro:
            return .leisureSports(LeisureSportsSpecificInfo(
                openperiod: leisureSports.openperiod?.decodedHTML,
                reservation: leisureSports.reservation?.decodedHTML,
                infocenterleports: leisureSports.infocenterleports?.decodedHTML,
                scaleleports: leisureSports.scaleleports?.decodedHTML,
                accomcountleports: leisureSports.accomcountleports?.decodedHTML,
                restdateleports: leisureSports.restdateleports?.decodedHTML,
                usetimeleports: leisureSports.usetimeleports?.decodedHTML,
                usefeeleports: leisureSports.usefeeleports?.decodedHTML,
                expagerangeleports: leisureSports.expagerangeleports?.decodedHTML,
                parkingleports: leisureSports.parkingleports?.decodedHTML,
                parkingfeeleports: leisureSports.parkingfeeleports?.decodedHTML,
                chkbabycarriageleports: leisureSports.chkbabycarriageleports?.decodedHTML,
                chkpetleports: leisureSports.chkpetleports?.decodedHTML,
                chkcreditcardleports: leisureSports.chkcreditcardleports?.decodedHTML
            ))

        case let accommodation as AccommodationDetailIntro:
            return .accommodation(AccommodationSpecificInfo(
                roomcount: accommodation.roomcount?.decodedHTML,
                roomtype: accommodation.roomtype?.decodedHTML,
                refundregulation: accommodation.refundregulation?.decodedHTML,
                checkintime: accommodation.checkintime?.decodedHTML,
                checkouttime: accommodation.checkouttime?.decodedHTML,
                chkcooking: accommodation.chkcooking?.decodedHTML,
                seminar: accommodation.seminar?.decodedHTML,
                sports: accommodation.sports?.decodedHTML,
                sauna: accommodation.sauna?.decodedHTML,
                beauty: accommodation.beauty?.decodedHTML,
                beverage: accommodation.beverage?.decodedHTML,
                karaoke: accommodation.karaoke?.decodedHTML,
                barbecue: accommodation.barbecue?.decodedHTML,
                campfire: accommodation.campfire?.decodedHTML,
                bicycle: accommodation.bicycle?.decodedHTML,
                fitness: accommodation.fitness?.decodedHTML,
                publicpc: accommodation.publicpc?.decodedHTML,
                publicbath: accommodation.publicbath?.decodedHTML,
                subfacility: accommodation.subfacility?.decodedHTML,
                foodplace: accommodation.foodplace?.decodedHTML,
                reservationurl: accommodation.reservationurl?.decodedHTML,
                pickup: accommodation.pickup?.decodedHTML,
                infocenterlodging: accommodation.infocenterlodging?.decodedHTML,
                parkinglodging: accommodation.parkinglodging?.decodedHTML,
                reservationlodging: accommodation.reservationlodging?.decodedHTML,
                scalelodging: accommodation.scalelodging?.decodedHTML,
                accomcountlodging: accommodation.accomcountlodging?.decodedHTML
            ))

        case let shopping as ShoppingDetailIntro:
            return .shopping(ShoppingSpecificInfo(
                saleitem: shopping.saleitem?.decodedHTML,
                saleitemcost: shopping.saleitemcost?.decodedHTML,
                fairday: shopping.fairday?.decodedHTML,
                opendateshopping: shopping.opendateshopping?.decodedHTML,
                shopguide: shopping.shopguide?.decodedHTML,
                culturecenter: shopping.culturecenter?.decodedHTML,
                restroom: shopping.restroom?.decodedHTML,
                infocentershopping: shopping.infocentershopping?.decodedHTML,
                scaleshopping: shopping.scaleshopping?.decodedHTML,
                restdateshopping: shopping.restdateshopping?.decodedHTML,
                parkingshopping: shopping.parkingshopping?.decodedHTML,
                chkbabycarriageshopping: shopping.chkbabycarriageshopping?.decodedHTML,
                chkpetshopping: shopping.chkpetshopping?.decodedHTML,
                chkcreditcardshopping: shopping.chkcreditcardshopping?.decodedHTML,
                opentime: shopping.opentime?.decodedHTML
            ))

        case let restaurant as RestaurantDetailIntro:
            return .restaurant(RestaurantSpecificInfo(
                seat: restaurant.seat?.decodedHTML,
                kidsfacility: restaurant.kidsfacility?.decodedHTML,
                firstmenu: restaurant.firstmenu?.decodedHTML,
                treatmenu: restaurant.treatmenu?.decodedHTML,
                smoking: restaurant.smoking?.decodedHTML,
                packing: restaurant.packing?.decodedHTML,
                infocenterfood: restaurant.infocenterfood?.decodedHTML,
                scalefood: restaurant.scalefood?.decodedHTML,
                parkingfood: restaurant.parkingfood?.decodedHTML,
                opendatefood: restaurant.opendatefood?.decodedHTML,
                opentimefood: restaurant.opentimefood?.decodedHTML,
                restdatefood: restaurant.restdatefood?.decodedHTML,
                discountinfofood: restaurant.discountinfofood?.decodedHTML,
                chkcreditcardfood: restaurant.chkcreditcardfood?.decodedHTML,
                reservationfood: restaurant.reservationfood?.decodedHTML,
                lcnsno: restaurant.lcnsno?.decodedHTML,
            ))

        case let travelCourse as TravelCourseDetailIntro:
            return .travelCourse(TravelCourseSpecificInfo(
                distance: travelCourse.distance?.decodedHTML,
                schedule: travelCourse.schedule?.decodedHTML,
                taketime: travelCourse.taketime?.decodedHTML,
                theme: travelCourse.theme?.decodedHTML,
                courseDetails: nil
            ))

        default:
            return nil
        }
    }
}

// MARK: - DetailIntroItem to OperatingInfo Mapping

extension DetailIntroItem {
    /// DetailIntroItem을 OperatingInfo로 변환 (공통 필드 + specificInfo)
    /// contentTypeId에 따라 적절한 필드를 매핑
    func toOperatingInfo() -> OperatingInfo {
        let specificInfo = toPlaceSpecificInfo()

        switch self {
        case let festival as FestivalDetailIntro:
            return OperatingInfo(
                useTime: festival.usetimefestival?.decodedHTML,
                restDate: nil,
                useFee: nil,
                homepage: festival.eventhomepage?.extractedURL,
                infoCenter: festival.sponsor1tel?.decodedHTML,
                parking: nil,
                specificInfo: specificInfo
            )

        case let touristSpot as TouristSpotDetailIntro:
            return OperatingInfo(
                useTime: touristSpot.usetime?.decodedHTML,
                restDate: touristSpot.restdate?.decodedHTML,
                useFee: nil,
                homepage: nil,
                infoCenter: touristSpot.infocenter?.decodedHTML,
                parking: touristSpot.parking?.decodedHTML,
                specificInfo: specificInfo
            )

        case let culturalFacility as CulturalFacilityDetailIntro:
            return OperatingInfo(
                useTime: culturalFacility.usetimeculture?.decodedHTML,
                restDate: culturalFacility.restdateculture?.decodedHTML,
                useFee: culturalFacility.usefee?.decodedHTML,
                homepage: nil,
                infoCenter: culturalFacility.infocenterculture?.decodedHTML,
                parking: culturalFacility.parkingculture?.decodedHTML,
                specificInfo: specificInfo
            )

        case let leisureSports as LeisureSportsDetailIntro:
            return OperatingInfo(
                useTime: leisureSports.usetimeleports?.decodedHTML,
                restDate: leisureSports.restdateleports?.decodedHTML,
                useFee: leisureSports.usefeeleports?.decodedHTML,
                homepage: nil,
                infoCenter: leisureSports.infocenterleports?.decodedHTML,
                parking: leisureSports.parkingleports?.decodedHTML,
                specificInfo: specificInfo
            )

        case let accommodation as AccommodationDetailIntro:
            let useTime: String? = {
                let checkin = accommodation.checkintime?.decodedHTML
                let checkout = accommodation.checkouttime?.decodedHTML
                if let checkin = checkin, let checkout = checkout {
                    return "\(checkin) ~ \(checkout)"
                }
                return checkin ?? checkout
            }()

            return OperatingInfo(
                useTime: useTime,
                restDate: nil,
                useFee: nil,
                homepage: accommodation.reservationurl?.extractedURL,
                infoCenter: accommodation.infocenterlodging?.decodedHTML,
                parking: accommodation.parkinglodging?.decodedHTML,
                specificInfo: specificInfo
            )

        case let shopping as ShoppingDetailIntro:
            return OperatingInfo(
                useTime: shopping.opentime?.decodedHTML,
                restDate: shopping.restdateshopping?.decodedHTML,
                useFee: nil,
                homepage: nil,
                infoCenter: shopping.infocentershopping?.decodedHTML,
                parking: shopping.parkingshopping?.decodedHTML,
                specificInfo: specificInfo
            )

        case let restaurant as RestaurantDetailIntro:
            return OperatingInfo(
                useTime: restaurant.opentimefood?.decodedHTML,
                restDate: restaurant.restdatefood?.decodedHTML,
                useFee: nil,
                homepage: nil,
                infoCenter: restaurant.infocenterfood?.decodedHTML,
                parking: restaurant.parkingfood?.decodedHTML,
                specificInfo: specificInfo
            )

        case let travelCourse as TravelCourseDetailIntro:
            return OperatingInfo(
                useTime: travelCourse.taketime?.decodedHTML,
                restDate: nil,
                useFee: nil,
                homepage: nil,
                infoCenter: nil,
                parking: nil,
                specificInfo: specificInfo
            )

        default:
            return OperatingInfo(
                useTime: nil,
                restDate: nil,
                useFee: nil,
                homepage: nil,
                infoCenter: nil,
                parking: nil,
                specificInfo: nil
            )
        }
    }
}
