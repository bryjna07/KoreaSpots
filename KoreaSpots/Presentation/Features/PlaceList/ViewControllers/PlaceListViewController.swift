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

        init(place: Place) {
            self.id = place.contentId
            self.place = place
        }

        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }

        static func == (lhs: PlaceItem, rhs: PlaceItem) -> Bool {
            return lhs.id == rhs.id
        }
    }

    // MARK: - Properties
    var disposeBag = DisposeBag()
    private let placeListView = PlaceListView()
    private var dataSource: UICollectionViewDiffableDataSource<Section, PlaceItem>!

    private lazy var emptyStateView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
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
        setupUI()
        setupEmptyState()
        setupDataSource()
        setupCollectionView()
    }

    // MARK: - Bind
    func bind(reactor: PlaceListReactor) {
        // Load sigungu data
        SigunguStore.loadFromBundleAsync(fileName: "sigungu_codes") { success in
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

        // Action: loadNextPage (infinite scroll)
        placeListView.collectionView.rx.willDisplayCell
            .filter { [weak self] _, indexPath in
                guard let self = self,
                      let reactor = self.reactor else { return false }
                let itemCount = reactor.currentState.places.count
                return indexPath.item >= itemCount - 5 && reactor.currentState.hasMorePages
            }
            .map { _ in PlaceListReactor.Action.loadNextPage }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        // State: places
        reactor.state
            .map { state -> (places: [Place], area: AreaCode?, contentType: Int?, cat3: String?) in
                return (state.places, state.selectedArea, state.contentTypeId, state.cat3)
            }
            .distinctUntilChanged { prev, curr in
                let placesEqual = prev.places == curr.places
                let areaEqual = prev.area == curr.area
                let contentTypeEqual = prev.contentType == curr.contentType
                let cat3Equal = prev.cat3 == curr.cat3
                return placesEqual && areaEqual && contentTypeEqual && cat3Equal
            }
            .asDriver(onErrorJustReturn: (places: [], area: nil, contentType: nil, cat3: nil))
            .drive(with: self) { owner, data in
                owner.applySnapshot(places: data.places)
                owner.updateEmptyState(
                    isEmpty: data.places.isEmpty,
                    selectedArea: data.area,
                    contentTypeId: data.contentType,
                    cat3: data.cat3
                )
            }
            .disposed(by: disposeBag)

        // State: isLoading
        reactor.state
            .map { $0.isLoading }
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: false)
            .drive(with: self) { owner, isLoading in
                if isLoading {
                    // TODO: Show loading indicator
                } else {
                    // TODO: Hide loading indicator
                }
            }
            .disposed(by: disposeBag)

        // State: error
        reactor.state
            .compactMap { $0.error }
            .asDriver(onErrorJustReturn: "Unknown error")
            .drive(with: self) { owner, error in
                owner.showErrorAlert(message: error)
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
    private func setupUI() {
        navigationController?.navigationBar.prefersLargeTitles = false
    }

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
        let cellRegistration = UICollectionView.CellRegistration<PlaceListCell, PlaceItem> { cell, indexPath, item in
            cell.configure(with: item.place)
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
        guard SigunguStore.isLoaded else {
            print("⚠️ SigunguStore not loaded yet")
            return []
        }

        var sigungus: [(code: Int, name: String)] = []
        for code in 1...999 {
            if let name = SigunguStore.name(areaCode: areaCode, sigunguCode: code, preferred: .ko) {
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
        placeListView.sigunguChipStackView.arrangedSubviews.enumerated().forEach { index, view in
            guard let button = view as? UIButton, var config = button.configuration else { return }

            let isSelected = (index == 0 && selectedSigungu == nil) || (index > 0 && selectedSigungu != nil)
            config.baseForegroundColor = isSelected ? .white : .label
            config.baseBackgroundColor = isSelected ? .systemBlue : .clear
            config.background.strokeColor = isSelected ? .systemBlue : .separator

            button.configuration = config
        }
    }

    private func applySnapshot(places: [Place]) {
        guard let dataSource = dataSource else {
            print("⚠️ DataSource is nil, skipping snapshot apply")
            return
        }

        var snapshot = NSDiffableDataSourceSnapshot<Section, PlaceItem>()
        snapshot.appendSections([.main])
        snapshot.appendItems(places.map { PlaceItem(place: $0) }, toSection: .main)
        dataSource.apply(snapshot, animatingDifferences: true)
    }

    private func updateEmptyState(isEmpty: Bool, selectedArea: AreaCode?, contentTypeId: Int?, cat3: String?) {
        emptyStateView.isHidden = !isEmpty
        guard isEmpty else { return }

        // 카테고리명 결정
        var categoryName = ""

        // 1. cat3 기반 테마명 (우선순위 최상)
        if let cat3 = cat3, !cat3.isEmpty {
            let cat3List = cat3.split(separator: ",").map { String($0.trimmingCharacters(in: .whitespaces)) }
            if let firstCat3 = cat3List.first,
               let theme = Theme12.allCases.first(where: {
                   $0.query.cat3Filters.map { $0.rawValue }.contains(firstCat3)
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
