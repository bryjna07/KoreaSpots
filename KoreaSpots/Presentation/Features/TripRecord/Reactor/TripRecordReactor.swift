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

    enum Action {
        case viewDidLoad
        case refresh
        case selectSortOption(TripSortOption)
        case selectMonth(Date?)
        case deleteTrip(String)
    }

    enum Mutation {
        case setLoading(Bool)
        case setTrips([Trip])
        case setAllTrips([Trip])
        case setTripTracks([String: Int])
        case setStatistics(TripStatistics)
        case setSortOption(TripSortOption)
        case setSelectedMonth(Date?)
        case setError(String)
    }

    struct State {
        var isLoading: Bool = false
        var trips: [Trip] = []  // 리스트에 표시할 여행 (필터링된)
        var allTrips: [Trip] = []  // 캘린더에 표시할 전체 여행
        var tripTracks: [String: Int] = [:]  // 여행별 트랙 할당 맵
        var statistics: TripStatistics?
        var sortOption: TripSortOption = .newest
        var selectedMonth: Date?
        var error: String?
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

        case .selectSortOption(let option):
            return .concat([
                .just(.setSortOption(option)),
                .just(.setSelectedMonth(nil)), // 정렬 변경 시 월 필터 해제
                loadTrips(sortedBy: option, month: nil)
            ])

        case .selectMonth(let month):
            return .concat([
                .just(.setSelectedMonth(month)),
                loadTrips(sortedBy: currentState.sortOption, month: month)
            ])

        case .deleteTrip(let tripId):
            print("🗑️ Delete trip action: \(tripId)")
            return deleteTripUseCase.execute(tripId: tripId)
                .andThen(Observable.just(()))
                .do(onNext: { _ in
                    print("✅ Delete completed, reloading data...")
                })
                .flatMap { _ -> Observable<Mutation> in
                    return self.loadData()
                }
                .catch { error in
                    print("❌ Delete trip error: \(error)")
                    return .just(.setError("여행 기록 삭제 중 오류가 발생했습니다."))
                }
        }
    }

    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state

        switch mutation {
        case .setLoading(let isLoading):
            newState.isLoading = isLoading

        case .setTrips(let trips):
            print("📊 Reduce: setTrips(\(trips.count) trips)")
            newState.trips = trips
            newState.isLoading = false

        case .setAllTrips(let trips):
            print("📊 Reduce: setAllTrips(\(trips.count) trips)")
            newState.allTrips = trips

        case .setTripTracks(let tracks):
            newState.tripTracks = tracks

        case .setStatistics(let statistics):
            print("📈 Reduce: setStatistics(total: \(statistics.totalTripCount))")
            newState.statistics = statistics

        case .setSortOption(let option):
            newState.sortOption = option

        case .setSelectedMonth(let month):
            newState.selectedMonth = month

        case .setError(let error):
            newState.error = error
            newState.isLoading = false
        }

        return newState
    }

    // MARK: - Private Methods

    private func loadData() -> Observable<Mutation> {
        return .concat([
            .just(.setLoading(true)),
            loadStatistics(),
            loadAllTrips(),  // 캘린더용 전체 여행
            loadTrips(sortedBy: currentState.sortOption, month: currentState.selectedMonth)
        ])
    }

    private func loadStatistics() -> Observable<Mutation> {
        return getTripStatisticsUseCase.execute()
            .asObservable()
            .map { Mutation.setStatistics($0) }
            .catch { error in
                print("❌ Load statistics error: \(error)")
                return .empty()
            }
    }

    private func loadAllTrips() -> Observable<Mutation> {
        return getTripsUseCase.execute(sortedBy: .newest)
            .asObservable()
            .flatMap { trips -> Observable<Mutation> in
                let tracks = self.calculateTripTracks(trips: trips)
                return .concat([
                    .just(.setAllTrips(trips)),
                    .just(.setTripTracks(tracks))
                ])
            }
            .catch { error in
                print("❌ Load all trips error: \(error)")
                return .empty()
            }
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
            .catch { error in
                print("❌ Load trips error: \(error)")
                return .just(.setError("여행 기록을 불러오는 중 오류가 발생했습니다."))
            }
    }

    // MARK: - Track Assignment

    /// 전체 여행에 대한 트랙 할당 계산 (Apple Calendar 스타일)
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
}
