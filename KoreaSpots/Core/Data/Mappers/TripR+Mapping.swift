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
            updatedAt: updatedAt,
            isRouteTrackingEnabled: isRouteTrackingEnabled,
            totalDistance: totalDistance,
            travelStyle: travelStyle
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
        self.isRouteTrackingEnabled = trip.isRouteTrackingEnabled
        self.totalDistance = trip.totalDistance
        self.travelStyle = trip.travelStyle
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
            location: locationSnapshot?.toDomain(),
            visitedTime: visitedTime,
            stayDuration: stayDuration,
            routeIndex: routeIndex,
            photos: photos.map { $0.toDomain() }
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
        self.visitedTime = visitedPlace.visitedTime
        self.stayDuration = visitedPlace.stayDuration
        self.routeIndex = visitedPlace.routeIndex
        self.photos.append(objectsIn: visitedPlace.photos.map { VisitPhotoE(from: $0) })
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

// MARK: - VisitPhotoE Mapping
extension VisitPhotoE {
    func toDomain() -> VisitPhoto {
        return VisitPhoto(
            photoId: photoId,
            localPath: localPath,
            caption: caption,
            takenAt: takenAt,
            isCover: isCover,
            order: order,
            width: width,
            height: height,
            cloudURL: cloudURL,
            isUploaded: isUploaded
        )
    }

    convenience init(from photo: VisitPhoto) {
        self.init()
        self.photoId = photo.photoId
        self.localPath = photo.localPath
        self.caption = photo.caption
        self.takenAt = photo.takenAt
        self.isCover = photo.isCover
        self.order = photo.order
        self.width = photo.width
        self.height = photo.height
        self.cloudURL = photo.cloudURL
        self.isUploaded = photo.isUploaded
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
