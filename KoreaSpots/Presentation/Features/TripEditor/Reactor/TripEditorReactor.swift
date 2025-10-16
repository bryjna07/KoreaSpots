//
//  TripEditorReactor.swift
//  KoreaSpots
//
//  Created by YoungJin on 10/10/25.
//

import Foundation
import ReactorKit
import RxSwift

final class TripEditorReactor: Reactor {

    enum Action {
        case updateTitle(String)
        case updateStartDate(Date)
        case updateEndDate(Date)
        case updateMemo(String)
        case addPlaces([String])
        case setPlaces([VisitedPlace]) // Directly set places without API call
        case removePlace(String)
        case reorderPlaces([String])
        case save
    }

    enum Mutation {
        case setTitle(String)
        case setStartDate(Date)
        case setEndDate(Date)
        case setMemo(String)
        case setPlaces([VisitedPlace])
        case setLoading(Bool)
        case setError(String)
        case setSaveSuccess
    }

    struct State {
        var trip: Trip?
        var title: String = ""
        var startDate: Date = Date()
        var endDate: Date = Date()
        var memo: String = ""
        var visitedPlaces: [VisitedPlace] = []
        var isLoading: Bool = false
        var errorMessage: String?

        @Pulse var saveSuccess: Void?

        var isValid: Bool {
            !title.isEmpty && !visitedPlaces.isEmpty && startDate <= endDate
        }
    }

    let initialState: State

    private let createTripUseCase: CreateTripUseCase
    private let updateTripUseCase: UpdateTripUseCase
    private let tourRepository: TourRepository

    init(
        trip: Trip?,
        createTripUseCase: CreateTripUseCase,
        updateTripUseCase: UpdateTripUseCase,
        tourRepository: TourRepository
    ) {
        self.createTripUseCase = createTripUseCase
        self.updateTripUseCase = updateTripUseCase
        self.tourRepository = tourRepository

        if let trip = trip {
            self.initialState = State(
                trip: trip,
                title: trip.title,
                startDate: trip.startDate,
                endDate: trip.endDate,
                memo: trip.memo,
                visitedPlaces: trip.visitedPlaces
            )
        } else {
            self.initialState = State()
        }
    }

    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .updateTitle(let title):
            return .just(.setTitle(title))

        case .updateStartDate(let date):
            return .just(.setStartDate(date))

        case .updateEndDate(let date):
            return .just(.setEndDate(date))

        case .updateMemo(let memo):
            return .just(.setMemo(memo))

        case .addPlaces(let placeIds):
            return loadPlaces(placeIds)

        case .setPlaces(let places):
            return .just(.setPlaces(places))

        case .removePlace(let placeId):
            return .just(.setPlaces(currentState.visitedPlaces.filter { $0.placeId != placeId }))

        case .reorderPlaces(let orderedIds):
            let reordered = orderedIds.compactMap { id in
                currentState.visitedPlaces.first { $0.placeId == id }
            }
            return .just(.setPlaces(reordered))

        case .save:
            return saveTrip()
        }
    }

    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state

        switch mutation {
        case .setTitle(let title):
            newState.title = title

        case .setStartDate(let date):
            newState.startDate = date

        case .setEndDate(let date):
            newState.endDate = date

        case .setMemo(let memo):
            newState.memo = memo

        case .setPlaces(let places):
            newState.visitedPlaces = places

        case .setLoading(let isLoading):
            newState.isLoading = isLoading

        case .setError(let error):
            newState.errorMessage = error
            newState.isLoading = false

        case .setSaveSuccess:
            newState.saveSuccess = ()
        }

        return newState
    }

    // MARK: - Private Methods

    private func loadPlaces(_ placeIds: [String]) -> Observable<Mutation> {
        guard !placeIds.isEmpty else {
            return .just(.setPlaces([]))
        }

        print("🔍 Loading places for IDs: \(placeIds)")

        let observables = placeIds.map { placeId in
            tourRepository.getPlaceDetail(contentId: placeId)
                .asObservable()
                .catch { error in
                    print("❌ Failed to load place \(placeId): \(error)")
                    return .empty()
                }
        }

        return Observable.zip(observables)
            .map { places in
                print("✅ Loaded \(places.count) places")
                let visitedPlaces = places.enumerated().map { index, place in
                    let visitedPlace = VisitedPlace(
                        entryId: UUID().uuidString,
                        placeId: place.contentId,
                        placeNameSnapshot: place.title,
                        thumbnailURLSnapshot: place.imageURL,
                        areaCode: place.areaCode,
                        sigunguCode: place.sigunguCode,
                        addedAt: Date(),
                        order: index,
                        note: nil,
                        rating: nil,
                        location: GeoPoint(
                            lat: place.mapY ?? 0,
                            lng: place.mapX ?? 0
                        ),
                        visitedTime: nil,
                        stayDuration: nil,
                        routeIndex: nil,
                        photos: []
                    )
                    print("📍 Place: \(visitedPlace.placeNameSnapshot), Image: \(visitedPlace.thumbnailURLSnapshot ?? "nil")")
                    return visitedPlace
                }
                return .setPlaces(visitedPlaces)
            }
            .catch { error in
                print("❌ Failed to load places: \(error)")
                return .just(.setError("관광지 정보를 불러오는데 실패했습니다."))
            }
    }

    private func saveTrip() -> Observable<Mutation> {
        guard currentState.isValid else {
            return .just(.setError("필수 항목을 입력해주세요"))
        }

        let visitedAreas = extractVisitedAreas()

        if let existingTrip = currentState.trip {
            let updatedTrip = Trip(
                id: existingTrip.id,
                title: currentState.title,
                coverPhotoPath: existingTrip.coverPhotoPath,
                startDate: currentState.startDate,
                endDate: currentState.endDate,
                memo: currentState.memo.isEmpty ? "" : currentState.memo,
                visitedPlaces: currentState.visitedPlaces,
                visitedAreas: visitedAreas,
                tags: existingTrip.tags,
                createdAt: existingTrip.createdAt,
                updatedAt: Date(),
                isRouteTrackingEnabled: existingTrip.isRouteTrackingEnabled,
                totalDistance: existingTrip.totalDistance,
                travelStyle: existingTrip.travelStyle
            )

            return .concat([
                .just(.setLoading(true)),
                updateTripUseCase.execute(updatedTrip)
                    .asObservable()
                    .flatMap { _ -> Observable<Mutation> in
                        return .just(.setSaveSuccess)
                    }
                    .catch { error in
                        return .just(.setError("저장 실패: \(error.localizedDescription)"))
                    }
            ])
        } else {
            let newTrip = Trip(
                id: "",
                title: currentState.title,
                coverPhotoPath: nil,
                startDate: currentState.startDate,
                endDate: currentState.endDate,
                memo: currentState.memo.isEmpty ? "" : currentState.memo,
                visitedPlaces: currentState.visitedPlaces,
                visitedAreas: visitedAreas,
                tags: [],
                createdAt: Date(),
                updatedAt: Date(),
                isRouteTrackingEnabled: false,
                totalDistance: nil,
                travelStyle: nil
            )

            return .concat([
                .just(.setLoading(true)),
                createTripUseCase.execute(newTrip)
                    .asObservable()
                    .flatMap { _ -> Observable<Mutation> in
                        return .just(.setSaveSuccess)
                    }
                    .catch { error in
                        return .just(.setError("저장 실패: \(error.localizedDescription)"))
                    }
            ])
        }
    }

    private func extractVisitedAreas() -> [VisitedArea] {
        // Extract unique area codes from visited places
        // This is a simplified version - actual implementation would use proper area data
        return []
    }
}
