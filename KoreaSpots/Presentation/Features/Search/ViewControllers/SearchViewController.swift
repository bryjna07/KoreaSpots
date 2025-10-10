//
//  SearchViewController.swift
//  KoreaSpots
//
//  Created by YoungJin on 10/09/25.
//

import UIKit
import ReactorKit
import RxSwift
import RxCocoa
import SnapKit

final class SearchViewController: BaseViewController, View, ScreenNavigatable {

    // MARK: - Section & Item

    enum RecentKeywordSection: Hashable {
        case main
    }

    struct RecentKeywordItem: Hashable {
        let keyword: String

        func hash(into hasher: inout Hasher) {
            hasher.combine(keyword)
        }

        static func == (lhs: RecentKeywordItem, rhs: RecentKeywordItem) -> Bool {
            return lhs.keyword == rhs.keyword
        }
    }

    enum ResultSection: Hashable {
        case main
    }

    struct PlaceItem: Hashable {
        let id: String
        let place: Place
        let isFavorite: Bool

        init(place: Place, isFavorite: Bool = false) {
            self.id = place.contentId
            self.place = place
            self.isFavorite = isFavorite
        }

        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }

        static func == (lhs: PlaceItem, rhs: PlaceItem) -> Bool {
            return lhs.id == rhs.id && lhs.isFavorite == rhs.isFavorite
        }
    }

    // MARK: - Properties

    var disposeBag = DisposeBag()
    private let searchView = SearchView()

    private var recentKeywordsDataSource: UICollectionViewDiffableDataSource<RecentKeywordSection, RecentKeywordItem>!
    private var resultsDataSource: UICollectionViewDiffableDataSource<ResultSection, PlaceItem>!

    // MARK: - Lifecycle

    override func loadView() {
        view = searchView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupDataSources()
        setupCollectionViews()
    }

    // MARK: - Bind

    func bind(reactor: SearchReactor) {
        // Action: Search button tap
        searchView.searchButton.rx.tap
            .map { SearchReactor.Action.search }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        // Action: Search bar text change
        searchView.searchBar.rx.text.orEmpty
            .distinctUntilChanged()
            .map { SearchReactor.Action.updateKeyword($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        // Action: Search bar return key
        searchView.searchBar.rx.searchButtonClicked
            .map { SearchReactor.Action.search }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        // Action: Clear all recent keywords
        searchView.clearAllButton.rx.tap
            .bind(with: self) { owner, _ in
                owner.showClearAllAlert(reactor: reactor)
            }
            .disposed(by: disposeBag)

        // Setup filter chips
        setupRegionChips(reactor: reactor)
        setupContentTypeChips(reactor: reactor)

        // State: Recent keywords
        reactor.state
            .map { $0.recentKeywords }
            .asDriver(onErrorJustReturn: [])
            .drive(with: self) { owner, keywords in
                owner.applyRecentKeywordsSnapshot(keywords: keywords)
            }
            .disposed(by: disposeBag)

        // State: Search results + favorites
        reactor.state
            .map { state -> (results: [Place], favorites: [String: Bool]) in
                return (state.searchResults, state.favorites)
            }
            .distinctUntilChanged { prev, curr in
                let resultsEqual = prev.results == curr.results
                let favoritesEqual = prev.favorites == curr.favorites
                return resultsEqual && favoritesEqual
            }
            .asDriver(onErrorJustReturn: (results: [], favorites: [:]))
            .drive(with: self) { owner, data in
                owner.applyResultsSnapshot(places: data.results)
            }
            .disposed(by: disposeBag)

        // State: UI visibility (combined state)
        Observable.combineLatest(
            reactor.state.map { $0.searchResults },
            reactor.state.map { $0.hasSearched },
            reactor.state.map { $0.isSearching }
        )
        .asDriver(onErrorJustReturn: ([], false, false))
        .drive(with: self) { owner, state in
            let (results, hasSearched, isSearching) = state

            if !hasSearched {
                // 검색 전 - 최근 검색어 섹션 표시
                owner.searchView.showRecentKeywordsSection()
            } else if isSearching {
                // 검색 중이면 현재 상태 유지
                return
            } else if results.isEmpty {
                // 검색 결과 없음
                owner.searchView.showEmptyState()
            } else {
                // 검색 결과 있음
                owner.searchView.showSearchResults()
            }
        }
        .disposed(by: disposeBag)

        // State: isSearching
        reactor.state
            .map { $0.isSearching }
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: false)
            .drive(with: self) { owner, isSearching in
                if isSearching {
                    // TODO: Show loading indicator
                } else {
                    // TODO: Hide loading indicator
                }
            }
            .disposed(by: disposeBag)

        // State: error (한번만 표시)
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

        // State: Toast message
        reactor.pulse(\.$toastMessage)
            .compactMap { $0 }
            .asDriver(onErrorJustReturn: "")
            .drive(with: self) { owner, message in
                owner.showToast(message: message)
            }
            .disposed(by: disposeBag)

        // Infinite scroll for results
        searchView.resultsCollectionView.rx.willDisplayCell
            .filter { [weak self] _, indexPath in
                guard let self = self,
                      let reactor = self.reactor else { return false }
                let itemCount = reactor.currentState.searchResults.count
                return indexPath.item >= itemCount - 5 && reactor.currentState.hasMorePages
            }
            .map { _ in SearchReactor.Action.loadNextPage }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        // Cell selection: Results
        searchView.resultsCollectionView.rx.itemSelected
            .compactMap { [weak self] indexPath -> Place? in
                guard let self = self,
                      let item = self.resultsDataSource.itemIdentifier(for: indexPath) else {
                    return nil
                }
                return item.place
            }
            .bind(with: self) { owner, place in
                owner.navigateToPlaceDetail(place: place)
            }
            .disposed(by: disposeBag)
    }

    // MARK: - Setup

    private func setupUI() {
        title = "검색"
        navigationController?.navigationBar.prefersLargeTitles = false

        // Initially show recent keywords section
        searchView.showRecentKeywordsSection()
    }

    private func setupDataSources() {
        // Recent keywords data source
        let recentKeywordCellRegistration = UICollectionView.CellRegistration<RecentKeywordCell, RecentKeywordItem> { [weak self] cell, indexPath, item in
            guard let self = self else { return }

            cell.configure(with: item.keyword)
            cell.onDeleteTapped = { [weak self] in
                guard let self = self else { return }
                // 즉시 UI에서 제거
                var currentKeywords = self.reactor?.currentState.recentKeywords ?? []
                currentKeywords.removeAll { $0 == item.keyword }
                self.applyRecentKeywordsSnapshot(keywords: currentKeywords)
                // Action 전송
                self.reactor?.action.onNext(.deleteRecentKeyword(item.keyword))
            }

            // Tap to search
            cell.contentView.gestureRecognizers?.forEach { cell.contentView.removeGestureRecognizer($0) }
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.recentKeywordCellTapped(_:)))
            cell.contentView.addGestureRecognizer(tapGesture)
            cell.tag = indexPath.item
        }

        recentKeywordsDataSource = UICollectionViewDiffableDataSource<RecentKeywordSection, RecentKeywordItem>(
            collectionView: searchView.recentKeywordsCollectionView
        ) { collectionView, indexPath, item in
            return collectionView.dequeueConfiguredReusableCell(
                using: recentKeywordCellRegistration,
                for: indexPath,
                item: item
            )
        }

        // DataSource 초기화 후 현재 State의 최근 검색어를 즉시 적용
        if let currentKeywords = reactor?.currentState.recentKeywords, !currentKeywords.isEmpty {
            print("🔄 Applying initial recent keywords from current state: \(currentKeywords)")
            applyRecentKeywordsSnapshot(keywords: currentKeywords)
        }

        // Results data source
        let resultCellRegistration = UICollectionView.CellRegistration<PlaceListCell, PlaceItem> { [weak self] cell, indexPath, item in
            guard let self = self else { return }

            cell.configure(with: item.place, showTag: true, isFavorite: item.isFavorite)

            // Favorite button tap with alert for removal
            cell.favoriteButton.rx.tap
                .bind(with: self) { owner, _ in
                    if item.isFavorite {
                        owner.showDeleteConfirmAlert(
                            title: "즐겨찾기 삭제",
                            message: "즐겨찾기에서 삭제하시겠습니까?"
                        ) {
                            owner.reactor?.action.onNext(.toggleFavorite(item.place, item.isFavorite))
                        }
                    } else {
                        owner.reactor?.action.onNext(.toggleFavorite(item.place, item.isFavorite))
                    }
                }
                .disposed(by: cell.disposeBag)
        }

        resultsDataSource = UICollectionViewDiffableDataSource<ResultSection, PlaceItem>(
            collectionView: searchView.resultsCollectionView
        ) { collectionView, indexPath, item in
            return collectionView.dequeueConfiguredReusableCell(
                using: resultCellRegistration,
                for: indexPath,
                item: item
            )
        }
    }

    private func setupCollectionViews() {
        // Recent keywords collection view
        searchView.recentKeywordsCollectionView.register(
            RecentKeywordCell.self,
            forCellWithReuseIdentifier: RecentKeywordCell.reuseIdentifier
        )

        // Results collection view
        searchView.resultsCollectionView.register(
            PlaceListCell.self,
            forCellWithReuseIdentifier: PlaceListCell.reuseIdentifier
        )

        // Configure results collection view layout
        if let layout = searchView.resultsCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            let width = UIScreen.main.bounds.width - 32
            layout.itemSize = CGSize(width: width, height: 120)
        }
    }

    // MARK: - Filter Chips

    private func setupRegionChips(reactor: SearchReactor) {
        searchView.regionChipStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        let allRegions: [AreaCode?] = [nil] + AreaCode.allCases

        allRegions.enumerated().forEach { index, areaCode in
            let title = areaCode?.displayName ?? "전체"
            let chip = searchView.createChipButton(title: title, isSelected: false, isSmall: false)

            chip.rx.tap
                .bind(with: self) { owner, _ in
                    // 즉시 UI 업데이트
                    owner.searchView.updateChipSelection(
                        in: owner.searchView.regionChipStackView,
                        selectedIndex: index
                    )
                    // Action 전송
                    reactor.action.onNext(.selectArea(areaCode))
                }
                .disposed(by: disposeBag)

            searchView.regionChipStackView.addArrangedSubview(chip)
        }

        // Apply initial selection after chips are created
        updateRegionChipSelection(selectedArea: reactor.currentState.selectedArea)
    }

    private func setupContentTypeChips(reactor: SearchReactor) {
        searchView.contentTypeChipStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        let contentTypes: [(id: Int?, name: String)] = [
            (nil, "전체"),
            (12, "관광지"),
            (14, "문화시설"),
            (15, "축제/행사"),
            (25, "여행코스"),
            (28, "레포츠"),
            (32, "숙박"),
            (38, "쇼핑"),
            (39, "음식점")
        ]

        contentTypes.enumerated().forEach { index, type in
            let chip = searchView.createChipButton(title: type.name, isSelected: false, isSmall: true)

            chip.rx.tap
                .bind(with: self) { owner, _ in
                    // 즉시 UI 업데이트
                    owner.searchView.updateChipSelection(
                        in: owner.searchView.contentTypeChipStackView,
                        selectedIndex: index
                    )
                    // Action 전송
                    reactor.action.onNext(.selectContentType(type.id))
                }
                .disposed(by: disposeBag)

            searchView.contentTypeChipStackView.addArrangedSubview(chip)
        }

        // Apply initial selection after chips are created
        updateContentTypeChipSelection(selectedContentType: reactor.currentState.selectedContentType)
    }

    private func updateRegionChipSelection(selectedArea: AreaCode?) {
        let allRegions: [AreaCode?] = [nil] + AreaCode.allCases
        if let selectedIndex = allRegions.firstIndex(where: { $0 == selectedArea }) {
            searchView.updateChipSelection(
                in: searchView.regionChipStackView,
                selectedIndex: selectedIndex
            )
        }
    }

    private func updateContentTypeChipSelection(selectedContentType: Int?) {
        let contentTypes: [Int?] = [nil, 12, 14, 15, 25, 28, 32, 38, 39]
        if let selectedIndex = contentTypes.firstIndex(where: { $0 == selectedContentType }) {
            searchView.updateChipSelection(
                in: searchView.contentTypeChipStackView,
                selectedIndex: selectedIndex
            )
        }
    }

    // MARK: - Snapshots

    private func applyRecentKeywordsSnapshot(keywords: [String]) {
        guard recentKeywordsDataSource != nil else {
            print("⚠️ recentKeywordsDataSource is not initialized yet, keywords: \(keywords)")
            return
        }

        print("✅ Applying recent keywords snapshot: \(keywords)")
        var snapshot = NSDiffableDataSourceSnapshot<RecentKeywordSection, RecentKeywordItem>()
        snapshot.appendSections([.main])
        snapshot.appendItems(keywords.map { RecentKeywordItem(keyword: $0) }, toSection: .main)
        recentKeywordsDataSource.apply(snapshot, animatingDifferences: true)
    }

    private func applyResultsSnapshot(places: [Place]) {
        guard resultsDataSource != nil, let reactor = reactor else {
            print("⚠️ resultsDataSource is not initialized yet")
            return
        }

        let items = places.map { place in
            let isFavorite = reactor.currentState.favorites[place.contentId] ?? false
            return PlaceItem(place: place, isFavorite: isFavorite)
        }

        var snapshot = NSDiffableDataSourceSnapshot<ResultSection, PlaceItem>()
        snapshot.appendSections([.main])
        snapshot.appendItems(items, toSection: .main)
        resultsDataSource.apply(snapshot, animatingDifferences: true)
    }

    // MARK: - Actions

    @objc private func recentKeywordCellTapped(_ gesture: UITapGestureRecognizer) {
        guard let cell = gesture.view?.superview as? RecentKeywordCell,
              let indexPath = searchView.recentKeywordsCollectionView.indexPath(for: cell),
              let item = recentKeywordsDataSource.itemIdentifier(for: indexPath) else {
            return
        }

        reactor?.action.onNext(.selectRecentKeyword(item.keyword))
    }

    private func showClearAllAlert(reactor: SearchReactor) {
        showDeleteConfirmAlert(
            title: "전체 삭제",
            message: "모든 최근 검색어를 삭제하시겠습니까?"
        ) { [weak self] in
            // 즉시 UI 업데이트
            self?.applyRecentKeywordsSnapshot(keywords: [])
            // Action 전송
            reactor.action.onNext(.clearAllRecentKeywords)
        }
    }

    // MARK: - Navigation

    func navigateToPlaceDetail(place: Place) {
        let viewController = AppContainer.shared.makePlaceDetailViewController(place: place)
        navigationController?.pushViewController(viewController, animated: true)
    }

}
