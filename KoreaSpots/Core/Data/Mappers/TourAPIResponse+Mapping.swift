//
//  TourAPIResponse+Mapping.swift
//  KoreaSpots
//
//  Created by YoungJin on 9/27/25.
//

import Foundation

// MARK: - TourAPIResponse to Domain Entity Mapping
extension TourAPIResponse {
    func toFestivals() -> [Festival] {
        return response.body?.items?.item.compactMap { $0.toFestival() } ?? []
    }

    func toPlaces() -> [Place] {
        return response.body?.items?.item.compactMap { $0.toPlace() } ?? []
    }
}

// MARK: - TourAPIItem to Domain Entity Mapping
extension TourAPIItem {
    func toFestival() -> Festival? {
        // MARK: - 필수 필드 검증 (이제 non-optional이므로 존재 보장)
        guard !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return nil
        }

        return Festival(
            contentId: contentid,
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            address: addr1.isEmpty ? "주소 정보 없음" : addr1.trimmingCharacters(in: .whitespacesAndNewlines),
            imageURL: processImageURL(firstimage),
            eventStartDate: eventstartdate ?? "",
            eventEndDate: eventenddate ?? "",
            tel: processPhone(tel),
            mapX: parseCoordinate(mapx),
            mapY: parseCoordinate(mapy),
            overview: processOverview(overview)
        )
    }

    func toPlace() -> Place? {
        // MARK: - 필수 필드 검증 (이제 non-optional이므로 존재 보장)
        guard !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return nil
        }

        return Place(
            contentId: contentid,
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            address: addr1.isEmpty ? "주소 정보 없음" : addr1.trimmingCharacters(in: .whitespacesAndNewlines),
            imageURL: processImageURL(firstimage),
            mapX: parseCoordinate(mapx),
            mapY: parseCoordinate(mapy),
            tel: processPhone(tel),
            overview: processOverview(overview),
            contentTypeId: parseInt(contenttypeid) ?? 12,
            distance: parseDistance(dist)
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
              !distance.isEmpty else { return nil }
        if let intValue = Int(distance) {
            return intValue
        } else if let doubleValue = Double(distance) {
            return Int(doubleValue)
        }
        return nil
    }
}

// MARK: - Validation Extensions
private extension TourAPIItem {
    var isValid: Bool {
        return !contentid.isEmpty &&
               !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
