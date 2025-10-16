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
                sponsor1: festival.sponsor1?.isEmpty == true ? nil : festival.sponsor1,
                sponsor1tel: festival.sponsor1tel?.isEmpty == true ? nil : festival.sponsor1tel,
                sponsor2: festival.sponsor2?.isEmpty == true ? nil : festival.sponsor2,
                sponsor2tel: festival.sponsor2tel?.isEmpty == true ? nil : festival.sponsor2tel,
                eventenddate: festival.eventenddate?.isEmpty == true ? nil : festival.eventenddate,
                playtime: festival.playtime?.isEmpty == true ? nil : festival.playtime,
                eventplace: festival.eventplace?.isEmpty == true ? nil : festival.eventplace,
                eventhomepage: festival.eventhomepage?.isEmpty == true ? nil : festival.eventhomepage,
                agelimit: festival.agelimit?.isEmpty == true ? nil : festival.agelimit,
                bookingplace: festival.bookingplace?.isEmpty == true ? nil : festival.bookingplace,
                placeinfo: festival.placeinfo?.isEmpty == true ? nil : festival.placeinfo,
                subevent: festival.subevent?.isEmpty == true ? nil : festival.subevent,
                program: festival.program?.isEmpty == true ? nil : festival.program,
                eventstartdate: festival.eventstartdate?.isEmpty == true ? nil : festival.eventstartdate,
                usetimefestival: festival.usetimefestival?.isEmpty == true ? nil : festival.usetimefestival,
                discountinfofestival: festival.discountinfofestival?.isEmpty == true ? nil : festival.discountinfofestival,
                spendtimefestival: festival.spendtimefestival?.isEmpty == true ? nil : festival.spendtimefestival
            ))

        case let touristSpot as TouristSpotDetailIntro:
            return .touristSpot(TouristSpotSpecificInfo(
                heritage1: touristSpot.heritage1?.isEmpty == true ? nil : touristSpot.heritage1,
                heritage2: touristSpot.heritage2?.isEmpty == true ? nil : touristSpot.heritage2,
                heritage3: touristSpot.heritage3?.isEmpty == true ? nil : touristSpot.heritage3,
                infocenter: touristSpot.infocenter?.isEmpty == true ? nil : touristSpot.infocenter,
                opendate: touristSpot.opendate?.isEmpty == true ? nil : touristSpot.opendate,
                restdate: touristSpot.restdate?.isEmpty == true ? nil : touristSpot.restdate,
                expguide: touristSpot.expguide?.isEmpty == true ? nil : touristSpot.expguide,
                expagerange: touristSpot.expagerange?.isEmpty == true ? nil : touristSpot.expagerange,
                accomcount: touristSpot.accomcount?.isEmpty == true ? nil : touristSpot.accomcount,
                useseason: touristSpot.useseason?.isEmpty == true ? nil : touristSpot.useseason,
                usetime: touristSpot.usetime?.isEmpty == true ? nil : touristSpot.usetime,
                parking: touristSpot.parking?.isEmpty == true ? nil : touristSpot.parking,
                chkbabycarriage: touristSpot.chkbabycarriage?.isEmpty == true ? nil : touristSpot.chkbabycarriage,
                chkpet: touristSpot.chkpet?.isEmpty == true ? nil : touristSpot.chkpet,
                chkcreditcard: touristSpot.chkcreditcard?.isEmpty == true ? nil : touristSpot.chkcreditcard
            ))

        case let culturalFacility as CulturalFacilityDetailIntro:
            return .culturalFacility(CulturalFacilitySpecificInfo(
                scale: culturalFacility.scale?.isEmpty == true ? nil : culturalFacility.scale,
                usefee: culturalFacility.usefee?.isEmpty == true ? nil : culturalFacility.usefee,
                discountinfo: culturalFacility.discountinfo?.isEmpty == true ? nil : culturalFacility.discountinfo,
                spendtime: culturalFacility.spendtime?.isEmpty == true ? nil : culturalFacility.spendtime,
                parkingfee: culturalFacility.parkingfee?.isEmpty == true ? nil : culturalFacility.parkingfee,
                infocenterculture: culturalFacility.infocenterculture?.isEmpty == true ? nil : culturalFacility.infocenterculture,
                accomcountculture: culturalFacility.accomcountculture?.isEmpty == true ? nil : culturalFacility.accomcountculture,
                usetimeculture: culturalFacility.usetimeculture?.isEmpty == true ? nil : culturalFacility.usetimeculture,
                restdateculture: culturalFacility.restdateculture?.isEmpty == true ? nil : culturalFacility.restdateculture,
                parkingculture: culturalFacility.parkingculture?.isEmpty == true ? nil : culturalFacility.parkingculture,
                chkbabycarriageculture: culturalFacility.chkbabycarriageculture?.isEmpty == true ? nil : culturalFacility.chkbabycarriageculture,
                chkpetculture: culturalFacility.chkpetculture?.isEmpty == true ? nil : culturalFacility.chkpetculture,
                chkcreditcardculture: culturalFacility.chkcreditcardculture?.isEmpty == true ? nil : culturalFacility.chkcreditcardculture
            ))

        case let leisureSports as LeisureSportsDetailIntro:
            return .leisureSports(LeisureSportsSpecificInfo(
                openperiod: leisureSports.openperiod?.isEmpty == true ? nil : leisureSports.openperiod,
                reservation: leisureSports.reservation?.isEmpty == true ? nil : leisureSports.reservation,
                infocenterleports: leisureSports.infocenterleports?.isEmpty == true ? nil : leisureSports.infocenterleports,
                scaleleports: leisureSports.scaleleports?.isEmpty == true ? nil : leisureSports.scaleleports,
                accomcountleports: leisureSports.accomcountleports?.isEmpty == true ? nil : leisureSports.accomcountleports,
                restdateleports: leisureSports.restdateleports?.isEmpty == true ? nil : leisureSports.restdateleports,
                usetimeleports: leisureSports.usetimeleports?.isEmpty == true ? nil : leisureSports.usetimeleports,
                usefeeleports: leisureSports.usefeeleports?.isEmpty == true ? nil : leisureSports.usefeeleports,
                expagerangeleports: leisureSports.expagerangeleports?.isEmpty == true ? nil : leisureSports.expagerangeleports,
                parkingleports: leisureSports.parkingleports?.isEmpty == true ? nil : leisureSports.parkingleports,
                parkingfeeleports: leisureSports.parkingfeeleports?.isEmpty == true ? nil : leisureSports.parkingfeeleports,
                chkbabycarriageleports: leisureSports.chkbabycarriageleports?.isEmpty == true ? nil : leisureSports.chkbabycarriageleports,
                chkpetleports: leisureSports.chkpetleports?.isEmpty == true ? nil : leisureSports.chkpetleports,
                chkcreditcardleports: leisureSports.chkcreditcardleports?.isEmpty == true ? nil : leisureSports.chkcreditcardleports
            ))

        case let accommodation as AccommodationDetailIntro:
            return .accommodation(AccommodationSpecificInfo(
                roomcount: accommodation.roomcount?.isEmpty == true ? nil : accommodation.roomcount,
                roomtype: accommodation.roomtype?.isEmpty == true ? nil : accommodation.roomtype,
                refundregulation: accommodation.refundregulation?.isEmpty == true ? nil : accommodation.refundregulation,
                checkintime: accommodation.checkintime?.isEmpty == true ? nil : accommodation.checkintime,
                checkouttime: accommodation.checkouttime?.isEmpty == true ? nil : accommodation.checkouttime,
                chkcooking: accommodation.chkcooking?.isEmpty == true ? nil : accommodation.chkcooking,
                seminar: accommodation.seminar?.isEmpty == true ? nil : accommodation.seminar,
                sports: accommodation.sports?.isEmpty == true ? nil : accommodation.sports,
                sauna: accommodation.sauna?.isEmpty == true ? nil : accommodation.sauna,
                beauty: accommodation.beauty?.isEmpty == true ? nil : accommodation.beauty,
                beverage: accommodation.beverage?.isEmpty == true ? nil : accommodation.beverage,
                karaoke: accommodation.karaoke?.isEmpty == true ? nil : accommodation.karaoke,
                barbecue: accommodation.barbecue?.isEmpty == true ? nil : accommodation.barbecue,
                campfire: accommodation.campfire?.isEmpty == true ? nil : accommodation.campfire,
                bicycle: accommodation.bicycle?.isEmpty == true ? nil : accommodation.bicycle,
                fitness: accommodation.fitness?.isEmpty == true ? nil : accommodation.fitness,
                publicpc: accommodation.publicpc?.isEmpty == true ? nil : accommodation.publicpc,
                publicbath: accommodation.publicbath?.isEmpty == true ? nil : accommodation.publicbath,
                subfacility: accommodation.subfacility?.isEmpty == true ? nil : accommodation.subfacility,
                foodplace: accommodation.foodplace?.isEmpty == true ? nil : accommodation.foodplace,
                reservationurl: accommodation.reservationurl?.isEmpty == true ? nil : accommodation.reservationurl,
                pickup: accommodation.pickup?.isEmpty == true ? nil : accommodation.pickup,
                infocenterlodging: accommodation.infocenterlodging?.isEmpty == true ? nil : accommodation.infocenterlodging,
                parkinglodging: accommodation.parkinglodging?.isEmpty == true ? nil : accommodation.parkinglodging,
                reservationlodging: accommodation.reservationlodging?.isEmpty == true ? nil : accommodation.reservationlodging,
                scalelodging: accommodation.scalelodging?.isEmpty == true ? nil : accommodation.scalelodging,
                accomcountlodging: accommodation.accomcountlodging?.isEmpty == true ? nil : accommodation.accomcountlodging
            ))

        case let shopping as ShoppingDetailIntro:
            return .shopping(ShoppingSpecificInfo(
                saleitem: shopping.saleitem?.isEmpty == true ? nil : shopping.saleitem,
                saleitemcost: shopping.saleitemcost?.isEmpty == true ? nil : shopping.saleitemcost,
                fairday: shopping.fairday?.isEmpty == true ? nil : shopping.fairday,
                opendateshopping: shopping.opendateshopping?.isEmpty == true ? nil : shopping.opendateshopping,
                shopguide: shopping.shopguide?.isEmpty == true ? nil : shopping.shopguide,
                culturecenter: shopping.culturecenter?.isEmpty == true ? nil : shopping.culturecenter,
                restroom: shopping.restroom?.isEmpty == true ? nil : shopping.restroom,
                infocentershopping: shopping.infocentershopping?.isEmpty == true ? nil : shopping.infocentershopping,
                scaleshopping: shopping.scaleshopping?.isEmpty == true ? nil : shopping.scaleshopping,
                restdateshopping: shopping.restdateshopping?.isEmpty == true ? nil : shopping.restdateshopping,
                parkingshopping: shopping.parkingshopping?.isEmpty == true ? nil : shopping.parkingshopping,
                chkbabycarriageshopping: shopping.chkbabycarriageshopping?.isEmpty == true ? nil : shopping.chkbabycarriageshopping,
                chkpetshopping: shopping.chkpetshopping?.isEmpty == true ? nil : shopping.chkpetshopping,
                chkcreditcardshopping: shopping.chkcreditcardshopping?.isEmpty == true ? nil : shopping.chkcreditcardshopping,
                opentime: shopping.opentime?.isEmpty == true ? nil : shopping.opentime
            ))

        case let restaurant as RestaurantDetailIntro:
            return .restaurant(RestaurantSpecificInfo(
                seat: restaurant.seat?.isEmpty == true ? nil : restaurant.seat,
                kidsfacility: restaurant.kidsfacility?.isEmpty == true ? nil : restaurant.kidsfacility,
                firstmenu: restaurant.firstmenu?.isEmpty == true ? nil : restaurant.firstmenu,
                treatmenu: restaurant.treatmenu?.isEmpty == true ? nil : restaurant.treatmenu,
                smoking: restaurant.smoking?.isEmpty == true ? nil : restaurant.smoking,
                packing: restaurant.packing?.isEmpty == true ? nil : restaurant.packing,
                infocenterfood: restaurant.infocenterfood?.isEmpty == true ? nil : restaurant.infocenterfood,
                scalefood: restaurant.scalefood?.isEmpty == true ? nil : restaurant.scalefood,
                parkingfood: restaurant.parkingfood?.isEmpty == true ? nil : restaurant.parkingfood,
                opendatefood: restaurant.opendatefood?.isEmpty == true ? nil : restaurant.opendatefood,
                opentimefood: restaurant.opentimefood?.isEmpty == true ? nil : restaurant.opentimefood,
                restdatefood: restaurant.restdatefood?.isEmpty == true ? nil : restaurant.restdatefood,
                discountinfofood: restaurant.discountinfofood?.isEmpty == true ? nil : restaurant.discountinfofood,
                chkcreditcardfood: restaurant.chkcreditcardfood?.isEmpty == true ? nil : restaurant.chkcreditcardfood,
                reservationfood: restaurant.reservationfood?.isEmpty == true ? nil : restaurant.reservationfood,
                lcnsno: restaurant.lcnsno?.isEmpty == true ? nil : restaurant.lcnsno
            ))

        case let travelCourse as TravelCourseDetailIntro:
            return .travelCourse(TravelCourseSpecificInfo(
                distance: travelCourse.distance?.isEmpty == true ? nil : travelCourse.distance,
                schedule: travelCourse.schedule?.isEmpty == true ? nil : travelCourse.schedule,
                taketime: travelCourse.taketime?.isEmpty == true ? nil : travelCourse.taketime,
                theme: travelCourse.theme?.isEmpty == true ? nil : travelCourse.theme
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
                useTime: nil,
                restDate: nil,
                useFee: festival.usetimefestival?.isEmpty == true ? nil : festival.usetimefestival,
                homepage: festival.eventhomepage?.isEmpty == true ? nil : festival.eventhomepage,
                infoCenter: festival.sponsor1tel?.isEmpty == true ? nil : festival.sponsor1tel,
                parking: nil,
                specificInfo: specificInfo
            )

        case let touristSpot as TouristSpotDetailIntro:
            return OperatingInfo(
                useTime: touristSpot.usetime?.isEmpty == true ? nil : touristSpot.usetime,
                restDate: touristSpot.restdate?.isEmpty == true ? nil : touristSpot.restdate,
                useFee: nil,
                homepage: nil,
                infoCenter: touristSpot.infocenter?.isEmpty == true ? nil : touristSpot.infocenter,
                parking: touristSpot.parking?.isEmpty == true ? nil : touristSpot.parking,
                specificInfo: specificInfo
            )

        case let culturalFacility as CulturalFacilityDetailIntro:
            return OperatingInfo(
                useTime: culturalFacility.usetimeculture?.isEmpty == true ? nil : culturalFacility.usetimeculture,
                restDate: culturalFacility.restdateculture?.isEmpty == true ? nil : culturalFacility.restdateculture,
                useFee: culturalFacility.usefee?.isEmpty == true ? nil : culturalFacility.usefee,
                homepage: nil,
                infoCenter: culturalFacility.infocenterculture?.isEmpty == true ? nil : culturalFacility.infocenterculture,
                parking: culturalFacility.parkingculture?.isEmpty == true ? nil : culturalFacility.parkingculture,
                specificInfo: specificInfo
            )

        case let leisureSports as LeisureSportsDetailIntro:
            return OperatingInfo(
                useTime: leisureSports.usetimeleports?.isEmpty == true ? nil : leisureSports.usetimeleports,
                restDate: leisureSports.restdateleports?.isEmpty == true ? nil : leisureSports.restdateleports,
                useFee: leisureSports.usefeeleports?.isEmpty == true ? nil : leisureSports.usefeeleports,
                homepage: nil,
                infoCenter: leisureSports.infocenterleports?.isEmpty == true ? nil : leisureSports.infocenterleports,
                parking: leisureSports.parkingleports?.isEmpty == true ? nil : leisureSports.parkingleports,
                specificInfo: specificInfo
            )

        case let accommodation as AccommodationDetailIntro:
            let useTime: String? = {
                let checkin = accommodation.checkintime?.isEmpty == false ? accommodation.checkintime : nil
                let checkout = accommodation.checkouttime?.isEmpty == false ? accommodation.checkouttime : nil
                if let checkin = checkin, let checkout = checkout {
                    return "\(checkin) ~ \(checkout)"
                }
                return checkin ?? checkout
            }()

            return OperatingInfo(
                useTime: useTime,
                restDate: nil,
                useFee: nil,
                homepage: accommodation.reservationurl?.isEmpty == true ? nil : accommodation.reservationurl,
                infoCenter: accommodation.infocenterlodging?.isEmpty == true ? nil : accommodation.infocenterlodging,
                parking: accommodation.parkinglodging?.isEmpty == true ? nil : accommodation.parkinglodging,
                specificInfo: specificInfo
            )

        case let shopping as ShoppingDetailIntro:
            return OperatingInfo(
                useTime: shopping.opentime?.isEmpty == true ? nil : shopping.opentime,
                restDate: shopping.restdateshopping?.isEmpty == true ? nil : shopping.restdateshopping,
                useFee: nil,
                homepage: nil,
                infoCenter: shopping.infocentershopping?.isEmpty == true ? nil : shopping.infocentershopping,
                parking: shopping.parkingshopping?.isEmpty == true ? nil : shopping.parkingshopping,
                specificInfo: specificInfo
            )

        case let restaurant as RestaurantDetailIntro:
            return OperatingInfo(
                useTime: restaurant.opentimefood?.isEmpty == true ? nil : restaurant.opentimefood,
                restDate: restaurant.restdatefood?.isEmpty == true ? nil : restaurant.restdatefood,
                useFee: nil,
                homepage: nil,
                infoCenter: restaurant.infocenterfood?.isEmpty == true ? nil : restaurant.infocenterfood,
                parking: restaurant.parkingfood?.isEmpty == true ? nil : restaurant.parkingfood,
                specificInfo: specificInfo
            )

        case let travelCourse as TravelCourseDetailIntro:
            return OperatingInfo(
                useTime: travelCourse.taketime?.isEmpty == true ? nil : travelCourse.taketime,
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
