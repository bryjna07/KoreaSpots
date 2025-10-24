//
//  PlaceListViewController.swift
//  KoreaSpots
//
//  Created by YoungJin on 10/08/25.
//

import UIKit
import ReactorKit
import RxSwift
import RxCocoa
import SnapKit

final class PlaceListViewController: BaseViewController, View, ScreenNavigatable {

    // MARK: - Section & Item
    enum Section: Hashable {
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
    private let placeListView = PlaceListView()
    private var dataSource: UICollectionViewDiffableDataSource<Section, PlaceItem>!

    private lazy var emptyStateView: UIView = {
        let view = UIView()
        view.backgroundColor = .backGround
        view.isHidden = true
        return view
    }()

    private lazy var emptyStateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    // MARK: - Lifecycle
    override func loadView() {
        view = placeListView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupEmptyState()
        setupDataSource()
        setupCollectionView()
    }

    // MARK: - Bind
    func bind(reactor: PlaceListReactor) {
        // Load sigungu data
        CodeBookStore.Sigungu.loadFromBundleAsync(fileName: "sigungu_codes") { success in
            if success {
                print("✅ sigungu_codes.json loaded")
            }
        }

        // Setup chips
        setupRegionChips(reactor: reactor)
        setupSigunguChips(reactor: reactor)

        // Action: viewDidLoad
        Observable.just(Void())
            .map { PlaceListReactor.Action.viewDidLoad }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        // Action: loadNextPage (무한 스크롤)
        placeListView.collectionView.rx.prefetchItems
            .compactMap { [weak self] indexPaths -> PlaceListReactor.Action? in
                guard let self,
                      let reactor = self.reactor else { return nil }

                let itemCount = reactor.currentState.places.count
                let threshold = itemCount - 5

                // prefetch된 indexPath 중 하나라도 threshold를 넘으면 다음 페이지 로드
                let shouldLoadNextPage = indexPaths.contains { $0.item >= threshold }

                guard shouldLoadNextPage,
                      reactor.currentState.hasMorePages,
                      !reactor.currentState.isLoading else {
                    return nil
                }

                return .loadNextPage
            }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        // State: places + favorites + isLoading
        reactor.state
            .map { state -> (places: [Place], favorites: [String: Bool], area: AreaCode?, contentType: Int?, cat3: String?, isLoading: Bool) in
                return (state.places, state.favorites, state.selectedArea, state.contentTypeId, state.cat3, state.isLoading)
            }
            .distinctUntilChanged { prev, curr in
                let placesEqual = prev.places == curr.places
                let favoritesEqual = prev.favorites == curr.favorites
                let areaEqual = prev.area == curr.area
                let contentTypeEqual = prev.contentType == curr.contentType
                let cat3Equal = prev.cat3 == curr.cat3
                let loadingEqual = prev.isLoading == curr.isLoading
                return placesEqual && favoritesEqual && areaEqual && contentTypeEqual && cat3Equal && loadingEqual
            }
            .asDriver(onErrorJustReturn: (places: [], favorites: [:], area: nil, contentType: nil, cat3: nil, isLoading: false))
            .drive(with: self) { owner, data in
                owner.applySnapshot(places: data.places)
                owner.updateEmptyState(
                    isEmpty: data.places.isEmpty,
                    isLoading: data.isLoading,
                    selectedArea: data.area,
                    contentTypeId: data.contentType,
                    cat3: data.cat3
                )
            }
            .disposed(by: disposeBag)

        // State: isLoading (removed - skeleton views are handled per cell in setupDataSource)

        // State: error
        reactor.state
            .compactMap { $0.error }
            .asDriver(onErrorJustReturn: "Unknown error")
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

        // State: Update chips when area/sigungu changes
        reactor.state
            .map { $0.selectedArea }
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: nil)
            .drive(with: self) { owner, selectedArea in
                owner.updateRegionChipSelection(selectedArea: selectedArea)
                owner.updateSigunguChips(for: selectedArea, selectedSigungu: nil, reactor: reactor)
            }
            .disposed(by: disposeBag)

        reactor.state
            .map { $0.selectedSigungu }
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: nil)
            .drive(with: self) { owner, selectedSigungu in
                owner.updateSigunguChipSelection(selectedSigungu: selectedSigungu)
            }
            .disposed(by: disposeBag)

        // Cell Selection
        placeListView.collectionView.rx.itemSelected
            .compactMap { [weak self] indexPath -> Place? in
                guard let self = self,
                      let item = self.dataSource.itemIdentifier(for: indexPath) else {
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

    private func setupEmptyState() {
        view.addSubview(emptyStateView)
        emptyStateView.addSubview(emptyStateLabel)

        emptyStateView.snp.makeConstraints {
            $0.edges.equalTo(placeListView.collectionView)
        }

        emptyStateLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(40)
        }
    }

    private func setupDataSource() {
        let cellRegistration = UICollectionView.CellRegistration<PlaceListCell, PlaceItem> { [weak self] cell, indexPath, item in
            guard let self = self else { return }

            cell.configure(with: item.place, showTag: false, isFavorite: item.isFavorite)

            // 스켈레톤 적용
            self.placeListView.collectionView.configureSkeletonIfNeeded(for: cell, with: item.place)

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

        dataSource = UICollectionViewDiffableDataSource<Section, PlaceItem>(
            collectionView: placeListView.collectionView
        ) { collectionView, indexPath, item in
            return collectionView.dequeueConfiguredReusableCell(
                using: cellRegistration,
                for: indexPath,
                item: item
            )
        }
    }

    private func setupCollectionView() {
        placeListView.collectionView.register(
            PlaceListCell.self,
            forCellWithReuseIdentifier: PlaceListCell.reuseIdentifier
        )
    }

    // MARK: - Chips Setup
    private func setupRegionChips(reactor: PlaceListReactor) {
        placeListView.regionChipStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        // 전체 + 17개 시도
        let allRegions: [AreaCode?] = [nil] + AreaCode.allCases

        allRegions.enumerated().forEach { index, areaCode in
            let title = areaCode?.displayName ?? "전체"
            let isSelected = (areaCode == reactor.currentState.selectedArea) ||
                            (areaCode == nil && reactor.currentState.selectedArea == nil)
            let chip = placeListView.createChipButton(title: title, isSelected: isSelected, isSmall: false)

            chip.rx.tap
                .bind(with: self) { owner, _ in
                    reactor.action.onNext(.selectArea(areaCode))
                    owner.placeListView.updateChipSelection(
                        in: owner.placeListView.regionChipStackView,
                        selectedIndex: index
                    )
                }
                .disposed(by: disposeBag)

            placeListView.regionChipStackView.addArrangedSubview(chip)
        }
    }

    private func setupSigunguChips(reactor: PlaceListReactor) {
        guard let selectedArea = reactor.currentState.selectedArea else {
            placeListView.sigunguChipScrollView.isHidden = true
            return
        }

        placeListView.sigunguChipScrollView.isHidden = false
        updateSigunguChips(
            for: selectedArea,
            selectedSigungu: reactor.currentState.selectedSigungu,
            reactor: reactor
        )
    }

    private func updateSigunguChips(for areaCode: AreaCode?, selectedSigungu: Int?, reactor: PlaceListReactor) {
        placeListView.sigunguChipStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        guard let areaCode = areaCode else {
            placeListView.sigunguChipScrollView.isHidden = true
            return
        }

        placeListView.sigunguChipScrollView.isHidden = false

        // Get sigungu list
        let sigungus = getSigungus(for: areaCode)

        // 전체 + 시군구
        let allSigungus: [(code: Int?, name: String)] = [(code: nil, name: "전체")] +
            sigungus.map { (code: $0.code, name: $0.name) }

        allSigungus.enumerated().forEach { index, item in
            let isSelected = (item.code == selectedSigungu) || (item.code == nil && selectedSigungu == nil)
            let chip = placeListView.createChipButton(title: item.name, isSelected: isSelected, isSmall: true)

            chip.rx.tap
                .bind(with: self) { owner, _ in
                    reactor.action.onNext(.selectSigungu(item.code))
                    owner.placeListView.updateChipSelection(
                        in: owner.placeListView.sigunguChipStackView,
                        selectedIndex: index
                    )
                }
                .disposed(by: disposeBag)

            placeListView.sigunguChipStackView.addArrangedSubview(chip)
        }
    }

    private func getSigungus(for areaCode: AreaCode) -> [(code: Int, name: String)] {
        guard CodeBookStore.Sigungu.isLoaded else {
            print("⚠️ CodeBookStore.Sigungu not loaded yet")
            return []
        }

        var sigungus: [(code: Int, name: String)] = []
        for code in 1...999 {
            if let name = CodeBookStore.Sigungu.name(areaCode: areaCode.rawValue, sigunguCode: code, preferred: .ko) {
                sigungus.append((code: code, name: name))
            }
        }
        return sigungus
    }

    private func updateRegionChipSelection(selectedArea: AreaCode?) {
        let allRegions: [AreaCode?] = [nil] + AreaCode.allCases
        if let selectedIndex = allRegions.firstIndex(where: { $0 == selectedArea }) {
            placeListView.updateChipSelection(
                in: placeListView.regionChipStackView,
                selectedIndex: selectedIndex
            )
        }
    }

    private func updateSigunguChipSelection(selectedSigungu: Int?) {
        // updateSigunguChips에서 칩을 재생성하므로 이 메서드는 사용되지 않음
        // State 변경 시 updateSigunguChips가 호출되어 올바른 선택 상태로 칩이 생성됨
    }

    private func applySnapshot(places: [Place]) {
        guard let dataSource = dataSource, let reactor = reactor else {
            print("⚠️ DataSource is nil, skipping snapshot apply")
            return
        }

        let items = places.map { place in
            let isFavorite = reactor.currentState.favorites[place.contentId] ?? false
            return PlaceItem(place: place, isFavorite: isFavorite)
        }

        var snapshot = NSDiffableDataSourceSnapshot<Section, PlaceItem>()
        snapshot.appendSections([.main])
        snapshot.appendItems(items, toSection: .main)
        dataSource.apply(snapshot, animatingDifferences: true)
    }

    private func updateEmptyState(isEmpty: Bool, isLoading: Bool, selectedArea: AreaCode?, contentTypeId: Int?, cat3: String?) {
        // 로딩 중이거나 데이터가 있으면 Empty State 숨김
        emptyStateView.isHidden = isLoading || !isEmpty
        guard !isLoading && isEmpty else { return }

        // 카테고리명 결정
        var categoryName = ""

        // 1. cat3 기반 테마명 (우선순위 최상)
        if let cat3 = cat3, !cat3.isEmpty {
            let cat3List = cat3.split(separator: ",").map { String($0.trimmingCharacters(in: .whitespaces)) }
            if let firstCat3 = cat3List.first,
               let theme = Theme12.allCases.first(where: {
                   $0.query.cat3Filters.contains(firstCat3)
               }) {
                categoryName = theme.displayName
            }
        }

        // 2. contentTypeId 기반
        if categoryName.isEmpty, let contentTypeId = contentTypeId {
            switch contentTypeId {
            case 12: categoryName = "관광지"
            case 14: categoryName = "문화시설"
            case 15: categoryName = "축제/공연/행사"
            case 25: categoryName = "여행코스"
            case 28: categoryName = "레포츠"
            case 32: categoryName = "숙박"
            case 38: categoryName = "쇼핑"
            case 39: categoryName = "음식점"
            default: categoryName = "장소"
            }
        }

        // 3. 지역명
        let areaName = selectedArea?.displayName ?? "전체"

        // 메시지 구성
        if categoryName.isEmpty {
            emptyStateLabel.text = "\(areaName) 데이터가 없습니다."
        } else {
            emptyStateLabel.text = "\(categoryName) 데이터가 없습니다."
        }
    }

    // MARK: - Navigation
    func navigateToPlaceDetail(place: Place) {
        let viewController = AppContainer.shared.makePlaceDetailViewController(place: place)
        navigationController?.pushViewController(viewController, animated: true)
    }

    private func showErrorAlert(message: String) {
        let alert = UIAlertController(
            title: LocalizedKeys.Common.error.localized,
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(
            title: LocalizedKeys.Common.confirm.localized,
            style: .default
        ))
        present(alert, animated: true)
    }
}
