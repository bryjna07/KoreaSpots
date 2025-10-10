//
//  TripR+Mapping.swift
//  KoreaSpots
//
//  Created by YoungJin on 10/10/25.
//

import Foundation
import RealmSwift

// MARK: - TripR Mapping
extension TripR {
    func toDomain() -> Trip {
        return Trip(
            id: id.stringValue,
            title: title,
            coverPhotoPath: coverPhotoId,
            startDate: startDate,
            endDate: endDate,
            memo: memo,
            visitedPlaces: visitedPlaces.map { $0.toDomain() },
            visitedAreas: visitedAreas.map { $0.toDomain() },
            tags: Array(tags),
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }

    convenience init(from trip: Trip) {
        self.init()
        if !trip.id.isEmpty, let objectId = try? ObjectId(string: trip.id) {
            self.id = objectId
        } else {
            // Generate new ObjectId for new trips
            self.id = ObjectId.generate()
        }
        self.title = trip.title
        self.coverPhotoId = trip.coverPhotoPath
        self.startDate = trip.startDate
        self.endDate = trip.endDate
        self.memo = trip.memo
        self.visitedPlaces.append(objectsIn: trip.visitedPlaces.map { VisitedPlaceE(from: $0) })
        self.visitedAreas.append(objectsIn: trip.visitedAreas.map { VisitedAreaE(from: $0) })
        self.tags.append(objectsIn: trip.tags)
        self.createdAt = trip.createdAt
        self.updatedAt = Date() // Always update timestamp
    }
}

// MARK: - VisitedPlaceE Mapping
extension VisitedPlaceE {
    func toDomain() -> VisitedPlace {
        return VisitedPlace(
            entryId: entryId,
            placeId: placeId,
            placeNameSnapshot: placeNameSnapshot,
            thumbnailURLSnapshot: thumbnailURLSnapshot,
            areaCode: areaCode,
            sigunguCode: sigunguCode,
            addedAt: addedAt,
            order: order,
            note: note,
            rating: rating,
            location: locationSnapshot?.toDomain()
        )
    }

    convenience init(from visitedPlace: VisitedPlace) {
        self.init()
        self.entryId = visitedPlace.entryId
        self.placeId = visitedPlace.placeId
        self.placeNameSnapshot = visitedPlace.placeNameSnapshot
        self.thumbnailURLSnapshot = visitedPlace.thumbnailURLSnapshot
        self.areaCode = visitedPlace.areaCode
        self.sigunguCode = visitedPlace.sigunguCode
        self.addedAt = visitedPlace.addedAt
        self.order = visitedPlace.order
        self.note = visitedPlace.note
        self.rating = visitedPlace.rating
        if let location = visitedPlace.location {
            self.locationSnapshot = GeoPointE(from: location)
        }
    }
}

// MARK: - VisitedAreaE Mapping
extension VisitedAreaE {
    func toDomain() -> VisitedArea {
        return VisitedArea(
            areaCode: areaCode,
            sigunguCode: sigunguCode,
            count: count,
            firstVisitedAt: firstVisitedAt,
            lastVisitedAt: lastVisitedAt
        )
    }

    convenience init(from visitedArea: VisitedArea) {
        self.init()
        self.areaCode = visitedArea.areaCode
        self.sigunguCode = visitedArea.sigunguCode
        self.count = visitedArea.count
        self.firstVisitedAt = visitedArea.firstVisitedAt
        self.lastVisitedAt = visitedArea.lastVisitedAt
    }
}

// MARK: - GeoPointE Mapping
extension GeoPointE {
    func toDomain() -> GeoPoint {
        return GeoPoint(lat: lat, lng: lng)
    }

    convenience init(from geoPoint: GeoPoint) {
        self.init()
        self.lat = geoPoint.lat
        self.lng = geoPoint.lng
    }
}

// MARK: - VisitIndexR Mapping
extension VisitIndexR {
    convenience init(from trip: Trip, visitedPlace: VisitedPlace) {
        self.init()
        self.tripId = try! ObjectId(string: trip.id)
        self.entryId = visitedPlace.entryId
        self.placeId = visitedPlace.placeId
        self.placeNameSnapshot = visitedPlace.placeNameSnapshot
        self.thumbnailURLSnapshot = visitedPlace.thumbnailURLSnapshot
        self.areaCode = visitedPlace.areaCode
        self.sigunguCode = visitedPlace.sigunguCode
        self.visitedAt = visitedPlace.addedAt
        self.tagKeys.append(objectsIn: trip.tags)
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}
