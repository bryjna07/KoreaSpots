//
//  TourAPIBaseItem+Mapping.swift
//  KoreaSpots
//
//  Created by YoungJin on 10/16/25.
//

import Foundation

// MARK: - TourAPIBaseItem to Domain Entity Mapping
extension TourAPIBaseItem {
    /// 일반 Place로 변환 (areaBasedList2, detailCommon2 등)
    func toPlace() -> Place? {
        guard !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return nil
        }

        // 주소가 비어있으면 areacode로 지역명 표시
        let displayAddress: String
        if addr1.isEmpty {
            if let areaCodeInt = parseInt(areacode),
               let areaCode = AreaCode(rawValue: areaCodeInt) {
                displayAddress = areaCode.displayName
            } else {
                displayAddress = "주소 정보 없음"
            }
        } else {
            displayAddress = addr1.trimmingCharacters(in: .whitespacesAndNewlines)
        }

        return Place(
            contentId: contentid,
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            address: displayAddress,
            imageURL: processImageURL(firstimage),
            mapX: parseCoordinate(mapx),
            mapY: parseCoordinate(mapy),
            tel: processPhone(tel),
            overview: processOverview(overview),
            contentTypeId: parseInt(contenttypeid) ?? 12,
            areaCode: parseInt(areacode),
            sigunguCode: parseInt(sigungucode),
            cat1: cat1?.isEmpty == true ? nil : cat1,
            cat2: cat2?.isEmpty == true ? nil : cat2,
            cat3: cat3?.isEmpty == true ? nil : cat3,
            distance: parseDistance(dist),
            modifiedTime: modifiedtime.isEmpty ? nil : modifiedtime,
            eventMeta: nil,
            isCustom: false,
            customPlaceId: nil,
            userProvidedImagePath: nil
        )
    }

    /// Festival Place로 변환 (eventMeta 포함)
    func toPlaceFromFestival() -> Place? {
        guard !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return nil
        }

        // EventMeta 생성
        let eventMeta: EventMeta?
        if let startDate = eventstartdate, let endDate = eventenddate,
           !startDate.isEmpty, !endDate.isEmpty {
            eventMeta = EventMeta(
                eventStartDate: startDate,
                eventEndDate: endDate
            )
        } else {
            eventMeta = nil
        }

        // 주소가 비어있으면 areacode로 지역명 표시
        let displayAddress: String
        if addr1.isEmpty {
            if let areaCodeInt = parseInt(areacode),
               let areaCode = AreaCode(rawValue: areaCodeInt) {
                displayAddress = areaCode.displayName
            } else {
                displayAddress = "주소 정보 없음"
            }
        } else {
            displayAddress = addr1.trimmingCharacters(in: .whitespacesAndNewlines)
        }

        return Place(
            contentId: contentid,
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            address: displayAddress,
            imageURL: processImageURL(firstimage),
            mapX: parseCoordinate(mapx),
            mapY: parseCoordinate(mapy),
            tel: processPhone(tel),
            overview: processOverview(overview),
            contentTypeId: parseInt(contenttypeid) ?? 15,  // 축제는 contentTypeId 15
            areaCode: parseInt(areacode),
            sigunguCode: parseInt(sigungucode),
            cat1: cat1?.isEmpty == true ? nil : cat1,
            cat2: cat2?.isEmpty == true ? nil : cat2,
            cat3: cat3?.isEmpty == true ? nil : cat3,
            distance: nil,
            modifiedTime: modifiedtime.isEmpty ? nil : modifiedtime,
            eventMeta: eventMeta,
            isCustom: false,
            customPlaceId: nil,
            userProvidedImagePath: nil
        )
    }

    // MARK: - Helper Methods
    private func processImageURL(_ imageURL: String?) -> String? {
        guard let url = imageURL?.trimmingCharacters(in: .whitespacesAndNewlines),
              !url.isEmpty else { return nil }
        return url
    }

    private func processPhone(_ phone: String?) -> String? {
        guard let phone = phone?.trimmingCharacters(in: .whitespacesAndNewlines),
              !phone.isEmpty else { return nil }
        return phone
    }

    private func processOverview(_ overview: String?) -> String? {
        guard let overview = overview?.trimmingCharacters(in: .whitespacesAndNewlines),
              !overview.isEmpty else { return nil }
        return overview
    }

    private func parseCoordinate(_ coordinate: String?) -> Double? {
        guard let coordinate = coordinate,
              let value = Double(coordinate) else { return nil }
        return value
    }

    private func parseInt(_ intString: String?) -> Int? {
        guard let intString = intString?.trimmingCharacters(in: .whitespacesAndNewlines),
              !intString.isEmpty,
              let value = Int(intString) else { return nil }
        return value
    }

    private func parseDistance(_ distance: String?) -> Int? {
        guard let distance = distance?.trimmingCharacters(in: .whitespacesAndNewlines),
              !distance.isEmpty else {
            return nil
        }

        if let intValue = Int(distance) {
            return intValue
        } else if let doubleValue = Double(distance) {
            return Int(doubleValue)
        }

        return nil
    }
}
