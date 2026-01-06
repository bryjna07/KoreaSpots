//
//  ManageTripUseCase.swift
//  KoreaSpots
//
//  Created by YoungJin on 10/10/25.
//

import Foundation
import RxSwift

// MARK: - Create Trip UseCase
protocol CreateTripUseCase {
    func execute(_ trip: Trip) -> Single<Trip>
}

final class CreateTripUseCaseImpl: CreateTripUseCase {
    private let tripRepository: TripRepository

    init(tripRepository: TripRepository) {
        self.tripRepository = tripRepository
    }

    func execute(_ trip: Trip) -> Single<Trip> {
        // Validation
        guard !trip.title.isEmpty else {
            return .error(TripValidationError.emptyTitle)
        }

        guard trip.endDate >= trip.startDate else {
            return .error(TripValidationError.invalidDateRange)
        }

        guard !trip.visitedPlaces.isEmpty else {
            return .error(TripValidationError.noVisitedPlaces)
        }

        return tripRepository.createTrip(trip)
            .flatMap { savedTrip in
                // Use saved trip with new ObjectId for visit index
                return self.tripRepository.syncVisitIndex(for: savedTrip)
                    .andThen(.just(savedTrip))
            }
    }
}

// MARK: - Update Trip UseCase
protocol UpdateTripUseCase {
    func execute(_ trip: Trip) -> Completable
}

final class UpdateTripUseCaseImpl: UpdateTripUseCase {
    private let tripRepository: TripRepository

    init(tripRepository: TripRepository) {
        self.tripRepository = tripRepository
    }

    func execute(_ trip: Trip) -> Completable {
        // Validation
        guard !trip.title.isEmpty else {
            return .error(TripValidationError.emptyTitle)
        }

        guard trip.endDate >= trip.startDate else {
            return .error(TripValidationError.invalidDateRange)
        }

        guard !trip.visitedPlaces.isEmpty else {
            return .error(TripValidationError.noVisitedPlaces)
        }

        // 기존 Trip을 가져와서 삭제된 사진 파일 정리
        return tripRepository.getTrip(id: trip.id)
            .flatMapCompletable { [weak self] existingTrip -> Completable in
                // 기존 Trip이 있으면 삭제된 사진 파일 정리
                if let existingTrip = existingTrip {
                    self?.cleanupDeletedPhotoFiles(
                        oldPhotos: existingTrip.photos,
                        newPhotos: trip.photos
                    )
                }

                return self?.tripRepository.updateTrip(trip)
                    .andThen(self?.tripRepository.syncVisitIndex(for: trip) ?? .empty())
                    ?? .empty()
            }
    }

    /// 삭제된 사진 파일을 기기에서 제거
    private func cleanupDeletedPhotoFiles(oldPhotos: [TripPhoto], newPhotos: [TripPhoto]) {
        let newPhotoIds = Set(newPhotos.map { $0.photoId })
        let fileManager = FileManager.default

        for oldPhoto in oldPhotos {
            // 새로운 사진 목록에 없는 경우 파일 삭제
            if !newPhotoIds.contains(oldPhoto.photoId) {
                guard !oldPhoto.localPath.isEmpty else { continue }

                // 파일이 존재하는 경우에만 삭제 시도
                if fileManager.fileExists(atPath: oldPhoto.localPath) {
                    do {
                        try fileManager.removeItem(atPath: oldPhoto.localPath)
                        print("✅ Deleted removed photo file: \(oldPhoto.localPath)")
                    } catch {
                        print("⚠️ Failed to delete photo file: \(oldPhoto.localPath), error: \(error)")
                    }
                }
            }
        }
    }
}

// MARK: - Delete Trip UseCase
protocol DeleteTripUseCase {
    func execute(tripId: String) -> Completable
}

final class DeleteTripUseCaseImpl: DeleteTripUseCase {
    private let tripRepository: TripRepository

    init(tripRepository: TripRepository) {
        self.tripRepository = tripRepository
    }

    func execute(tripId: String) -> Completable {
        // 삭제 전에 Trip 정보를 가져와서 사진 파일들을 삭제
        return tripRepository.getTrip(id: tripId)
            .flatMapCompletable { [weak self] trip -> Completable in
                guard let self = self else { return .empty() }

                // 기기 내 사진 파일 삭제
                if let trip = trip {
                    self.deletePhotoFiles(from: trip)
                }

                // VisitIndex 및 Trip 삭제
                return self.tripRepository.deleteVisitIndex(for: tripId)
                    .andThen(self.tripRepository.deleteTrip(id: tripId))
            }
    }

    /// 여행에 포함된 모든 사진 파일을 기기에서 삭제
    private func deletePhotoFiles(from trip: Trip) {
        let fileManager = FileManager.default

        for photo in trip.photos {
            guard !photo.localPath.isEmpty else { continue }

            // 파일이 존재하는 경우에만 삭제 시도
            if fileManager.fileExists(atPath: photo.localPath) {
                do {
                    try fileManager.removeItem(atPath: photo.localPath)
                    print("✅ Photo file deleted: \(photo.localPath)")
                } catch {
                    print("⚠️ Failed to delete photo file: \(photo.localPath), error: \(error)")
                }
            }
        }

        // 커버 사진 경로가 photos에 포함되어 있지 않은 경우 별도 삭제
        if let coverPath = trip.coverPhotoPath,
           !coverPath.isEmpty,
           !trip.photos.contains(where: { $0.localPath == coverPath }),
           fileManager.fileExists(atPath: coverPath) {
            do {
                try fileManager.removeItem(atPath: coverPath)
                print("✅ Cover photo file deleted: \(coverPath)")
            } catch {
                print("⚠️ Failed to delete cover photo file: \(coverPath), error: \(error)")
            }
        }
    }
}

// MARK: - Validation Errors
enum TripValidationError: Error, LocalizedError {
    case emptyTitle
    case invalidDateRange
    case noVisitedPlaces

    var errorDescription: String? {
        switch self {
        case .emptyTitle:
            return "여행 제목을 입력해주세요."
        case .invalidDateRange:
            return "종료일은 시작일 이후여야 합니다."
        case .noVisitedPlaces:
            return "최소 1개 이상의 관광지를 추가해주세요."
        }
    }
}
