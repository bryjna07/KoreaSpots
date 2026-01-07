//
//  TripEditorViewController.swift
//  KoreaSpots
//
//  Created by YoungJin on 10/10/25.
//

import UIKit
import ReactorKit
import RxSwift
import RxCocoa
import PhotosUI
import MapKit

final class TripEditorViewController: BaseViewController, View {

    // MARK: - Properties
    var disposeBag = DisposeBag()
    private var tripEditorView: TripEditorView { return view as! TripEditorView }
    private let appContainer: AppContainer

    // MARK: - Initialization

    init(reactor: TripEditorReactor, appContainer: AppContainer) {
        self.appContainer = appContainer
        super.init(nibName: nil, bundle: nil)
        self.reactor = reactor
    }

    // MARK: - Lifecycle

    override func loadView() {
        view = TripEditorView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupMapView()
    }

    // MARK: - Setup

    private func setupNavigationBar() {
        title = reactor?.currentState.trip == nil ? "새 여행 기록" : "여행 기록 수정"
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(cancelTapped)
        )
    }

    private func setupMapView() {
        tripEditorView.routeMapView.delegate = self
    }

    // MARK: - Binding

    func bind(reactor: TripEditorReactor) {
        // Setup Form callbacks (direct binding to TripFormView)
        tripEditorView.formView.onTitleChanged = { [weak reactor] text in
            reactor?.action.onNext(.updateTitle(text))
        }

        tripEditorView.formView.onStartDateChanged = { [weak reactor] date in
            reactor?.action.onNext(.updateStartDate(date))
        }

        tripEditorView.formView.onEndDateChanged = { [weak reactor] date in
            reactor?.action.onNext(.updateEndDate(date))
        }

        tripEditorView.formView.onMemoChanged = { [weak reactor] text in
            reactor?.action.onNext(.updateMemo(text))
        }

        // Setup Photos callbacks
        tripEditorView.onAddPhotosTapped = { [weak self] in
            self?.showPhotoPicker()
        }

        tripEditorView.onPhotoDeleteTapped = { [weak reactor] photo in
            reactor?.action.onNext(.deletePhoto(photo))
        }

        // Setup Places callbacks
        tripEditorView.onAddPlacesTapped = { [weak self] in
            self?.showPlaceSelector()
        }

        // Places reorder callback
        tripEditorView.onPlacesReordered = { [weak reactor] reorderedPlaces in
            reactor?.action.onNext(.setPlaces(reorderedPlaces))
        }

        // Places delete callback
        tripEditorView.onPlaceDeleteTapped = { [weak reactor] place in
            reactor?.action.onNext(.removePlace(place.placeId))
        }

        // Save button
        tripEditorView.saveButton.rx.tap
            .map { Reactor.Action.save }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        // State: Form fields
        reactor.state
            .map { ($0.title, $0.startDate, $0.endDate, $0.memo) }
            .distinctUntilChanged { lhs, rhs in
                let titleEqual = lhs.0 == rhs.0
                let startDateEqual = lhs.1 == rhs.1
                let endDateEqual = lhs.2 == rhs.2
                let memoEqual = lhs.3 == rhs.3
                return titleEqual && startDateEqual && endDateEqual && memoEqual
            }
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(with: self, onNext: { owner, data in
                owner.tripEditorView.updateForm(
                    title: data.0,
                    startDate: data.1,
                    endDate: data.2,
                    memo: data.3
                )
            })
            .disposed(by: disposeBag)

        // State: Photos
        reactor.state
            .map { $0.photos }
            .distinctUntilChanged { $0.map { $0.photoId } == $1.map { $0.photoId } }
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(with: self, onNext: { owner, photos in
                owner.tripEditorView.updatePhotos(photos)
            })
            .disposed(by: disposeBag)

        // State: Places list
        reactor.state
            .map { $0.visitedPlaces }
            .distinctUntilChanged { $0.map { $0.placeId } == $1.map { $0.placeId } }
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(with: self, onNext: { owner, places in
                owner.tripEditorView.updatePlaces(places)
            })
            .disposed(by: disposeBag)

        reactor.state.map { $0.isValid }
            .distinctUntilChanged()
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(with: self, onNext: { owner, isValid in
                owner.tripEditorView.saveButton.isEnabled = isValid
                owner.tripEditorView.saveButton.alpha = isValid ? 1.0 : 0.5
            })
            .disposed(by: disposeBag)

        // State: Dismiss on save success
        reactor.state
            .map { $0.shouldDismiss }
            .do(onNext: { value in
                print("🔔 shouldDismiss state changed: \(value)")
            })
            .distinctUntilChanged()
            .filter { $0 }
            .observe(on: MainScheduler.instance)
            .subscribe(with: self, onNext: { owner, _ in
                print("✅ shouldDismiss = true, popping view controller")
                print("📱 navigationController: \(String(describing: owner.navigationController))")
                owner.navigationController?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)

        reactor.state.map { $0.errorMessage }
            .compactMap { $0 }
            .distinctUntilChanged()
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(with: self, onNext: { owner, message in
                owner.showToast(message: message)
            })
            .disposed(by: disposeBag)

        // Alert 메시지 바인딩
        reactor.pulse(\.$alertMessage)
            .compactMap { $0 }
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(with: self, onNext: { owner, message in
                owner.showMockModeAlert(message: message)
            })
            .disposed(by: disposeBag)
    }

    // MARK: - Alert Helper
    private func showMockModeAlert(message: String) {
        let alert = UIAlertController(
            title: "기능 사용 제한",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }

    // MARK: - Actions

    @objc private func cancelTapped() {
        navigationController?.popViewController(animated: true)
    }

    private func showPhotoPicker() {
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = 10 // Allow multiple photos
        configuration.filter = .images

        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true)
    }

    private func showPlaceSelector() {
        let existingVisitedPlaces = reactor?.currentState.visitedPlaces ?? []
        let selectedIds = existingVisitedPlaces.map { $0.placeId }

        // 기존 VisitedPlace를 Place 객체로 변환하여 전달
        let preSelectedPlaces = existingVisitedPlaces.map { visited in
            Place(
                contentId: visited.placeId,
                title: visited.placeNameSnapshot,
                address: "",
                imageURL: visited.thumbnailURLSnapshot,
                mapX: visited.location?.lng,
                mapY: visited.location?.lat,
                tel: nil,
                overview: nil,
                contentTypeId: nil,
                areaCode: visited.areaCode,
                sigunguCode: visited.sigunguCode,
                cat1: nil,
                cat2: nil,
                cat3: nil,
                distance: nil,
                modifiedTime: nil,
                eventMeta: nil,
                isCustom: false,
                customPlaceId: nil,
                userProvidedImagePath: nil
            )
        }

        print("🔍 Opening PlaceSelector with pre-selected: \(selectedIds)")

        var placeSelectorReactorRef: PlaceSelectorReactor?

        // 기존 VisitedPlace 정보를 보관 (메타데이터 유지용)
        let existingVisitedPlacesDict = Dictionary(
            uniqueKeysWithValues: existingVisitedPlaces.map { ($0.placeId, $0) }
        )

        let placeSelectorVC = appContainer.makePlaceSelectorViewController(
            maxSelectionCount: 20,
            preSelectedPlaceIds: selectedIds,
            preSelectedPlaces: preSelectedPlaces
        ) { [weak self] selectedIds in
            print("✅ PlaceSelector confirmed with IDs: \(selectedIds)")

            // Get selectedPlaces from PlaceSelector reactor
            guard let placeSelectorReactor = placeSelectorReactorRef else {
                print("❌ Failed to get PlaceSelectorReactor")
                return
            }

            let selectedPlacesDict = placeSelectorReactor.currentState.selectedPlaces
            let selectedIdSet = Set(selectedIds)

            // 1. 기존 장소 중 여전히 선택된 것들 (기존 순서 유지)
            var orderedPlaces: [Place] = []
            for existingPlace in existingVisitedPlaces {
                if selectedIdSet.contains(existingPlace.placeId),
                   let place = selectedPlacesDict[existingPlace.placeId] {
                    orderedPlaces.append(place)
                }
            }

            // 2. 새로 추가된 장소들 (기존에 없던 것들)
            let existingIds = Set(existingVisitedPlaces.map { $0.placeId })
            for id in selectedIds {
                if !existingIds.contains(id), let place = selectedPlacesDict[id] {
                    orderedPlaces.append(place)
                }
            }

            print("📦 Ordered Places: \(orderedPlaces.map { "\($0.title) (ID: \($0.contentId))" })")

            // Convert to VisitedPlace (기존 메타데이터 유지)
            let visitedPlaces = orderedPlaces.enumerated().map { index, place in
                // 기존에 있던 장소인 경우 메타데이터 유지
                if let existing = existingVisitedPlacesDict[place.contentId] {
                    return VisitedPlace(
                        entryId: existing.entryId,
                        placeId: place.contentId,
                        placeNameSnapshot: place.title,
                        thumbnailURLSnapshot: place.imageURL,
                        areaCode: place.areaCode,
                        sigunguCode: place.sigunguCode ?? 0,
                        addedAt: existing.addedAt,
                        order: index,
                        note: existing.note,
                        rating: existing.rating,
                        location: GeoPoint(
                            lat: place.mapY ?? 0,
                            lng: place.mapX ?? 0
                        ),
                        visitedTime: existing.visitedTime,
                        stayDuration: existing.stayDuration,
                        routeIndex: existing.routeIndex
                    )
                } else {
                    // 새로 추가된 장소
                    return VisitedPlace(
                        entryId: UUID().uuidString,
                        placeId: place.contentId,
                        placeNameSnapshot: place.title,
                        thumbnailURLSnapshot: place.imageURL,
                        areaCode: place.areaCode,
                        sigunguCode: place.sigunguCode ?? 0,
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
                }
            }

            print("🎯 Final VisitedPlaces: \(visitedPlaces.map { "\($0.placeNameSnapshot) (ID: \($0.placeId))" })")

            // Directly set places instead of loading from API
            self?.reactor?.action.onNext(.setPlaces(visitedPlaces))
        }

        // Store reactor reference
        placeSelectorReactorRef = placeSelectorVC.reactor

        let nav = UINavigationController(rootViewController: placeSelectorVC)
        present(nav, animated: true)
    }
}

// MARK: - PHPickerViewControllerDelegate

extension TripEditorViewController: PHPickerViewControllerDelegate {

    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)

        guard !results.isEmpty else { return }

        let dispatchGroup = DispatchGroup()
        var loadedImages: [(Int, UIImage)] = []

        for (index, result) in results.enumerated() {
            dispatchGroup.enter()

            result.itemProvider.loadObject(ofClass: UIImage.self) { object, error in
                defer { dispatchGroup.leave() }

                guard let image = object as? UIImage, error == nil else {
                    print("Failed to load image: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }

                loadedImages.append((index, image))
            }
        }

        dispatchGroup.notify(queue: .main) { [weak self] in
            // Sort by original index to maintain order
            let sortedImages = loadedImages.sorted { $0.0 < $1.0 }.map { $0.1 }
            if !sortedImages.isEmpty {
                self?.reactor?.action.onNext(.addPhotos(sortedImages))
            }
        }
    }
}

// MARK: - MKMapViewDelegate

extension TripEditorViewController: MKMapViewDelegate {

    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let polyline = overlay as? MKPolyline {
            let renderer = MKPolylineRenderer(polyline: polyline)
            renderer.strokeColor = UIColor.primary
            renderer.lineWidth = 3.0
            return renderer
        }
        return MKOverlayRenderer(overlay: overlay)
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !(annotation is MKUserLocation) else { return nil }

        let identifier = "RouteAnnotation"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView

        if annotationView == nil {
            annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true
        } else {
            annotationView?.annotation = annotation
        }

        annotationView?.markerTintColor = .primary

        return annotationView
    }
}
