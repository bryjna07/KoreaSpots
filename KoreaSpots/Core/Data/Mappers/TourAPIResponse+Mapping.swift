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

extension TourAPIImageResponse {
    func toPlaceImages() -> [PlaceImage] {
        return response.body?.items?.item.compactMap { $0.toPlaceImage() } ?? []
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

        let parsedDistance = parseDistance(dist)
        print("🏢 Creating Place '\(title)' with distance: \(parsedDistance?.description ?? "nil") (from dist: '\(dist ?? "nil")')")

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
            distance: parsedDistance
        )
    }

    func toOperatingInfo() -> OperatingInfo {
        return OperatingInfo(
            useTime: usetime?.isEmpty == true ? nil : usetime,
            restDate: restdate?.isEmpty == true ? nil : restdate,
            useFee: usefee?.isEmpty == true ? nil : usefee,
            homepage: nil // homepage는 별도 처리 필요
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
            print("🚫 parseDistance: distance is nil or empty")
            return nil
        }

        print("📏 parseDistance: parsing '\(distance)'")

        if let intValue = Int(distance) {
            print("✅ parseDistance: parsed as int = \(intValue)")
            return intValue
        } else if let doubleValue = Double(distance) {
            let result = Int(doubleValue)
            print("✅ parseDistance: parsed as double \(doubleValue) -> int \(result)")
            return result
        }

        print("❌ parseDistance: failed to parse '\(distance)'")
        return nil
    }
}

// MARK: - TourAPIImageItem to Domain Entity Mapping
extension TourAPIImageItem {
    func toPlaceImage() -> PlaceImage? {
        guard !contentid.isEmpty,
              !originimgurl.isEmpty else { return nil }

        return PlaceImage(
            contentId: contentid,
            originImageURL: originimgurl,
            imageName: imgname?.isEmpty == true ? nil : imgname,
            smallImageURL: smallimageurl?.isEmpty == true ? nil : smallimageurl
        )
    }
}

// MARK: - Validation Extensions
private extension TourAPIItem {
    var isValid: Bool {
        return !contentid.isEmpty &&
               !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
