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
    var listDataSource: UICollectionViewDiffableDataSource<Section, Trip>!

    private var isFirstAppear = true

    // 여행별 트랙 할당 맵 (Reactor state에서 받아옴)
    var tripTracks: [String: Int] = [:]

    let addButton = UIBarButtonItem(
        image: UIImage(systemName: "plus"),
        style: .plain,
        target: nil,
        action: nil
    )

    // 년도 목록 (여행 데이터가 존재하는 년도만, Reactor state에서 받아옴)
    var availableYears: [Int] = []

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

    // MARK: - Setup

    override func setupNaviBar() {
        super.setupNaviBar()
        title = "여행 기록"
        navigationItem.rightBarButtonItem = addButton
    }

    func setupDataSources() {
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

    func showDeleteConfirmation(for trip: Trip) {
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

// MARK: - Snapshot

extension TripRecordViewController {

    func applyListSnapshot(trips: [Trip]) {
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

    func navigateToTripDetail(trip: Trip) {
        let viewController = AppContainer.shared.makeTripDetailViewController(trip: trip)
        navigationController?.pushViewController(viewController, animated: true)
    }
}
