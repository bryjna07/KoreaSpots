//
//  TripRecordViewController+Bind.swift
//  KoreaSpots
//
//  Created by YoungJin on 11/12/25.
//

// 역할: Reactor Action/State 바인딩 (뷰 이벤트 -> Action, State -> UI)
// 의존: TripRecordReactor, TripRecordView
// 사용처: TripRecordViewController

import UIKit
import ReactorKit
import RxSwift
import RxCocoa

extension TripRecordViewController {

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
}
