//
//  PlaceSelectorViewController.swift
//  KoreaSpots
//
//  Created by YoungJin on 10/10/25.
//

import UIKit
import ReactorKit
import RxSwift
import RxCocoa

final class PlaceSelectorViewController: BaseViewController, View {

    // MARK: - Properties
    var disposeBag = DisposeBag()
    private var placeSelectorView: PlaceSelectorView { return view as! PlaceSelectorView }
    private let maxSelectionCount: Int
    private let onConfirm: ([String]) -> Void

    // MARK: - Initialization

    init(
        reactor: PlaceSelectorReactor,
        maxSelectionCount: Int = 20,
        preSelectedPlaceIds: [String] = [],
        onConfirm: @escaping ([String]) -> Void
    ) {
        self.maxSelectionCount = maxSelectionCount
        self.onConfirm = onConfirm
        super.init(nibName: nil, bundle: nil)
        self.reactor = reactor
    }

    // MARK: - Lifecycle

    override func loadView() {
        view = PlaceSelectorView()
    }

    // MARK: - NavigationBar
    override func setupNaviBar() {
        title = "관광지 선택"
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(cancelTapped)
        )
    }

    // MARK: - Binding

    func bind(reactor: PlaceSelectorReactor) {
        // Action
        Observable.just(())
            .map { Reactor.Action.loadFavorites }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        placeSelectorView.segmentedControl.rx.selectedSegmentIndex
            .map { $0 == 0 ? PlaceSelectorTab.favorites : PlaceSelectorTab.search }
            .map { Reactor.Action.selectTab($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        // Search on return key press only (no real-time search)
        placeSelectorView.searchBar.rx.searchButtonClicked
            .withLatestFrom(placeSelectorView.searchBar.rx.text.orEmpty)
            .map { Reactor.Action.searchKeyword($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        placeSelectorView.placeSelected
            .withLatestFrom(reactor.state.map { $0.displayPlaces }) { (placeId: $0, places: $1) }
            .compactMap { data -> (String, Place)? in
                guard let place = data.places.first(where: { $0.contentId == data.placeId }) else {
                    return nil
                }
                return (data.placeId, place)
            }
            .map { Reactor.Action.togglePlace($0.0, $0.1) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        placeSelectorView.confirmButton.rx.tap
            .map { Reactor.Action.confirm }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        // State
        reactor.state.map { $0.currentTab }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] tab in
                self?.placeSelectorView.searchBar.isHidden = (tab == .favorites)
            })
            .disposed(by: disposeBag)

        // Combine displayPlaces and selectedPlaceIds to update snapshot (simplified for compiler)
        let placesStream = reactor.state
            .map { $0.displayPlaces }
            .distinctUntilChanged { $0.count == $1.count }
            .share(replay: 1)

        let selectedIdsStream = reactor.state
            .map { $0.selectedPlaceIds }
            .distinctUntilChanged()
            .share(replay: 1)

        Observable.combineLatest(placesStream, selectedIdsStream)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] places, ids in
                self?.placeSelectorView.applySnapshot(places: places, selectedPlaceIds: ids)
            })
            .disposed(by: disposeBag)

        reactor.pulse(\.$confirmEvent)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] selectedIds in
                self?.onConfirm(selectedIds)
                self?.dismiss(animated: true)
            })
            .disposed(by: disposeBag)

        reactor.state.map { $0.isLoading }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .bind(to: placeSelectorView.rx.isLoading)
            .disposed(by: disposeBag)

        reactor.state.map { $0.errorMessage }
            .compactMap { $0 }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] message in
                self?.showToast(message: message)
            })
            .disposed(by: disposeBag)

        // Update confirm button title with count
        reactor.state.map { $0.selectedPlaceIds.count }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] count in
                guard let self = self else { return }
                let title = count > 0 ? "확인 (\(count)/\(self.maxSelectionCount))" : "확인"
                self.placeSelectorView.confirmButton.setTitle(title, for: .normal)
                self.placeSelectorView.confirmButton.isEnabled = count > 0
                self.placeSelectorView.confirmButton.alpha = count > 0 ? 1.0 : 0.5
            })
            .disposed(by: disposeBag)
    }

    // MARK: - Actions

    @objc private func cancelTapped() {
        dismiss(animated: true)
    }
}
