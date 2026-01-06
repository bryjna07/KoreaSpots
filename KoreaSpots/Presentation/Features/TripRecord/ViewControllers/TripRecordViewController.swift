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

    // DataSources
    private var listDataSource: UICollectionViewDiffableDataSource<Section, Trip>!

    private var isFirstAppear = true

    // 여행별 트랙 할당 맵 (Reactor state에서 받아옴)
    var tripTracks: [String: Int] = [:]

    private let addButton = UIBarButtonItem(
        image: UIImage(systemName: "plus"),
        style: .plain,
        target: nil,
        action: nil
    )

    // 년도 목록 (여행 데이터가 존재하는 년도만, Reactor state에서 받아옴)
    private var availableYears: [Int] = []

    // 월 목록 (1 ~ 12)
    private let availableMonths: [Int] = Array(1...12)

    // MARK: - Lifecycle

    override func loadView() {
        view = tripRecordView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupDataSources()
        setupListYearTableView()
        setupListMonthTableView()
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
        if listDataSource == nil {
            setupDataSources()
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

        // Action: Segment selection
        tripRecordView.segmentedControl.rx.selectedSegmentIndex
            .compactMap { TripRecordSegment(rawValue: $0) }
            .bind(with: self) { owner, segment in
                reactor.action.onNext(.selectSegment(segment))
            }
            .disposed(by: disposeBag)

        // Action: Filter button tap
        tripRecordView.filterButton.rx.tap
            .bind(with: self) { owner, _ in
                owner.tripRecordView.toggleFilterDropdown()
            }
            .disposed(by: disposeBag)

        // Action: Filter mode changed (from TripRecordView callback)
        tripRecordView.onFilterModeChanged = { [weak self] mode in
            self?.reactor?.action.onNext(.setListFilterMode(mode))
        }

        // Action: Year picker button tap
        tripRecordView.yearPickerButton.rx.tap
            .bind(with: self) { owner, _ in
                owner.tripRecordView.toggleYearDropdown()
            }
            .disposed(by: disposeBag)

        // Action: Month picker button tap
        tripRecordView.monthPickerButton.rx.tap
            .bind(with: self) { owner, _ in
                owner.tripRecordView.toggleMonthDropdown()
            }
            .disposed(by: disposeBag)

        // Action: Previous month button (Calendar)
        tripRecordView.calendarView.previousMonthButton.rx.tap
            .bind(with: self) { owner, _ in
                let calendar = Calendar.current
                if let previousMonth = calendar.date(byAdding: .month, value: -1, to: owner.tripRecordView.calendarView.currentMonth) {
                    owner.tripRecordView.calendarView.moveCalendar(to: previousMonth)
                    owner.reactor?.action.onNext(.selectMonth(previousMonth))
                }
            }
            .disposed(by: disposeBag)

        // Action: Next month button (Calendar)
        tripRecordView.calendarView.nextMonthButton.rx.tap
            .bind(with: self) { owner, _ in
                let calendar = Calendar.current
                if let nextMonth = calendar.date(byAdding: .month, value: 1, to: owner.tripRecordView.calendarView.currentMonth) {
                    owner.tripRecordView.calendarView.moveCalendar(to: nextMonth)
                    owner.reactor?.action.onNext(.selectMonth(nextMonth))
                }
            }
            .disposed(by: disposeBag)

        // Action: Month label tap (Calendar year dropdown toggle)
        let monthLabelTap = UITapGestureRecognizer()
        tripRecordView.calendarView.monthLabel.addGestureRecognizer(monthLabelTap)
        monthLabelTap.rx.event
            .bind(with: self) { owner, _ in
                owner.tripRecordView.calendarView.toggleYearDropdown()
            }
            .disposed(by: disposeBag)

        // Action: Load more (infinite scroll)
        tripRecordView.listView.collectionView.rx.contentOffset
            .map { [weak self] offset -> Bool in
                guard let self = self else { return false }
                let collectionView = self.tripRecordView.listView.collectionView
                let contentHeight = collectionView.contentSize.height
                let frameHeight = collectionView.frame.height
                let threshold: CGFloat = 100

                return offset.y > contentHeight - frameHeight - threshold && contentHeight > 0
            }
            .distinctUntilChanged()
            .filter { $0 }
            .map { _ in TripRecordReactor.Action.loadMoreList }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        // State: Selected segment
        reactor.state
            .map { $0.selectedSegment }
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: .list)
            .drive(with: self) { owner, segment in
                owner.tripRecordView.currentSegment = segment
                owner.tripRecordView.segmentedControl.selectedSegmentIndex = segment.rawValue
            }
            .disposed(by: disposeBag)

        // State: List trips (목록용)
        reactor.state
            .map { $0.listTrips }
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: [])
            .drive(with: self) { owner, trips in
                owner.applyListSnapshot(trips: trips)
                owner.tripRecordView.listView.isEmpty = trips.isEmpty
            }
            .disposed(by: disposeBag)

        // State: Total trip count (전체 n개)
        reactor.state
            .map { $0.totalTripCount }
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: 0)
            .drive(with: self) { owner, count in
                owner.tripRecordView.updateTotalCount(count)
            }
            .disposed(by: disposeBag)

        // State: List filter mode
        reactor.state
            .map { $0.listFilterMode }
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: .all)
            .drive(with: self) { owner, mode in
                owner.tripRecordView.currentFilterMode = mode
            }
            .disposed(by: disposeBag)

        // State: Filter year
        reactor.state
            .map { $0.filterYear }
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: Calendar.current.component(.year, from: Date()))
            .drive(with: self) { owner, year in
                owner.tripRecordView.selectedYear = year
                owner.tripRecordView.yearTableView.reloadData()
            }
            .disposed(by: disposeBag)

        // State: Filter month
        reactor.state
            .map { $0.filterMonth }
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: Calendar.current.component(.month, from: Date()))
            .drive(with: self) { owner, month in
                owner.tripRecordView.selectedMonth = month
                owner.tripRecordView.monthTableView.reloadData()
            }
            .disposed(by: disposeBag)

        // State: All trips (캘린더 표시용 - 전체 여행 데이터)
        reactor.state
            .map { $0.allTrips }
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: [])
            .drive(with: self) { owner, allTrips in
                owner.tripRecordView.trips = allTrips
                // 캘린더가 visible 상태일 때만 reloadData 호출 (hidden일 때 size 0 에러 방지)
                if !owner.tripRecordView.calendarContainerView.isHidden {
                    owner.tripRecordView.calendarView.calendar.reloadData()
                }
            }
            .disposed(by: disposeBag)

        // State: Trip tracks (Reactor에서 계산된 트랙 할당)
        reactor.state
            .map { $0.tripTracks }
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: [:])
            .drive(with: self) { owner, tracks in
                owner.tripTracks = tracks
                // 캘린더가 visible 상태일 때만 reloadData 호출 (hidden일 때 size 0 에러 방지)
                if !owner.tripRecordView.calendarContainerView.isHidden {
                    owner.tripRecordView.calendarView.calendar.reloadData()
                }
            }
            .disposed(by: disposeBag)

        // State: Available years (여행 데이터가 존재하는 년도)
        reactor.state
            .map { $0.availableYears }
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: [])
            .drive(with: self) { owner, years in
                owner.availableYears = years
                owner.tripRecordView.yearTableView.reloadData()
                owner.tripRecordView.calendarView.yearTableView.reloadData()
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

        // State: Statistics
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

        // State: Loading more
        reactor.state
            .map { $0.isLoadingMore }
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: false)
            .drive(with: self) { owner, isLoading in
                if isLoading {
                    owner.tripRecordView.listView.loadingIndicator.startAnimating()
                } else {
                    owner.tripRecordView.listView.loadingIndicator.stopAnimating()
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

        // List Cell selection
        tripRecordView.listView.collectionView.rx.itemSelected
            .do(onNext: { [weak self] indexPath in
                self?.tripRecordView.listView.collectionView.deselectItem(at: indexPath, animated: true)
            })
            .compactMap { [weak self] indexPath -> Trip? in
                return self?.listDataSource.itemIdentifier(for: indexPath)
            }
            .bind(with: self) { owner, trip in
                owner.navigateToTripDetail(trip: trip)
            }
            .disposed(by: disposeBag)

        // Set delegate for swipe actions
        tripRecordView.listView.collectionView.rx.setDelegate(self)
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

    private func setupDataSources() {
        guard listDataSource == nil else { return }

        // Trip cell registration for list
        let listCellRegistration = UICollectionView.CellRegistration<TripCell, Trip> { [weak self] cell, indexPath, trip in
            cell.configure(with: trip)
            cell.onDeleteTapped = { [weak self] in
                self?.showDeleteConfirmation(for: trip)
            }
        }

        // List DataSource
        listDataSource = UICollectionViewDiffableDataSource<Section, Trip>(
            collectionView: tripRecordView.listView.collectionView
        ) { collectionView, indexPath, trip in
            return collectionView.dequeueConfiguredReusableCell(
                using: listCellRegistration,
                for: indexPath,
                item: trip
            )
        }
    }

    private func setupListYearTableView() {
        // Setup delegates for manual data source
        tripRecordView.yearTableView.dataSource = self
        tripRecordView.yearTableView.delegate = self

        // Setup calendar year table view delegates
        tripRecordView.calendarView.yearTableView.dataSource = self
        tripRecordView.calendarView.yearTableView.delegate = self
    }

    private func setupListMonthTableView() {
        // Bind available months to month table view
        Observable.just(availableMonths)
            .bind(to: tripRecordView.monthTableView.rx.items(
                cellIdentifier: "MonthCell",
                cellType: UITableViewCell.self
            )) { [weak self] row, month, cell in
                guard let self = self else { return }

                cell.textLabel?.text = "\(month)월"
                cell.textLabel?.font = FontManager.body
                cell.textLabel?.textAlignment = .center
                cell.backgroundColor = .white
                cell.selectionStyle = .default

                // 현재 선택된 월 표시
                if month == self.tripRecordView.selectedMonth {
                    cell.backgroundColor = UIColor.primary.withAlphaComponent(0.1)
                    cell.textLabel?.textColor = .primary
                    cell.textLabel?.font = FontManager.bodyBold
                } else {
                    cell.textLabel?.textColor = .label
                }
            }
            .disposed(by: disposeBag)

        // Handle month selection
        tripRecordView.monthTableView.rx.itemSelected
            .bind(with: self) { owner, indexPath in
                owner.tripRecordView.monthTableView.deselectRow(at: indexPath, animated: true)

                let selectedMonth = owner.availableMonths[indexPath.row]
                owner.tripRecordView.hideMonthDropdown()
                owner.reactor?.action.onNext(.selectFilterMonth(selectedMonth))
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
        guard collectionView == tripRecordView.listView.collectionView,
              let trip = listDataSource?.itemIdentifier(for: indexPath) else {
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

    private func applyListSnapshot(trips: [Trip]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Trip>()
        snapshot.appendSections([.trips])
        snapshot.appendItems(trips, toSection: .trips)
        listDataSource.apply(snapshot, animatingDifferences: true)
    }

    // MARK: - Navigation

    func navigateToTripEditor(trip: Trip?) {
        let viewController = AppContainer.shared.makeTripEditorViewController(trip: trip)
        navigationController?.pushViewController(viewController, animated: true)
    }

    private func navigateToTripDetail(trip: Trip) {
        let viewController = AppContainer.shared.makeTripDetailViewController(trip: trip)
        navigationController?.pushViewController(viewController, animated: true)
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate (Year TableViews)

extension TripRecordViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Both year table views use availableYears
        if tableView == tripRecordView.yearTableView || tableView == tripRecordView.calendarView.yearTableView {
            return availableYears.count
        }
        return 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // List filter year table view
        if tableView == tripRecordView.yearTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "YearCell", for: indexPath)
            let year = availableYears[indexPath.row]

            cell.textLabel?.text = "\(year)년"
            cell.textLabel?.font = FontManager.body
            cell.textLabel?.textAlignment = .center
            cell.backgroundColor = .white
            cell.selectionStyle = .default

            // 현재 선택된 년도 표시
            if year == tripRecordView.selectedYear {
                cell.backgroundColor = UIColor.primary.withAlphaComponent(0.1)
                cell.textLabel?.textColor = .primary
                cell.textLabel?.font = FontManager.bodyBold
            } else {
                cell.textLabel?.textColor = .label
            }

            return cell
        }

        // Calendar year table view
        if tableView == tripRecordView.calendarView.yearTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "YearCell", for: indexPath)
            let year = availableYears[indexPath.row]

            cell.textLabel?.text = "\(year)년"
            cell.textLabel?.font = FontManager.body
            cell.textLabel?.textAlignment = .center
            cell.backgroundColor = .white
            cell.selectionStyle = .default

            // 현재 선택된 년도 표시
            let currentYear = Calendar.current.component(.year, from: tripRecordView.calendarView.currentMonth)
            if year == currentYear {
                cell.backgroundColor = UIColor.primary.withAlphaComponent(0.1)
                cell.textLabel?.textColor = .primary
                cell.textLabel?.font = FontManager.bodyBold
            } else {
                cell.textLabel?.textColor = .label
            }

            return cell
        }

        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        // List filter year selection
        if tableView == tripRecordView.yearTableView {
            let selectedYear = availableYears[indexPath.row]
            tripRecordView.hideYearDropdown()
            reactor?.action.onNext(.selectFilterYear(selectedYear))
        }

        // Calendar year selection
        if tableView == tripRecordView.calendarView.yearTableView {
            let selectedYear = availableYears[indexPath.row]
            let calendar = Calendar.current
            let currentMonth = calendar.component(.month, from: tripRecordView.calendarView.currentMonth)

            var components = DateComponents()
            components.year = selectedYear
            components.month = currentMonth
            components.day = 1

            if let selectedDate = calendar.date(from: components) {
                tripRecordView.calendarView.moveCalendar(to: selectedDate)
                reactor?.action.onNext(.selectMonth(selectedDate))
                tripRecordView.calendarView.hideYearDropdown()
                tripRecordView.calendarView.yearTableView.reloadData()
            }
        }
    }
}
