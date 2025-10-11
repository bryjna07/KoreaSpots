//
//  TripRecordViewController.swift
//  KoreaSpots
//
//  Created by YoungJin on 10/10/25.
//

import UIKit
import ReactorKit
import RxSwift
import RxCocoa

final class TripRecordViewController: BaseViewController, View {

    // MARK: - Section & Item

    enum Section: Hashable {
        case trips
    }
    
    // MARK: - Properties

    var disposeBag = DisposeBag()
    private let tripRecordView = TripRecordView()
    private var dataSource: UICollectionViewDiffableDataSource<Section, Trip>!
    private var isFirstAppear = true

    private let addButton = UIBarButtonItem(
        image: UIImage(systemName: "plus"),
        style: .plain,
        target: nil,
        action: nil
    )

    // MARK: - Lifecycle

    override func loadView() {
        view = tripRecordView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupDataSource()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Reload data when returning from TripEditor (skip first appear)
        if !isFirstAppear {
            reactor?.action.onNext(.refresh)
        }
        isFirstAppear = false
    }

    // MARK: - Bind

    func bind(reactor: TripRecordReactor) {
        // DataSource 초기화 보장
        if dataSource == nil {
            setupDataSource()
        }

        // Action: viewDidLoad
        Observable.just(())
            .map { TripRecordReactor.Action.viewDidLoad }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        // Action: Create new trip (+ button)
        addButton.rx.tap
            .bind(with: self) { owner, _ in
                owner.navigateToTripEditor(trip: nil)
            }
            .disposed(by: disposeBag)

        // State: Trips
        reactor.state
            .map { $0.trips }
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: [])
            .drive(with: self) { owner, trips in
                print("🔄 Drive: applySnapshot(\(trips.count) trips)")
                owner.applySnapshot(trips: trips)
            }
            .disposed(by: disposeBag)

        // State: Statistics (separate view)
        reactor.state
            .map { $0.statistics }
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: nil)
            .drive(with: self) { owner, statistics in
                if let statistics = statistics {
                    owner.tripRecordView.statisticsHeaderView.configure(with: statistics)
                }
            }
            .disposed(by: disposeBag)

        // State: Error
        reactor.state
            .map { $0.error }
            .distinctUntilChanged()
            .compactMap { $0 }
            .filter { !$0.isEmpty }
            .asDriver(onErrorJustReturn: "")
            .drive(with: self) { owner, error in
                owner.showErrorAlert(message: error)
            }
            .disposed(by: disposeBag)

        // Cell selection (using RxSwift)
        tripRecordView.collectionView.rx.itemSelected
            .do(onNext: { [weak self] indexPath in
                // Deselect immediately for visual feedback
                self?.tripRecordView.collectionView.deselectItem(at: indexPath, animated: true)
            })
            .compactMap { [weak self] indexPath -> Trip? in
                return self?.dataSource.itemIdentifier(for: indexPath)
            }
            .bind(with: self) { owner, trip in
                owner.navigateToTripEditor(trip: trip)
            }
            .disposed(by: disposeBag)

        // Set delegate for swipe actions (works with RxSwift)
        tripRecordView.collectionView.rx.setDelegate(self)
            .disposed(by: disposeBag)
    }

    // MARK: - Setup

    override func setupNaviBar() {
        super.setupNaviBar()
        title = "여행 기록"
        navigationItem.rightBarButtonItem = addButton
    }

    private func setupDataSource() {
        // 이미 초기화되었으면 skip
        guard dataSource == nil else { return }

        // Trip cell registration
        let tripCellRegistration = UICollectionView.CellRegistration<TripCell, Trip> { [weak self] cell, indexPath, trip in
            cell.configure(with: trip)
            cell.onDeleteTapped = { [weak self] in
                self?.showDeleteConfirmation(for: trip)
            }
        }

        // DataSource
        dataSource = UICollectionViewDiffableDataSource<Section, Trip>(
            collectionView: tripRecordView.collectionView
        ) { collectionView, indexPath, trip in
            return collectionView.dequeueConfiguredReusableCell(
                using: tripCellRegistration,
                for: indexPath,
                item: trip
            )
        }
    }

    // MARK: - Alert

    private func showDeleteConfirmation(for trip: Trip) {
        let alert = UIAlertController(
            title: "여행 기록 삭제",
            message: "'\(trip.title)' 여행 기록을 삭제하시겠습니까?",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        alert.addAction(UIAlertAction(title: "삭제", style: .destructive) { [weak self] _ in
            self?.reactor?.action.onNext(.deleteTrip(trip.id))
        })

        present(alert, animated: true)
    }
}

// MARK: - UICollectionViewDelegate

extension TripRecordViewController: UICollectionViewDelegate {
    // Trailing swipe actions (left swipe)
    func collectionView(
        _ collectionView: UICollectionView,
        trailingSwipeActionsConfigurationForItemAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        guard let trip = dataSource.itemIdentifier(for: indexPath) else {
            return nil
        }

        let deleteAction = UIContextualAction(
            style: .destructive,
            title: "삭제"
        ) { [weak self] _, _, completion in
            self?.showDeleteConfirmation(for: trip)
            completion(true)
        }
        deleteAction.image = UIImage(systemName: "trash")

        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        configuration.performsFirstActionWithFullSwipe = false

        return configuration
    }
}

    // MARK: - Snapshot

extension TripRecordViewController {


    private func applySnapshot(trips: [Trip]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Trip>()

        snapshot.appendSections([.trips])
        snapshot.appendItems(trips, toSection: .trips)

        dataSource.apply(snapshot, animatingDifferences: true)
    }

    // MARK: - Navigation

    private func navigateToTripEditor(trip: Trip?) {
        let viewController = AppContainer.shared.makeTripEditorViewController(trip: trip)
        navigationController?.pushViewController(viewController, animated: true)
    }

    private func navigateToTripDetail(trip: Trip) {
        // TODO: Implement TripDetail in Phase 2
        print("Navigate to trip detail: \(trip.title)")
    }
}
