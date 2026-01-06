//
//  TripDetailReactor.swift
//  KoreaSpots
//
//  Created by Watson22_YJ on 11/16/25.
//

import Foundation
import ReactorKit
import RxSwift

final class TripDetailReactor: Reactor {

    // MARK: - Action

    enum Action {
        case viewDidLoad
        case reloadTrip
        case selectPlace(VisitedPlace)
        case selectPhoto(TripPhoto)
        case deletePhoto(TripPhoto)
        case addPhotos([TripPhoto])
    }

    // MARK: - Mutation

    enum Mutation {
        case setTrip(Trip)
        case setSelectedPlace(VisitedPlace?)
        case setAllPhotos([TripPhoto])
        case setError(String?)
    }

    // MARK: - State

    struct State {
        var trip: Trip
        var selectedPlace: VisitedPlace?
        var allPhotos: [TripPhoto] = []
        var statistics: TripStatistics?
        var error: String?
    }

    // MARK: - Properties

    let initialState: State
    private let tripRepository: TripRepository

    // MARK: - Initialization

    init(trip: Trip, tripRepository: TripRepository) {
        self.tripRepository = tripRepository
        self.initialState = State(
            trip: trip,
            statistics: TripStatistics(
                totalTripCount: 1,
                totalPlaceCount: trip.visitedPlaceCount,
                mostVisitedAreas: trip.visitedAreas
            )
        )
    }

    // MARK: - Mutate

    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewDidLoad:
            let trip = currentState.trip
            // Sort photos: cover photo first, then by order
            let allPhotos = trip.photos.sorted { $0.order < $1.order }
            return .concat([
                .just(.setTrip(trip)),
                .just(.setAllPhotos(allPhotos))
            ])

        case .reloadTrip:
            return reloadTrip()

        case .selectPlace(let place):
            return .just(.setSelectedPlace(place))

        case .selectPhoto:
            // Photo viewer will be handled in ViewController
            return .empty()

        case .deletePhoto(let photo):
            return deletePhoto(photo)

        case .addPhotos(let photos):
            return addPhotos(photos)
        }
    }

    // MARK: - Reduce

    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state

        switch mutation {
        case .setTrip(let trip):
            newState.trip = trip

        case .setSelectedPlace(let place):
            newState.selectedPlace = place

        case .setAllPhotos(let photos):
            newState.allPhotos = photos

        case .setError(let error):
            newState.error = error
        }

        return newState
    }

    // MARK: - Private Methods

    private func reloadTrip() -> Observable<Mutation> {
        let tripId = currentState.trip.id
        return tripRepository.getTrip(id: tripId)
            .asObservable()
            .flatMap { trip -> Observable<Mutation> in
                guard let trip = trip else {
                    return .just(.setError("여행 기록을 찾을 수 없습니다."))
                }
                let allPhotos = trip.photos.sorted { $0.order < $1.order }
                return .concat([
                    .just(.setTrip(trip)),
                    .just(.setAllPhotos(allPhotos))
                ])
            }
            .catch { error in
                return .just(.setError(error.localizedDescription))
            }
    }

    private func deletePhoto(_ photo: TripPhoto) -> Observable<Mutation> {
        var updatedTrip = currentState.trip

        // Remove photo from trip's photos
        var updatedPhotos = updatedTrip.photos.filter { $0.photoId != photo.photoId }

        // Reorder remaining photos
        updatedPhotos = updatedPhotos.enumerated().map { index, photo in
            TripPhoto(
                photoId: photo.photoId,
                localPath: photo.localPath,
                caption: photo.caption,
                takenAt: photo.takenAt,
                isCover: index == 0, // First photo becomes cover
                order: index,
                width: photo.width,
                height: photo.height,
                cloudURL: photo.cloudURL,
                isUploaded: photo.isUploaded
            )
        }

        updatedTrip = Trip(
            id: updatedTrip.id,
            title: updatedTrip.title,
            coverPhotoPath: updatedTrip.coverPhotoPath,
            startDate: updatedTrip.startDate,
            endDate: updatedTrip.endDate,
            memo: updatedTrip.memo,
            visitedPlaces: updatedTrip.visitedPlaces,
            photos: updatedPhotos,
            visitedAreas: updatedTrip.visitedAreas,
            tags: updatedTrip.tags,
            createdAt: updatedTrip.createdAt,
            updatedAt: Date(),
            isRouteTrackingEnabled: updatedTrip.isRouteTrackingEnabled,
            totalDistance: updatedTrip.totalDistance,
            travelStyle: updatedTrip.travelStyle
        )

        return tripRepository.updateTrip(updatedTrip)
            .asObservable()
            .flatMap { _ -> Observable<Mutation> in
                // Sort photos: cover photo first, then by takenAt
                let allPhotos = updatedTrip.photos.sorted { photo1, photo2 in
                    if photo1.isCover { return true }
                    if photo2.isCover { return false }
                    return photo1.takenAt < photo2.takenAt
                }
                return .concat([
                    .just(.setTrip(updatedTrip)),
                    .just(.setAllPhotos(allPhotos))
                ])
            }
            .catch { error in
                return .just(.setError(error.localizedDescription))
            }
    }

    private func addPhotos(_ photos: [TripPhoto]) -> Observable<Mutation> {
        var updatedTrip = currentState.trip

        // Add new photos to trip's photos
        var updatedPhotos = updatedTrip.photos + photos

        // Reorder all photos
        updatedPhotos = updatedPhotos.enumerated().map { index, photo in
            TripPhoto(
                photoId: photo.photoId,
                localPath: photo.localPath,
                caption: photo.caption,
                takenAt: photo.takenAt,
                isCover: index == 0,
                order: index,
                width: photo.width,
                height: photo.height,
                cloudURL: photo.cloudURL,
                isUploaded: photo.isUploaded
            )
        }

        updatedTrip = Trip(
            id: updatedTrip.id,
            title: updatedTrip.title,
            coverPhotoPath: updatedTrip.coverPhotoPath,
            startDate: updatedTrip.startDate,
            endDate: updatedTrip.endDate,
            memo: updatedTrip.memo,
            visitedPlaces: updatedTrip.visitedPlaces,
            photos: updatedPhotos,
            visitedAreas: updatedTrip.visitedAreas,
            tags: updatedTrip.tags,
            createdAt: updatedTrip.createdAt,
            updatedAt: Date(),
            isRouteTrackingEnabled: updatedTrip.isRouteTrackingEnabled,
            totalDistance: updatedTrip.totalDistance,
            travelStyle: updatedTrip.travelStyle
        )

        // Sort photos: cover photo first, then by takenAt
        let allPhotos = updatedPhotos.sorted { photo1, photo2 in
            if photo1.isCover { return true }
            if photo2.isCover { return false }
            return photo1.takenAt < photo2.takenAt
        }

        // First update UI immediately, then persist to storage
        return .concat([
            .just(.setTrip(updatedTrip)),
            .just(.setAllPhotos(allPhotos)),
            tripRepository.updateTrip(updatedTrip)
                .asObservable()
                .flatMap { _ -> Observable<Mutation> in
                    return .empty()
                }
                .catch { error in
                    return .just(.setError(error.localizedDescription))
                }
        ])
    }
}

