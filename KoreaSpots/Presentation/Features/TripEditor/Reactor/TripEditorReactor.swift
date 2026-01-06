//
//  TripEditorReactor.swift
//  KoreaSpots
//
//  Created by YoungJin on 10/10/25.
//

import Foundation
import ReactorKit
import RxSwift
import UIKit

final class TripEditorReactor: Reactor {

    enum Action {
        case updateTitle(String)
        case updateStartDate(Date)
        case updateEndDate(Date)
        case updateMemo(String)
        case addPlaces([String])
        case setPlaces([VisitedPlace])
        case removePlace(String)
        case reorderPlaces([String])
        case addPhotos([UIImage])
        case deletePhoto(TripPhoto)
        case save
    }

    enum Mutation {
        case setTitle(String)
        case setStartDate(Date)
        case setEndDate(Date)
        case setMemo(String)
        case setPlaces([VisitedPlace])
        case setPhotos([TripPhoto])
        case setLoading(Bool)
        case setError(String)
        case setSaveSuccess
        case setShouldDismiss(Bool)
        case showAlert(String)
    }

    struct State {
        var trip: Trip?
        var title: String = ""
        var startDate: Date = Date()
        var endDate: Date = Date()
        var memo: String = ""
        var visitedPlaces: [VisitedPlace] = []
        var photos: [TripPhoto] = []
        var isLoading: Bool = false
        var errorMessage: String?
        var shouldDismiss: Bool = false

        @Pulse var saveSuccess: Void?
        @Pulse var alertMessage: String?

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
                visitedPlaces: trip.visitedPlaces,
                photos: trip.photos
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

        case .addPhotos(let images):
            return addPhotos(images)

        case .deletePhoto(let photo):
            let updatedPhotos = currentState.photos.filter { $0.photoId != photo.photoId }
            // Reorder remaining photos
            let reorderedPhotos = updatedPhotos.enumerated().map { index, p in
                TripPhoto(
                    photoId: p.photoId,
                    localPath: p.localPath,
                    caption: p.caption,
                    takenAt: p.takenAt,
                    isCover: index == 0, // First photo is now cover
                    order: index,
                    width: p.width,
                    height: p.height,
                    cloudURL: p.cloudURL,
                    isUploaded: p.isUploaded
                )
            }
            // Delete file from disk (파일이 존재하는 경우에만)
            if !photo.localPath.isEmpty,
               FileManager.default.fileExists(atPath: photo.localPath) {
                try? FileManager.default.removeItem(atPath: photo.localPath)
            }
            return .just(.setPhotos(reorderedPhotos))

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

        case .setPhotos(let photos):
            newState.photos = photos

        case .setLoading(let isLoading):
            newState.isLoading = isLoading

        case .setError(let error):
            newState.errorMessage = error
            newState.isLoading = false

        case .setSaveSuccess:
            newState.saveSuccess = ()

        case .setShouldDismiss(let shouldDismiss):
            print("📍 Reduce: setShouldDismiss(\(shouldDismiss))")
            newState.shouldDismiss = shouldDismiss

        case .showAlert(let message):
            newState.alertMessage = message
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
                        routeIndex: nil
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

        // Mock 모드 체크
        guard AppStateManager.shared.canPerformWriteOperation() else {
            let message = """
            현재 서버 오류로 인해
            예시 데이터를 표시 중입니다.

            예시 데이터 사용 중에는
            이 기능을 사용할 수 없습니다.
            """
            return .just(.showAlert(message))
        }

        let visitedAreas = extractVisitedAreas()

        // First photo is cover photo
        let coverPhotoPath: String? = currentState.photos.first?.localPath

        if let existingTrip = currentState.trip {
            let updatedTrip = Trip(
                id: existingTrip.id,
                title: currentState.title,
                coverPhotoPath: coverPhotoPath,
                startDate: currentState.startDate,
                endDate: currentState.endDate,
                memo: currentState.memo.isEmpty ? "" : currentState.memo,
                visitedPlaces: currentState.visitedPlaces,
                photos: currentState.photos,
                visitedAreas: visitedAreas,
                tags: existingTrip.tags,
                createdAt: existingTrip.createdAt,
                updatedAt: Date(),
                isRouteTrackingEnabled: existingTrip.isRouteTrackingEnabled,
                totalDistance: existingTrip.totalDistance,
                travelStyle: existingTrip.travelStyle
            )

            print("🔄 Starting update trip...")
            return .concat([
                .just(.setLoading(true)),
                updateTripUseCase.execute(updatedTrip)
                    .andThen(Observable.just(()))
                    .do(onNext: { _ in
                        print("✅ Update trip succeeded, emitting shouldDismiss")
                    })
                    .flatMap { _ -> Observable<Mutation> in
                        return Observable.from([
                            Mutation.setLoading(false),
                            Mutation.setSaveSuccess,
                            Mutation.setShouldDismiss(true)
                        ])
                    }
                    .catch { error in
                        print("❌ Update trip failed: \(error)")
                        return Observable.from([
                            Mutation.setLoading(false),
                            Mutation.setError("저장 실패: \(error.localizedDescription)")
                        ])
                    }
            ])
        } else {
            let newTrip = Trip(
                id: "",
                title: currentState.title,
                coverPhotoPath: coverPhotoPath,
                startDate: currentState.startDate,
                endDate: currentState.endDate,
                memo: currentState.memo.isEmpty ? "" : currentState.memo,
                visitedPlaces: currentState.visitedPlaces,
                photos: currentState.photos,
                visitedAreas: visitedAreas,
                tags: [],
                createdAt: Date(),
                updatedAt: Date(),
                isRouteTrackingEnabled: false,
                totalDistance: nil,
                travelStyle: nil
            )

            print("🔄 Starting create trip...")
            return .concat([
                .just(.setLoading(true)),
                createTripUseCase.execute(newTrip)
                    .asObservable()
                    .flatMap { _ -> Observable<Mutation> in
                        print("✅ Create trip succeeded, emitting shouldDismiss")
                        return Observable.from([
                            Mutation.setLoading(false),
                            Mutation.setSaveSuccess,
                            Mutation.setShouldDismiss(true)
                        ])
                    }
                    .catch { error in
                        print("❌ Create trip failed: \(error)")
                        return Observable.from([
                            Mutation.setLoading(false),
                            Mutation.setError("저장 실패: \(error.localizedDescription)")
                        ])
                    }
            ])
        }
    }

    private func addPhotos(_ images: [UIImage]) -> Observable<Mutation> {
        var newPhotos: [TripPhoto] = []
        let currentCount = currentState.photos.count

        for (index, image) in images.enumerated() {
            if let localPath = savePhotoToLocal(image: image) {
                let order = currentCount + index
                let photo = TripPhoto(
                    photoId: UUID().uuidString,
                    localPath: localPath,
                    caption: nil,
                    takenAt: Date(),
                    isCover: order == 0, // First photo is cover
                    order: order,
                    width: Int(image.size.width),
                    height: Int(image.size.height),
                    cloudURL: nil,
                    isUploaded: false
                )
                newPhotos.append(photo)
            }
        }

        let allPhotos = currentState.photos + newPhotos

        // Update isCover for all photos (first one is cover)
        let updatedPhotos = allPhotos.enumerated().map { index, photo in
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

        return .just(.setPhotos(updatedPhotos))
    }

    private func savePhotoToLocal(image: UIImage) -> String? {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let photosDir = documentsPath.appendingPathComponent("TripPhotos")

        try? FileManager.default.createDirectory(at: photosDir, withIntermediateDirectories: true)

        let fileName = "\(UUID().uuidString).jpg"
        let fileURL = photosDir.appendingPathComponent(fileName)

        guard let imageData = image.jpegData(compressionQuality: 0.8) else { return nil }

        do {
            try imageData.write(to: fileURL)
            return fileURL.path
        } catch {
            print("Failed to save photo: \(error)")
            return nil
        }
    }

    private func extractVisitedAreas() -> [VisitedArea] {
        return []
    }
}
