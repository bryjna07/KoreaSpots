//
//  TripRecordReactor.swift
//  KoreaSpots
//
//  Created by YoungJin on 10/10/25.
//

import Foundation
import ReactorKit
import RxSwift

final class TripRecordReactor: Reactor {

    // MARK: - Constants

    private let pageSize = 20

    // MARK: - Action

    enum Action {
        case viewDidLoad
        case refresh
        case selectSegment(TripRecordSegment)
        case selectSortOption(TripSortOption)
        case selectMonth(Date?)
        case loadMoreList
        case deleteTrip(String)
        // List filter actions
        case setListFilterMode(ListFilterMode)
        case selectFilterYear(Int)
        case selectFilterMonth(Int)
    }

    // MARK: - Mutation

    enum Mutation {
        case setLoading(Bool)
        case setLoadingMore(Bool)
        case setSelectedSegment(TripRecordSegment)
        case setTrips([Trip])
        case setListTrips([Trip])
        case appendListTrips([Trip])
        case setAllTrips([Trip])
        case setTripTracks([String: Int])
        case setStatistics(TripStatistics)
        case setSortOption(TripSortOption)
        case setSelectedMonth(Date?)
        case setCurrentPage(Int)
        case setHasMoreData(Bool)
        case setError(String)
        // List filter mutations
        case setListFilterMode(ListFilterMode)
        case setFilterYear(Int)
        case setFilterMonth(Int)
        case setTotalTripCount(Int)
        case setAvailableYears([Int])
    }

    // MARK: - State

    struct State {
        var isLoading: Bool = false
        var isLoadingMore: Bool = false
        var selectedSegment: TripRecordSegment = .list
        var trips: [Trip] = []  // 캘린더에 필터링된 여행
        var listTrips: [Trip] = []  // 목록용 전체 여행 (페이지네이션)
        var allTrips: [Trip] = []  // 캘린더 표시용 전체 여행
        var tripTracks: [String: Int] = [:]
        var statistics: TripStatistics?
        var sortOption: TripSortOption = .newest
        var selectedMonth: Date?
        var currentPage: Int = 0
        var hasMoreData: Bool = true
        var error: String?
        // List filter state
        var listFilterMode: ListFilterMode = .all
        var filterYear: Int = Calendar.current.component(.year, from: Date())
        var filterMonth: Int = Calendar.current.component(.month, from: Date())
        var totalTripCount: Int = 0
        var availableYears: [Int] = []  // 여행 데이터가 존재하는 년도 목록
    }

    let initialState = State()

    private let getTripsUseCase: GetTripsUseCase
    private let getTripStatisticsUseCase: GetTripStatisticsUseCase
    private let deleteTripUseCase: DeleteTripUseCase

    init(
        getTripsUseCase: GetTripsUseCase,
        getTripStatisticsUseCase: GetTripStatisticsUseCase,
        deleteTripUseCase: DeleteTripUseCase
    ) {
        self.getTripsUseCase = getTripsUseCase
        self.getTripStatisticsUseCase = getTripStatisticsUseCase
        self.deleteTripUseCase = deleteTripUseCase
    }

    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewDidLoad, .refresh:
            return loadData()

        case .selectSegment(let segment):
            return .just(.setSelectedSegment(segment))

        case .selectSortOption(let option):
            return .concat([
                .just(.setSortOption(option)),
                .just(.setSelectedMonth(nil)),
                loadTrips(sortedBy: option, month: nil)
            ])

        case .selectMonth(let month):
            return .concat([
                .just(.setSelectedMonth(month)),
                loadTrips(sortedBy: currentState.sortOption, month: month)
            ])

        case .loadMoreList:
            guard !currentState.isLoadingMore, currentState.hasMoreData else {
                return .empty()
            }
            return loadMoreListTrips()

        case .deleteTrip(let tripId):
            return deleteTripUseCase.execute(tripId: tripId)
                .andThen(Observable.just(()))
                .flatMap { _ -> Observable<Mutation> in
                    return self.loadData()
                }
                .catch { _ in
                    return .just(.setError("여행 기록 삭제 중 오류가 발생했습니다."))
                }

        case .setListFilterMode(let mode):
            return .concat([
                .just(.setListFilterMode(mode)),
                .just(.setCurrentPage(0)),
                .just(.setHasMoreData(true)),
                loadFilteredListTrips(mode: mode, year: currentState.filterYear, month: currentState.filterMonth)
            ])

        case .selectFilterYear(let year):
            return .concat([
                .just(.setFilterYear(year)),
                .just(.setCurrentPage(0)),
                .just(.setHasMoreData(true)),
                loadFilteredListTrips(mode: currentState.listFilterMode, year: year, month: currentState.filterMonth)
            ])

        case .selectFilterMonth(let month):
            return .concat([
                .just(.setFilterMonth(month)),
                .just(.setCurrentPage(0)),
                .just(.setHasMoreData(true)),
                loadFilteredListTrips(mode: currentState.listFilterMode, year: currentState.filterYear, month: month)
            ])
        }
    }

    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state

        switch mutation {
        case .setLoading(let isLoading):
            newState.isLoading = isLoading

        case .setLoadingMore(let isLoadingMore):
            newState.isLoadingMore = isLoadingMore

        case .setSelectedSegment(let segment):
            newState.selectedSegment = segment

        case .setTrips(let trips):
            newState.trips = trips
            newState.isLoading = false

        case .setListTrips(let trips):
            newState.listTrips = trips
            newState.isLoading = false

        case .appendListTrips(let trips):
            newState.listTrips.append(contentsOf: trips)
            newState.isLoadingMore = false

        case .setAllTrips(let trips):
            newState.allTrips = trips

        case .setTripTracks(let tracks):
            newState.tripTracks = tracks

        case .setStatistics(let statistics):
            newState.statistics = statistics

        case .setSortOption(let option):
            newState.sortOption = option

        case .setSelectedMonth(let month):
            newState.selectedMonth = month

        case .setCurrentPage(let page):
            newState.currentPage = page

        case .setHasMoreData(let hasMore):
            newState.hasMoreData = hasMore

        case .setError(let error):
            newState.error = error
            newState.isLoading = false
            newState.isLoadingMore = false

        case .setListFilterMode(let mode):
            newState.listFilterMode = mode

        case .setFilterYear(let year):
            newState.filterYear = year

        case .setFilterMonth(let month):
            newState.filterMonth = month

        case .setTotalTripCount(let count):
            newState.totalTripCount = count

        case .setAvailableYears(let years):
            newState.availableYears = years
        }

        return newState
    }

    // MARK: - Private Methods

    private func loadData() -> Observable<Mutation> {
        return .concat([
            .just(.setLoading(true)),
            .just(.setCurrentPage(0)),
            .just(.setHasMoreData(true)),
            loadStatistics(),
            loadAllTrips(),
            loadInitialListTrips(),
            loadTrips(sortedBy: currentState.sortOption, month: currentState.selectedMonth)
        ])
    }

    private func loadStatistics() -> Observable<Mutation> {
        return getTripStatisticsUseCase.execute()
            .asObservable()
            .map { Mutation.setStatistics($0) }
            .catch { _ in
                return .empty()
            }
    }

    private func loadAllTrips() -> Observable<Mutation> {
        return getTripsUseCase.execute(sortedBy: .newest)
            .asObservable()
            .flatMap { trips -> Observable<Mutation> in
                let tracks = self.calculateTripTracks(trips: trips)
                let availableYears = self.extractAvailableYears(from: trips)
                return .concat([
                    .just(.setAllTrips(trips)),
                    .just(.setTripTracks(tracks)),
                    .just(.setAvailableYears(availableYears))
                ])
            }
            .catch { _ in
                return .empty()
            }
    }

    private func loadInitialListTrips() -> Observable<Mutation> {
        return getTripsUseCase.execute(sortedBy: .newest)
            .asObservable()
            .flatMap { [weak self] trips -> Observable<Mutation> in
                guard let self = self else { return .empty() }
                let initialTrips = Array(trips.prefix(self.pageSize))
                let hasMore = trips.count > self.pageSize
                return .concat([
                    .just(.setTotalTripCount(trips.count)),
                    .just(.setListTrips(initialTrips)),
                    .just(.setCurrentPage(1)),
                    .just(.setHasMoreData(hasMore))
                ])
            }
            .catch { _ in
                return .just(.setError("여행 기록을 불러오는 중 오류가 발생했습니다."))
            }
    }

    private func loadMoreListTrips() -> Observable<Mutation> {
        return .concat([
            .just(.setLoadingMore(true)),
            getTripsUseCase.execute(sortedBy: .newest)
                .asObservable()
                .flatMap { [weak self] allTrips -> Observable<Mutation> in
                    guard let self = self else { return .empty() }

                    let startIndex = self.currentState.currentPage * self.pageSize
                    let endIndex = min(startIndex + self.pageSize, allTrips.count)

                    guard startIndex < allTrips.count else {
                        return .concat([
                            .just(.setLoadingMore(false)),
                            .just(.setHasMoreData(false))
                        ])
                    }

                    let newTrips = Array(allTrips[startIndex..<endIndex])
                    let hasMore = endIndex < allTrips.count

                    return .concat([
                        .just(.appendListTrips(newTrips)),
                        .just(.setCurrentPage(self.currentState.currentPage + 1)),
                        .just(.setHasMoreData(hasMore))
                    ])
                }
                .catch { _ in
                    return .concat([
                        .just(.setLoadingMore(false)),
                        .just(.setError("더 많은 여행 기록을 불러오는 중 오류가 발생했습니다."))
                    ])
                }
        ])
    }

    private func loadTrips(sortedBy sortOption: TripSortOption, month: Date?) -> Observable<Mutation> {
        let tripsObservable: Single<[Trip]>

        if let month = month {
            tripsObservable = getTripsUseCase.execute(forMonth: month)
        } else {
            tripsObservable = getTripsUseCase.execute(sortedBy: sortOption)
        }

        return tripsObservable
            .asObservable()
            .map { Mutation.setTrips($0) }
            .catch { _ in
                return .just(.setError("여행 기록을 불러오는 중 오류가 발생했습니다."))
            }
    }

    private func loadFilteredListTrips(mode: ListFilterMode, year: Int, month: Int) -> Observable<Mutation> {
        return getTripsUseCase.execute(sortedBy: .newest)
            .asObservable()
            .flatMap { [weak self] allTrips -> Observable<Mutation> in
                guard let self = self else { return .empty() }

                let filteredTrips: [Trip]
                switch mode {
                case .all:
                    filteredTrips = allTrips
                case .byYear:
                    filteredTrips = allTrips.filter { trip in
                        let tripYear = Calendar.current.component(.year, from: trip.startDate)
                        return tripYear == year
                    }
                case .byMonth:
                    filteredTrips = allTrips.filter { trip in
                        let calendar = Calendar.current
                        let tripYear = calendar.component(.year, from: trip.startDate)
                        let tripMonth = calendar.component(.month, from: trip.startDate)
                        return tripYear == year && tripMonth == month
                    }
                }

                let initialTrips = Array(filteredTrips.prefix(self.pageSize))
                let hasMore = filteredTrips.count > self.pageSize

                return .concat([
                    .just(.setTotalTripCount(filteredTrips.count)),
                    .just(.setListTrips(initialTrips)),
                    .just(.setCurrentPage(1)),
                    .just(.setHasMoreData(hasMore))
                ])
            }
            .catch { _ in
                return .just(.setError("여행 기록을 불러오는 중 오류가 발생했습니다."))
            }
    }

    // MARK: - Track Assignment

    private func calculateTripTracks(trips: [Trip]) -> [String: Int] {
        var tripTracks: [String: Int] = [:]
        let sortedTrips = trips.sorted { $0.startDate < $1.startDate }
        var trackEndDates: [Date] = []

        for trip in sortedTrips {
            let calendar = Calendar.current
            let tripStart = calendar.startOfDay(for: trip.startDate)

            var assignedTrack = -1

            for (trackIndex, trackEndDate) in trackEndDates.enumerated() {
                let trackEnd = calendar.startOfDay(for: trackEndDate)

                if tripStart > trackEnd {
                    assignedTrack = trackIndex
                    trackEndDates[trackIndex] = trip.endDate
                    break
                }
            }

            if assignedTrack == -1 {
                assignedTrack = trackEndDates.count
                trackEndDates.append(trip.endDate)
            }

            tripTracks[trip.id] = assignedTrack
        }

        return tripTracks
    }

    /// 여행 데이터가 존재하는 년도 추출 (내림차순 정렬)
    private func extractAvailableYears(from trips: [Trip]) -> [Int] {
        let calendar = Calendar.current
        let years = trips.map { calendar.component(.year, from: $0.startDate) }
        let uniqueYears = Set(years)
        return Array(uniqueYears).sorted(by: >)
    }
}
