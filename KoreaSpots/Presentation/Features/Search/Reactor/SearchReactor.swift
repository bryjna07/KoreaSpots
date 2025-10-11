//
//  SearchReactor.swift
//  KoreaSpots
//
//  Created by YoungJin on 10/09/25.
//

import Foundation
import ReactorKit
import RxSwift
import RxCocoa

final class SearchReactor: Reactor {

    enum Action {
        case updateKeyword(String)
        case search
        case selectRecentKeyword(String)
        case deleteRecentKeyword(String)
        case clearAllRecentKeywords
        case selectArea(AreaCode?)
        case selectSigungu(Int?)
        case selectContentType(Int?)
        case loadNextPage
        case toggleFavorite(Place, Bool) // contentId, currentIsFavorite
    }

    enum Mutation {
        case setKeyword(String)
        case setSearching(Bool)
        case setResults([Place])
        case appendResults([Place])
        case setRecentKeywords([String])
        case setSelectedArea(AreaCode?)
        case setSelectedSigungu(Int?)
        case setSelectedContentType(Int?)
        case setError(String)
        case setHasMorePages(Bool)
        case setCurrentPage(Int)
        case setHasSearched(Bool)
        case setFavorites([String: Bool]) // contentId: isFavorite
        case showToast(String)
    }

    struct State {
        var keyword: String = ""
        var isSearching: Bool = false
        var searchResults: [Place] = []
        var recentKeywords: [String] = []
        var selectedArea: AreaCode?
        var selectedSigungu: Int?
        var selectedContentType: Int?
        var favorites: [String: Bool] = [:] // contentId: isFavorite
        var error: String?
        var hasMorePages: Bool = false
        var currentPage: Int = 1
        var hasSearched: Bool = false // 검색 실행 여부 추적
        @Pulse var toastMessage: String?
    }

    let initialState = State()

    private let searchPlacesUseCase: SearchPlacesUseCase
    private let getRecentKeywordsUseCase: GetRecentKeywordsUseCase
    private let deleteRecentKeywordUseCase: DeleteRecentKeywordUseCase
    private let clearAllRecentKeywordsUseCase: ClearAllRecentKeywordsUseCase
    private let checkFavoriteUseCase: CheckFavoriteUseCase
    private let toggleFavoriteUseCase: ToggleFavoriteUseCase

    init(
        searchPlacesUseCase: SearchPlacesUseCase,
        getRecentKeywordsUseCase: GetRecentKeywordsUseCase,
        deleteRecentKeywordUseCase: DeleteRecentKeywordUseCase,
        clearAllRecentKeywordsUseCase: ClearAllRecentKeywordsUseCase,
        checkFavoriteUseCase: CheckFavoriteUseCase,
        toggleFavoriteUseCase: ToggleFavoriteUseCase
    ) {
        self.searchPlacesUseCase = searchPlacesUseCase
        self.getRecentKeywordsUseCase = getRecentKeywordsUseCase
        self.deleteRecentKeywordUseCase = deleteRecentKeywordUseCase
        self.clearAllRecentKeywordsUseCase = clearAllRecentKeywordsUseCase
        self.checkFavoriteUseCase = checkFavoriteUseCase
        self.toggleFavoriteUseCase = toggleFavoriteUseCase
    }

    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .updateKeyword(let keyword):
            return .concat([
                .just(.setKeyword(keyword)),
                .just(.setError("")) // 키워드 변경 시 에러 초기화
            ])

        case .search:
            // Reset pagination - hasSearched는 검색 성공 후 설정
            let resetMutations: [Mutation] = [
                .setSearching(true),
                .setCurrentPage(1),
                .setError("")
            ]

            // Perform search using UseCase
            let searchMutation = performSearch(page: 1)

            return .concat([
                .from(resetMutations),
                searchMutation
            ])

        case .selectRecentKeyword(let keyword):
            return .concat([
                .just(.setKeyword(keyword)),
                mutate(action: .search)
            ])

        case .deleteRecentKeyword(let keyword):
            return deleteRecentKeywordUseCase.execute(keyword: keyword)
                .asObservable()
                .flatMap { _ in
                    self.getRecentKeywordsUseCase.execute(limit: 10)
                        .asObservable()
                }
                .map { Mutation.setRecentKeywords($0) }
                .catch { error in
                    print("❌ Delete recent keyword error: \(error)")
                    return .just(.setRecentKeywords(self.currentState.recentKeywords))
                }

        case .clearAllRecentKeywords:
            return clearAllRecentKeywordsUseCase.execute()
                .asObservable()
                .map { _ in Mutation.setRecentKeywords([]) }
                .catch { error in
                    print("❌ Clear all keywords error: \(error)")
                    return .just(.setError("검색어 삭제 중 오류가 발생했습니다."))
                }

        case .selectArea(let areaCode):
            // 검색 전이면 State만 변경, 검색 후라면 즉시 재검색
            if !currentState.hasSearched || currentState.keyword.count < 2 {
                return .concat([
                    .just(.setSelectedArea(areaCode)),
                    .just(.setSelectedSigungu(nil))
                ])
            }
            // 검색 후 필터 변경 시 즉시 재검색 (State 변경 후 검색)
            return Observable.concat([
                Observable.just(.setSelectedArea(areaCode)),
                Observable.just(.setSelectedSigungu(nil)),
                Observable.just(.setSearching(true)),
                Observable.just(.setCurrentPage(1))
            ])
            .concat(
                // State가 업데이트된 후 검색 실행을 위해 지연
                Observable<Mutation>.create { [weak self] observer in
                    guard let self = self else {
                        observer.onCompleted()
                        return Disposables.create()
                    }

                    let input = SearchPlacesInput(
                        keyword: self.currentState.keyword,
                        areaCode: areaCode?.rawValue, // 새로운 값 직접 사용
                        sigunguCode: nil, // 지역 변경시 시군구 초기화
                        contentTypeId: self.currentState.selectedContentType,
                        cat1: nil,
                        cat2: nil,
                        cat3: nil,
                        page: 1,
                        sortOption: .title,
                        shouldSaveToRecent: false
                    )

                    self.searchPlacesUseCase.execute(input)
                        .asObservable()
                        .flatMap { places -> Observable<Mutation> in
                            let hasMore = places.count >= 20
                            return .from([
                                .setResults(places),
                                .setHasMorePages(hasMore)
                            ])
                        }
                        .catch { error in
                            print("❌ Search error: \(error)")
                            let errorMessage: String
                            if let useCaseError = error as? SearchUseCaseError {
                                errorMessage = useCaseError.localizedDescription
                            } else {
                                errorMessage = "검색 중 오류가 발생했습니다."
                            }
                            return .just(.setError(errorMessage))
                        }
                        .subscribe(observer)

                    return Disposables.create()
                }
            )

        case .selectSigungu(let sigunguCode):
            if !currentState.hasSearched || currentState.keyword.count < 2 {
                return .just(.setSelectedSigungu(sigunguCode))
            }
            return Observable.concat([
                Observable.just(.setSelectedSigungu(sigunguCode)),
                Observable.just(.setSearching(true)),
                Observable.just(.setCurrentPage(1))
            ])
            .concat(
                Observable<Mutation>.create { [weak self] observer in
                    guard let self = self else {
                        observer.onCompleted()
                        return Disposables.create()
                    }

                    let input = SearchPlacesInput(
                        keyword: self.currentState.keyword,
                        areaCode: self.currentState.selectedArea?.rawValue,
                        sigunguCode: sigunguCode, // 새로운 값 직접 사용
                        contentTypeId: self.currentState.selectedContentType,
                        cat1: nil,
                        cat2: nil,
                        cat3: nil,
                        page: 1,
                        sortOption: .title,
                        shouldSaveToRecent: false
                    )

                    self.searchPlacesUseCase.execute(input)
                        .asObservable()
                        .flatMap { places -> Observable<Mutation> in
                            let hasMore = places.count >= 20
                            return .from([
                                .setResults(places),
                                .setHasMorePages(hasMore)
                            ])
                        }
                        .catch { error in
                            print("❌ Search error: \(error)")
                            let errorMessage: String
                            if let useCaseError = error as? SearchUseCaseError {
                                errorMessage = useCaseError.localizedDescription
                            } else {
                                errorMessage = "검색 중 오류가 발생했습니다."
                            }
                            return .just(.setError(errorMessage))
                        }
                        .subscribe(observer)

                    return Disposables.create()
                }
            )

        case .selectContentType(let contentTypeId):
            if !currentState.hasSearched || currentState.keyword.count < 2 {
                return .just(.setSelectedContentType(contentTypeId))
            }
            return Observable.concat([
                Observable.just(.setSelectedContentType(contentTypeId)),
                Observable.just(.setSearching(true)),
                Observable.just(.setCurrentPage(1))
            ])
            .concat(
                Observable<Mutation>.create { [weak self] observer in
                    guard let self = self else {
                        observer.onCompleted()
                        return Disposables.create()
                    }

                    let input = SearchPlacesInput(
                        keyword: self.currentState.keyword,
                        areaCode: self.currentState.selectedArea?.rawValue,
                        sigunguCode: self.currentState.selectedSigungu,
                        contentTypeId: contentTypeId, // 새로운 값 직접 사용
                        cat1: nil,
                        cat2: nil,
                        cat3: nil,
                        page: 1,
                        sortOption: .title,
                        shouldSaveToRecent: false
                    )

                    self.searchPlacesUseCase.execute(input)
                        .asObservable()
                        .flatMap { places -> Observable<Mutation> in
                            let hasMore = places.count >= 20
                            return .from([
                                .setResults(places),
                                .setHasMorePages(hasMore)
                            ])
                        }
                        .catch { error in
                            print("❌ Search error: \(error)")
                            let errorMessage: String
                            if let useCaseError = error as? SearchUseCaseError {
                                errorMessage = useCaseError.localizedDescription
                            } else {
                                errorMessage = "검색 중 오류가 발생했습니다."
                            }
                            return .just(.setError(errorMessage))
                        }
                        .subscribe(observer)

                    return Disposables.create()
                }
            )

        case .loadNextPage:
            guard currentState.hasMorePages, !currentState.isSearching else {
                return .empty()
            }

            let nextPage = currentState.currentPage + 1
            return .concat([
                .just(.setSearching(true)),
                .just(.setCurrentPage(nextPage)),
                performSearch(page: nextPage, appendResults: true)
            ])

        case .toggleFavorite(let place, let isFavorite):
            let placeName = place.title

            return toggleFavoriteUseCase.execute(place: place, isFavorite: isFavorite)
                .andThen(Observable.just(()))
                .flatMap { _ -> Observable<Mutation> in
                    let toastMessage = isFavorite ? "" : "\(placeName)이(가) 즐겨찾기에 추가되었습니다."
                    return Observable.concat([
                        self.checkFavoriteStatus(contentId: place.contentId),
                        isFavorite ? .empty() : .just(.showToast(toastMessage))
                    ])
                }
                .catch { error in
                    print("❌ Toggle favorite error: \(error)")
                    return .just(.setError("즐겨찾기 변경 중 오류가 발생했습니다."))
                }
        }
    }

    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state

        switch mutation {
        case .setKeyword(let keyword):
            newState.keyword = keyword
            // 검색어가 비어지면 hasSearched 초기화
            if keyword.isEmpty {
                newState.hasSearched = false
            }

        case .setSearching(let isSearching):
            newState.isSearching = isSearching

        case .setResults(let results):
            newState.searchResults = results
            newState.isSearching = false

        case .appendResults(let results):
            newState.searchResults.append(contentsOf: results)
            newState.isSearching = false

        case .setRecentKeywords(let keywords):
            newState.recentKeywords = keywords

        case .setSelectedArea(let areaCode):
            newState.selectedArea = areaCode

        case .setSelectedSigungu(let sigunguCode):
            newState.selectedSigungu = sigunguCode

        case .setSelectedContentType(let contentTypeId):
            newState.selectedContentType = contentTypeId

        case .setError(let error):
            newState.error = error
            newState.isSearching = false

        case .setHasMorePages(let hasMore):
            newState.hasMorePages = hasMore

        case .setCurrentPage(let page):
            newState.currentPage = page

        case .setHasSearched(let hasSearched):
            newState.hasSearched = hasSearched

        case .setFavorites(let favorites):
            newState.favorites = favorites

        case .showToast(let message):
            newState.toastMessage = message
        }

        return newState
    }

    func transform(mutation: Observable<Mutation>) -> Observable<Mutation> {
        // Initial load of recent keywords when reactor is initialized
        let initialKeywords = getRecentKeywordsUseCase.execute(limit: 10)
            .asObservable()
            .map { Mutation.setRecentKeywords($0) }
            .catchAndReturn(Mutation.setRecentKeywords([]))

        // SearchResults가 변경될 때마다 즐겨찾기 상태 체크
        let favoritesUpdate = mutation
            .compactMap { mutation -> [Place]? in
                switch mutation {
                case .setResults(let places), .appendResults(let places):
                    return places
                default:
                    return nil
                }
            }
            .flatMap { places -> Observable<Mutation> in
                let contentIds = places.map { $0.contentId }
                return self.checkFavoritesStatus(contentIds: contentIds)
            }

        return Observable.merge(mutation, initialKeywords, favoritesUpdate)
    }

    func transform(state: Observable<State>) -> Observable<State> {
        return state
    }

    // MARK: - Private Methods

    private func checkFavoriteStatus(contentId: String) -> Observable<Mutation> {
        return checkFavoriteUseCase.execute(contentId: contentId)
            .asObservable()
            .map { isFavorite in
                var favorites = self.currentState.favorites
                favorites[contentId] = isFavorite
                return Mutation.setFavorites(favorites)
            }
            .catch { error in
                print("❌ Check favorite error: \(error)")
                return .empty()
            }
    }

    private func checkFavoritesStatus(contentIds: [String]) -> Observable<Mutation> {
        guard !contentIds.isEmpty else {
            return .empty()
        }

        let checks = contentIds.map { contentId in
            checkFavoriteUseCase.execute(contentId: contentId)
                .map { (contentId, $0) }
        }

        return Single.zip(checks)
            .asObservable()
            .map { results in
                var favorites: [String: Bool] = [:]
                results.forEach { contentId, isFavorite in
                    favorites[contentId] = isFavorite
                }
                return Mutation.setFavorites(favorites)
            }
            .catch { error in
                print("❌ Check favorites error: \(error)")
                return .empty()
            }
    }

    private func performSearch(page: Int, appendResults: Bool = false) -> Observable<Mutation> {
        let input = SearchPlacesInput(
            keyword: currentState.keyword,
            areaCode: currentState.selectedArea?.rawValue,
            sigunguCode: currentState.selectedSigungu,
            contentTypeId: currentState.selectedContentType,
            cat1: nil,
            cat2: nil,
            cat3: nil,
            page: page,
            sortOption: .title,
            shouldSaveToRecent: page == 1 && !appendResults // 첫 페이지 신규 검색 시에만 최근 검색어 저장
        )

        return searchPlacesUseCase.execute(input)
            .asObservable()
            .flatMap { [weak self] places -> Observable<Mutation> in
                guard let self = self else { return .empty() }

                let hasMore = places.count >= 20

                // 첫 페이지 검색 완료 후 최근 검색어 다시 로드 + hasSearched 설정
                if page == 1 && !appendResults {
                    // 검색어 저장 완료 후 최근 검색어 리스트 다시 로드
                    let reloadKeywords = self.getRecentKeywordsUseCase.execute(limit: 10)
                        .asObservable()
                        .map { Mutation.setRecentKeywords($0) }
                        .catchAndReturn(Mutation.setRecentKeywords([]))

                    return .concat([
                        .from([
                            .setResults(places),
                            .setHasMorePages(hasMore),
                            .setHasSearched(true) // 검색 성공 시에만 true
                        ]),
                        reloadKeywords
                    ])
                } else if appendResults {
                    return .from([
                        .appendResults(places),
                        .setHasMorePages(hasMore)
                    ])
                } else {
                    return .from([
                        .setResults(places),
                        .setHasMorePages(hasMore)
                    ])
                }
            }
            .catch { error in
                print("❌ Search error: \(error)")

                // UseCase 에러를 사용자 친화적 메시지로 변환
                let errorMessage: String
                if let useCaseError = error as? SearchUseCaseError {
                    errorMessage = useCaseError.localizedDescription
                } else {
                    errorMessage = "검색 중 오류가 발생했습니다."
                }

                return .just(.setError(errorMessage))
            }
    }

}

///TODO:- 최근검색어 - 처음 눌렀을 때 알럿나오는 문제 해결 필요
