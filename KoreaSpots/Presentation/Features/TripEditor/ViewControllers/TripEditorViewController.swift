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

        // Setup Places callbacks
        tripEditorView.onAddPlacesTapped = { [weak self] in
            self?.showPlaceSelector()
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

        reactor.pulse(\.$saveSuccess)
            .compactMap { $0 }
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(with: self, onNext: { owner, _ in
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
    }

    // MARK: - Actions

    @objc private func cancelTapped() {
        navigationController?.popViewController(animated: true)
    }

    private func showPlaceSelector() {
        let selectedIds = reactor?.currentState.visitedPlaces.map { $0.placeId } ?? []
        print("🔍 Opening PlaceSelector with pre-selected: \(selectedIds)")

        var placeSelectorReactorRef: PlaceSelectorReactor?

        let placeSelectorVC = appContainer.makePlaceSelectorViewController(
            maxSelectionCount: 20,
            preSelectedPlaceIds: selectedIds
        ) { [weak self] selectedIds in
            print("✅ PlaceSelector confirmed with IDs: \(selectedIds)")

            // Get selectedPlaces from PlaceSelector reactor
            guard let placeSelectorReactor = placeSelectorReactorRef else {
                print("❌ Failed to get PlaceSelectorReactor")
                return
            }

            let selectedPlaces = selectedIds.compactMap { placeSelectorReactor.currentState.selectedPlaces[$0] }
            print("📦 Selected Places: \(selectedPlaces.map { "\($0.title) (ID: \($0.contentId))" })")

            // Convert to VisitedPlace
            let visitedPlaces = selectedPlaces.enumerated().map { index, place in
                VisitedPlace(
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
                    )
                )
            }

            print("🎯 Final VisitedPlaces: \(visitedPlaces.map { "\($0.placeNameSnapshot) (ID: \($0.placeId))" })")

            // Directly set places instead of loading from API
            self?.reactor?.action.onNext(.setPlaces(visitedPlaces))
        }

        // Store reactor reference
        placeSelectorReactorRef = placeSelectorVC.reactor as? PlaceSelectorReactor

        let nav = UINavigationController(rootViewController: placeSelectorVC)
        present(nav, animated: true)
    }
}
