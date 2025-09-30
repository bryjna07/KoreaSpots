//
//  LocalizedKeys.swift
//  KoreaSpots
//
//  Created by YoungJin on 9/27/25.
//

import Foundation

// MARK: - Localized Keys
enum LocalizedKeys {

    // MARK: - Home
    enum Home {
        static let title = "home_title"
    }

    // MARK: - Section Headers
    enum Section {
        static let festival = "section_festival"
        static let nearby = "section_nearby"
        static let theme = "section_theme"
        static let areaQuickLink = "section_area_quick_link"
        static let operatingInfo = "section_operating_info"
        static let location = "section_location"
        static let nearbyPlaces = "section_nearby_places"
    }

    // MARK: - Actions
    enum Action {
        static let openMap = "action_open_map"
        static let confirm = "action_confirm"
        static let cancel = "action_cancel"
        static let delete = "action_delete"
    }

    // MARK: - Errors
    enum Error {
        static let title = "error_title"
        static let fetchFestivalFailed = "error_fetch_festival_failed"
        static let fetchPlacesFailed = "error_fetch_places_failed"
        static let fetchPlaceDetailFailed = "error_fetch_place_detail_failed"
    }

    // MARK: - Search
    enum Search {
        static let placeholder = "search_placeholder"
        static let title = "search_title"
        static let navigationMessage = "search_navigation_message"
    }

    // MARK: - Area Names
    enum Area {
        static let seoul = "area_seoul"
        static let incheon = "area_incheon"
        static let daejeon = "area_daejeon"
        static let daegu = "area_daegu"
        static let gwangju = "area_gwangju"
        static let busan = "area_busan"
        static let ulsan = "area_ulsan"
        static let sejong = "area_sejong"
        static let gyeonggi = "area_gyeonggi"
        static let gangwon = "area_gangwon"
        static let chungbuk = "area_chungbuk"
        static let chungnam = "area_chungnam"
        static let gyeongbuk = "area_gyeongbuk"
        static let gyeongnam = "area_gyeongnam"
        static let jeonbuk = "area_jeonbuk"
        static let jeonnam = "area_jeonnam"
        static let jeju = "area_jeju"
    }

    // MARK: - Categories
    enum Category {
        static let nature = "category_nature"
        static let culture = "category_culture"
        static let sports = "category_sports"
        static let shopping = "category_shopping"
        static let food = "category_food"
        static let accommodation = "category_accommodation"
        static let course = "category_course"
    }

    // MARK: - Theme Categories
    enum Theme {
        static let ocean = "theme_ocean"
        static let mountain = "theme_mountain"
        static let valley = "theme_valley"
        static let river = "theme_river"
        static let forest = "theme_forest"
        static let cave = "theme_cave"
        static let park = "theme_park"
        static let themePark = "theme_theme_park"
        static let spa = "theme_spa"
        static let tradition = "theme_tradition"
        static let history = "theme_history"
        static let etc = "theme_etc"
    }
}
