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
        case setStatistics(TripStatistics)
        case setSortOption(TripSortOption)
        case setSelectedMonth(Date?)
        case setError(String)
    }

    struct State {
        var isLoading: Bool = false
        var trips: [Trip] = []
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
}
