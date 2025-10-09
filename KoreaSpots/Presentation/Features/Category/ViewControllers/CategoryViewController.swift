//
//  CategoryViewController.swift
//  KoreaSpots
//
//  Created by Claude on 9/30/25.
//

import UIKit
import ReactorKit
import RxSwift
import RxCocoa

final class CategoryViewController: BaseViewController, View, ScreenNavigatable {

    var disposeBag = DisposeBag()

    // MARK: - Section & Item Types
    enum SidebarSection: Hashable {
        case main
    }

    enum GridSection: Hashable {
        case category(Cat2)
    }

    struct GridItem: Hashable {
        let id: String
        let cat3: Cat3

        init(cat3: Cat3) {
            self.id = cat3.rawValue
            self.cat3 = cat3
        }
    }

    // MARK: - UI
    private let categoryView = CategoryView()

    // MARK: - Properties
    private var sidebarDataSource: UICollectionViewDiffableDataSource<SidebarSection, Cat2>!
    private var gridDataSource: UICollectionViewDiffableDataSource<GridSection, GridItem>!
    private var isScrollingProgrammatically = false

    // MARK: - Lifecycle
    override func loadView() {
        view = categoryView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "카테고리"
        setupDataSources()
        setupSearchBarGesture()
    }

    private func setupSearchBarGesture() {
        let tapGesture = UITapGestureRecognizer()
        categoryView.searchBar.addGestureRecognizer(tapGesture)

        tapGesture.rx.event
            .bind(with: self) { owner, _ in
                owner.showAlert(
                    title: LocalizedKeys.Search.title.localized,
                    message: LocalizedKeys.Search.navigationMessage.localized
                )
            }
            .disposed(by: disposeBag)
    }

    // MARK: - DataSource Setup
    private func setupDataSources() {
        // 이미 초기화되었으면 skip
        guard sidebarDataSource == nil || gridDataSource == nil else { return }

        // Sidebar DataSource
        let sidebarCellRegistration = UICollectionView.CellRegistration<CategorySidebarCell, Cat2> {
            [weak self] cell, indexPath, cat2 in
            guard let self = self, let reactor = self.reactor else { return }
            let isHighlighted = (cat2 == reactor.currentState.highlightedCat2)
            cell.configure(cat2: cat2, isHighlighted: isHighlighted)
        }

        sidebarDataSource = UICollectionViewDiffableDataSource<SidebarSection, Cat2>(
            collectionView: categoryView.sidebarCollectionView
        ) { collectionView, indexPath, cat2 in
            return collectionView.dequeueConfiguredReusableCell(
                using: sidebarCellRegistration,
                for: indexPath,
                item: cat2
            )
        }

        // Grid DataSource
        let gridCellRegistration = UICollectionView.CellRegistration<RectangleCell, GridItem> {
            cell, indexPath, item in
            cell.configure(with: item.cat3)
        }

        let headerRegistration = UICollectionView.SupplementaryRegistration<CategorySectionHeader>(
            elementKind: UICollectionView.elementKindSectionHeader
        ) { [weak self] header, kind, indexPath in
            guard let self = self, let reactor = self.reactor else { return }

            let snapshot = self.gridDataSource.snapshot()
            let section = snapshot.sectionIdentifiers[indexPath.section]

            if case .category(let cat2) = section {
                let state = reactor.currentState
                header.configure(
                    cat2: cat2,
                    isExpanded: state.isExpanded(cat2: cat2),
                    showMoreButton: state.shouldShowExpandButton(for: cat2)
                )

                header.onMoreButtonTapped = { [weak self] in
                    self?.reactor?.action.onNext(.toggleExpandSection(cat2))
                }
            }
        }

        gridDataSource = UICollectionViewDiffableDataSource<GridSection, GridItem>(
            collectionView: categoryView.gridCollectionView
        ) { collectionView, indexPath, item in
            return collectionView.dequeueConfiguredReusableCell(
                using: gridCellRegistration,
                for: indexPath,
                item: item
            )
        }

        gridDataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
            return collectionView.dequeueConfiguredReusableSupplementary(
                using: headerRegistration,
                for: indexPath
            )
        }

        // Sidebar Selection
        categoryView.sidebarCollectionView.rx.itemSelected
            .compactMap { [weak self] indexPath -> Cat2? in
                return self?.sidebarDataSource.itemIdentifier(for: indexPath)
            }
            .bind(with: self) { owner, cat2 in
                owner.reactor?.action.onNext(.selectCat2(cat2))
            }
            .disposed(by: disposeBag)

        // Grid Selection - Navigate to PlaceList
        categoryView.gridCollectionView.rx.itemSelected
            .compactMap { [weak self] indexPath -> (Cat2, Cat3)? in
                guard let self = self,
                      let item = self.gridDataSource.itemIdentifier(for: indexPath) else {
                    return nil
                }

                // 현재 섹션의 Cat2 가져오기
                let snapshot = self.gridDataSource.snapshot()
                let section = snapshot.sectionIdentifiers[indexPath.section]

                if case .category(let cat2) = section {
                    return (cat2, item.cat3)
                }
                return nil
            }
            .bind(with: self) { owner, data in
                let (cat2, cat3) = data
                owner.navigateToPlaceList(cat2: cat2, cat3: cat3)
            }
            .disposed(by: disposeBag)
    }

    // MARK: - Bind Reactor
    func bind(reactor: CategoryReactor) {
        // DataSource 초기화 보장
        if sidebarDataSource == nil || gridDataSource == nil {
            setupDataSources()
        }

        // Action
        Observable.just(())
            .map { Reactor.Action.viewDidLoad }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        // State - Sidebar
        reactor.state.map { $0.sidebarItems }
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: [])
            .drive(with: self) { owner, items in
                owner.applySidebarSnapshot(items: items)
            }
            .disposed(by: disposeBag)

        // State - Grid (Categories)
        reactor.state
            .map { $0.categories.count }
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: 0)
            .drive(with: self) { owner, _ in
                guard let reactor = owner.reactor else { return }
                owner.applyGridSnapshot(state: reactor.currentState)
            }
            .disposed(by: disposeBag)

        // State - Grid (Expanded Sections)
        reactor.state
            .map { $0.expandedSections }
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: [])
            .drive(with: self) { owner, _ in
                guard let reactor = owner.reactor else { return }
                owner.applyGridSnapshot(state: reactor.currentState)
            }
            .disposed(by: disposeBag)

        // State - Highlighted Sidebar (스크롤로 인한 변경)
        reactor.state.map { $0.highlightedCat2 }
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: .A0101)
            .drive(with: self) { owner, _ in
                owner.updateSidebarHighlight()
            }
            .disposed(by: disposeBag)

        // State - Scroll To Section
        reactor.state.compactMap { $0.scrollToCat2 }
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: .A0101)
            .drive(with: self) { owner, cat2 in
                owner.scrollToSection(cat2: cat2)
            }
            .disposed(by: disposeBag)

        // Grid Scroll Monitoring
        categoryView.gridCollectionView.rx.contentOffset
            .throttle(.milliseconds(100), scheduler: MainScheduler.instance)
            .asDriver(onErrorJustReturn: .zero)
            .drive(with: self) { owner, _ in
                owner.updateSidebarBasedOnScroll()
            }
            .disposed(by: disposeBag)
    }

    // MARK: - Snapshot Apply
    private func applySidebarSnapshot(items: [Cat2]) {
        guard sidebarDataSource != nil else {
            print("⚠️ sidebarDataSource is nil")
            return
        }
        var snapshot = NSDiffableDataSourceSnapshot<SidebarSection, Cat2>()
        snapshot.appendSections([.main])
        snapshot.appendItems(items, toSection: .main)
        sidebarDataSource.apply(snapshot, animatingDifferences: false)
    }

    private func applyGridSnapshot(state: CategoryReactor.State) {
        guard gridDataSource != nil else {
            print("⚠️ gridDataSource is nil")
            return
        }
        var snapshot = NSDiffableDataSourceSnapshot<GridSection, GridItem>()
        var seenSections = Set<Cat2>()

        state.categories.forEach { categoryDetail in
            // 중복 섹션 건너뛰기
            guard !seenSections.contains(categoryDetail.cat2) else { return }
            seenSections.insert(categoryDetail.cat2)

            let section = GridSection.category(categoryDetail.cat2)
            snapshot.appendSections([section])

            let visibleItems = state.visibleCat3Items(for: categoryDetail.cat2)
            let gridItems = visibleItems.map { GridItem(cat3: $0) }
            snapshot.appendItems(gridItems, toSection: section)
        }

        gridDataSource.apply(snapshot, animatingDifferences: true)
    }

    private func updateSidebarHighlight() {
        guard let reactor = reactor, sidebarDataSource != nil else { return }
        let highlightedCat2 = reactor.currentState.highlightedCat2

        sidebarDataSource.snapshot().itemIdentifiers.enumerated().forEach { index, cat2 in
            let indexPath = IndexPath(item: index, section: 0)
            if let cell = categoryView.sidebarCollectionView.cellForItem(at: indexPath) as? CategorySidebarCell {
                cell.configure(cat2: cat2, isHighlighted: cat2 == highlightedCat2)
            }
        }
    }

    // MARK: - Scroll Coordination
    private func scrollToSection(cat2: Cat2) {
        guard gridDataSource != nil else { return }
        guard let sectionIndex = gridDataSource.snapshot().sectionIdentifiers.firstIndex(where: {
            if case .category(let sectionCat2) = $0 {
                return sectionCat2 == cat2
            }
            return false
        }) else { return }

        isScrollingProgrammatically = true

        let indexPath = IndexPath(item: 0, section: sectionIndex)
        categoryView.gridCollectionView.scrollToItem(at: indexPath, at: .top, animated: true)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.isScrollingProgrammatically = false
        }
    }

    private func updateSidebarBasedOnScroll() {
        guard !isScrollingProgrammatically, let reactor = reactor, gridDataSource != nil else { return }

        // 현재 화면에 보이는 섹션 중 가장 위에 있는 섹션 찾기
        let visibleIndexPaths = categoryView.gridCollectionView.indexPathsForVisibleSupplementaryElements(ofKind: UICollectionView.elementKindSectionHeader)

        guard let topIndexPath = visibleIndexPaths.min(by: { $0.section < $1.section }) else { return }

        let snapshot = gridDataSource.snapshot()
        let section = snapshot.sectionIdentifiers[topIndexPath.section]

        if case .category(let cat2) = section, cat2 != reactor.currentState.highlightedCat2 {
            reactor.action.onNext(.scrollToCat2(cat2))
        }
    }

    // MARK: - Navigation
    private func navigateToPlaceList(cat2: Cat2, cat3: Cat3) {
        let viewController = AppContainer.shared.makePlaceListViewController(
            initialArea: nil,
            contentTypeId: 12, // 관광지
            cat1: cat2.cat1,    // Cat2에서 Cat1 추출 (예: A0101 -> A01)
            cat2: cat2.rawValue,
            cat3: cat3.rawValue
        )

        // 타이틀 설정: cat3의 displayName 사용
        viewController.title = cat3.labelKo

        navigationController?.pushViewController(viewController, animated: true)
    }
}
