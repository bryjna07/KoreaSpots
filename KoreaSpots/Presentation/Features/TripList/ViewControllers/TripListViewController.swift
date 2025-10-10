//
//  TripListViewController.swift
//  KoreaSpots
//
//  Created by YoungJin on 10/10/25.
//

import UIKit
import ReactorKit
import RxSwift
import RxCocoa

final class TripListViewController: BaseViewController, View {

    // MARK: - Section & Item

    enum Section: Hashable {
        case statistics
        case trips
    }

    enum Item: Hashable {
        case statistics(TripStatistics)
        case trip(Trip)

        func hash(into hasher: inout Hasher) {
            switch self {
            case .statistics:
                hasher.combine("statistics")
            case .trip(let trip):
                hasher.combine(trip.id)
            }
        }

        static func == (lhs: Item, rhs: Item) -> Bool {
            switch (lhs, rhs) {
            case (.statistics, .statistics):
                return true
            case (.trip(let lhs), .trip(let rhs)):
                return lhs.id == rhs.id
            default:
                return false
            }
        }
    }

    // MARK: - Properties

    var disposeBag = DisposeBag()
    private let tripListView = TripListView()
    private var dataSource: UICollectionViewDiffableDataSource<Section, Item>!

    // MARK: - Lifecycle

    override func loadView() {
        view = tripListView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupDataSource()
    }

    // MARK: - Bind

    func bind(reactor: TripListReactor) {
        // Action: viewDidLoad
        Observable.just(())
            .map { TripListReactor.Action.viewDidLoad }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        // Action: Refresh
        tripListView.collectionView.refreshControl?.rx.controlEvent(.valueChanged)
            .map { TripListReactor.Action.refresh }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        // Action: Create new trip (+ button)
        navigationItem.rightBarButtonItem?.rx.tap
            .bind(with: self) { owner, _ in
                owner.navigateToTripEditor(trip: nil)
            }
            .disposed(by: disposeBag)

        // State: Loading
        reactor.state
            .map { $0.isLoading }
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: false)
            .drive(with: self) { owner, isLoading in
                if !isLoading {
                    owner.tripListView.collectionView.refreshControl?.endRefreshing()
                }
            }
            .disposed(by: disposeBag)

        // State: Trips & Statistics
        Observable.combineLatest(
            reactor.state.map { $0.trips },
            reactor.state.map { $0.statistics }
        )
        .asDriver(onErrorJustReturn: ([], nil))
        .drive(with: self) { owner, data in
            let (trips, statistics) = data
            owner.applySnapshot(trips: trips, statistics: statistics)
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

        // Cell selection
        tripListView.collectionView.rx.itemSelected
            .compactMap { [weak self] indexPath -> Trip? in
                guard let self = self,
                      let item = self.dataSource.itemIdentifier(for: indexPath),
                      case .trip(let trip) = item else {
                    return nil
                }
                return trip
            }
            .bind(with: self) { owner, trip in
                owner.navigateToTripDetail(trip: trip)
            }
            .disposed(by: disposeBag)
    }

    // MARK: - Setup

    private func setupUI() {
        title = "여행 기록"
        navigationController?.navigationBar.prefersLargeTitles = true

        // Add button
        let addButton = UIBarButtonItem(
            image: UIImage(systemName: "plus"),
            style: .plain,
            target: nil,
            action: nil
        )
        navigationItem.rightBarButtonItem = addButton

        // Refresh control
        let refreshControl = UIRefreshControl()
        tripListView.collectionView.refreshControl = refreshControl
    }

    private func setupDataSource() {
        // Statistics header registration
        let statisticsHeaderRegistration = UICollectionView.SupplementaryRegistration<TripStatisticsHeaderView>(
            elementKind: UICollectionView.elementKindSectionHeader
        ) { [weak self] headerView, elementKind, indexPath in
            guard let self = self,
                  let section = self.dataSource.sectionIdentifier(for: indexPath.section),
                  case .statistics = section,
                  let reactor = self.reactor,
                  let statistics = reactor.currentState.statistics else {
                return
            }
            headerView.configure(with: statistics)
        }

        // Trip cell registration
        let tripCellRegistration = UICollectionView.CellRegistration<TripCell, Item> { cell, indexPath, item in
            if case .trip(let trip) = item {
                cell.configure(with: trip)
            }
        }

        // DataSource
        dataSource = UICollectionViewDiffableDataSource<Section, Item>(
            collectionView: tripListView.collectionView
        ) { collectionView, indexPath, item in
            return collectionView.dequeueConfiguredReusableCell(
                using: tripCellRegistration,
                for: indexPath,
                item: item
            )
        }

        // Supplementary view provider
        dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
            return collectionView.dequeueConfiguredReusableSupplementary(
                using: statisticsHeaderRegistration,
                for: indexPath
            )
        }
    }

    // MARK: - Snapshot

    private func applySnapshot(trips: [Trip], statistics: TripStatistics?) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()

        // Statistics section
        if let statistics = statistics {
            snapshot.appendSections([.statistics])
            snapshot.appendItems([.statistics(statistics)], toSection: .statistics)
        }

        // Trips section
        if !trips.isEmpty {
            snapshot.appendSections([.trips])
            snapshot.appendItems(trips.map { .trip($0) }, toSection: .trips)
        }

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
