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
    let tripRecordView = TripRecordView()
    private var dataSource: UICollectionViewDiffableDataSource<Section, Trip>!
    private var isFirstAppear = true

    // 여행별 트랙 할당 맵 (Reactor state에서 받아옴)
    var tripTracks: [String: Int] = [:]

    private let addButton = UIBarButtonItem(
        image: UIImage(systemName: "plus"),
        style: .plain,
        target: nil,
        action: nil
    )

    // 년도 목록 (과거 10년 ~ 현재)
    private var availableYears: [Int] {
        let currentYear = Calendar.current.component(.year, from: Date())
        return Array((currentYear - 10)...currentYear).reversed()
    }

    // MARK: - Lifecycle

    override func loadView() {
        view = tripRecordView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupDataSource()
        setupYearTableView()
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

        // Action: Previous month button
        tripRecordView.calendarView.previousMonthButton.rx.tap
            .bind(with: self) { owner, _ in
                let calendar = Calendar.current
                if let previousMonth = calendar.date(byAdding: .month, value: -1, to: owner.tripRecordView.calendarView.currentMonth) {
                    owner.tripRecordView.calendarView.moveCalendar(to: previousMonth)
                    owner.reactor?.action.onNext(.selectMonth(previousMonth))
                }
            }
            .disposed(by: disposeBag)

        // Action: Next month button
        tripRecordView.calendarView.nextMonthButton.rx.tap
            .bind(with: self) { owner, _ in
                let calendar = Calendar.current
                if let nextMonth = calendar.date(byAdding: .month, value: 1, to: owner.tripRecordView.calendarView.currentMonth) {
                    owner.tripRecordView.calendarView.moveCalendar(to: nextMonth)
                    owner.reactor?.action.onNext(.selectMonth(nextMonth))
                }
            }
            .disposed(by: disposeBag)

        // Action: Month label tap (year dropdown toggle)
        let monthLabelTap = UITapGestureRecognizer()
        tripRecordView.calendarView.monthLabel.addGestureRecognizer(monthLabelTap)
        monthLabelTap.rx.event
            .bind(with: self) { owner, _ in
                owner.tripRecordView.calendarView.toggleYearDropdown()
            }
            .disposed(by: disposeBag)

        // State: Trips (리스트 표시용 - 필터링된 데이터)
        reactor.state
            .map { $0.trips }
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: [])
            .drive(with: self) { owner, trips in
                owner.applySnapshot(trips: trips)
            }
            .disposed(by: disposeBag)

        // State: All trips (캘린더 표시용 - 전체 여행 데이터)
        reactor.state
            .map { $0.allTrips }
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: [])
            .drive(with: self) { owner, allTrips in
                owner.tripRecordView.trips = allTrips
                owner.tripRecordView.calendarView.calendar.reloadData()
            }
            .disposed(by: disposeBag)

        // State: Trip tracks (Reactor에서 계산된 트랙 할당)
        reactor.state
            .map { $0.tripTracks }
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: [:])
            .drive(with: self) { owner, tracks in
                owner.tripTracks = tracks
                owner.tripRecordView.calendarView.calendar.reloadData()
            }
            .disposed(by: disposeBag)

        // State: Selected month (달력 이동)
        reactor.state
            .map { $0.selectedMonth }
            .distinctUntilChanged()
            .compactMap { $0 }
            .asDriver(onErrorJustReturn: Date())
            .drive(with: self) { owner, month in
                owner.tripRecordView.calendarView.moveCalendar(to: month)
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

        // Set calendar delegate
        tripRecordView.calendarView.calendar.delegate = self
        tripRecordView.calendarView.calendar.dataSource = self
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

    private func setupYearTableView() {
        // Bind available years to table view
        Observable.just(availableYears)
            .bind(to: tripRecordView.calendarView.yearTableView.rx.items(
                cellIdentifier: "YearCell",
                cellType: UITableViewCell.self
            )) { [weak self] row, year, cell in
                guard let self = self else { return }

                cell.textLabel?.text = "\(year)년"
                cell.textLabel?.font = FontManager.body
                cell.textLabel?.textAlignment = .center
                cell.backgroundColor = .white
                cell.selectionStyle = .default

                // 현재 선택된 년도 표시
                let currentYear = Calendar.current.component(.year, from: self.tripRecordView.calendarView.currentMonth)
                if year == currentYear {
                    cell.backgroundColor = UIColor.primary.withAlphaComponent(0.1)
                    cell.textLabel?.textColor = .primary
                    cell.textLabel?.font = FontManager.bodyBold
                } else {
                    cell.textLabel?.textColor = .label
                }
            }
            .disposed(by: disposeBag)

        // Handle year selection
        tripRecordView.calendarView.yearTableView.rx.itemSelected
            .bind(with: self) { owner, indexPath in
                owner.tripRecordView.calendarView.yearTableView.deselectRow(at: indexPath, animated: true)

                let selectedYear = owner.availableYears[indexPath.row]
                let calendar = Calendar.current
                let currentMonth = calendar.component(.month, from: owner.tripRecordView.calendarView.currentMonth)

                var components = DateComponents()
                components.year = selectedYear
                components.month = currentMonth
                components.day = 1

                if let selectedDate = calendar.date(from: components) {
                    owner.tripRecordView.calendarView.moveCalendar(to: selectedDate)
                    owner.reactor?.action.onNext(.selectMonth(selectedDate))
                    owner.tripRecordView.calendarView.hideYearDropdown()
                    owner.tripRecordView.calendarView.yearTableView.reloadData()
                }
            }
            .disposed(by: disposeBag)
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

    func navigateToTripEditor(trip: Trip?) {
        let viewController = AppContainer.shared.makeTripEditorViewController(trip: trip)
        navigationController?.pushViewController(viewController, animated: true)
    }

    private func navigateToTripDetail(trip: Trip) {
        // TODO: Implement TripDetail in Phase 2
        print("Navigate to trip detail: \(trip.title)")
    }
}
