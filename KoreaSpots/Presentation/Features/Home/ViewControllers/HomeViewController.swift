//
//  HomeViewController.swift
//  KoreaSpots
//
//  Created by YoungJin on 9/25/25.
//

import UIKit
import ReactorKit
import RxSwift
import RxCocoa
import RxDataSources
import SkeletonView

final class HomeViewController: BaseViewController, View, ScreenNavigatable {

    // MARK: - Properties
    var disposeBag = DisposeBag()
    private var homeView: HomeView { return view as! HomeView }
    private var dataSource: RxCollectionViewSectionedAnimatedDataSource<HomeSectionModel>!

    // MARK: - Lifecycle
    override func loadView() {
        view = HomeView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupDataSource()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        homeView.resumeAutoScroll()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        homeView.pauseAutoScroll()
    }

    // MARK: - Bind
    func bind(reactor: HomeReactor) {
        // Action
        Observable.just(())
            .map { Reactor.Action.viewDidLoad }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        homeView.refreshControl.rx.controlEvent(.valueChanged)
            .map { Reactor.Action.refresh }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        // Search Button Action
        homeView.searchButton.rx.tap
            .subscribe(with: self, onNext: { owner, _ in
                owner.navigateToSearch()
            })
            .disposed(by: disposeBag)

        // State
        reactor.state
            .map(\.isLoading)
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: false)
            .drive(with: self, onNext: { owner, isLoading in
                if isLoading {
                    // 뷰가 화면에 표시된 경우에만 beginRefreshing 호출
                    if owner.isViewLoaded && owner.view.window != nil {
                        owner.homeView.refreshControl.beginRefreshing()
                    }
                } else {
                    owner.homeView.refreshControl.endRefreshing()
                }
            })
            .disposed(by: disposeBag)

        reactor.state
            .map(\.sections)
            .asDriver(onErrorJustReturn: [])
            .do(onNext: { [weak self] sections in
                // 축제 섹션의 아이템 수를 확인하여 자동 페이징 설정
                if let festivalSection = sections.first(where: { $0.section == .festival }) {
                    self?.homeView.updateFestivalPageCount(festivalSection.items.count)
                }
            })
            .drive(homeView.collectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)

        // Error Handling
        reactor.state
            .compactMap(\.error)
            .asDriver(onErrorJustReturn: "Unknown error occurred")
            .drive(with: self, onNext: { owner, error in
                owner.showErrorAlert(message: error)
            })
            .disposed(by: disposeBag)

        // Cell Selection
        homeView.collectionView.rx.itemSelected
            .subscribe(with: self, onNext: { owner, indexPath in
                owner.handleCellSelection(at: indexPath, reactor: reactor)
            })
            .disposed(by: disposeBag)

        // Location Updates
        reactor.observeLocationUpdates()
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        // Request location permission on viewDidLoad
        reactor.requestLocationPermission()
    }

    // MARK: - Setup
    private func setupUI() {
        title = LocalizedKeys.Home.title.localized
        navigationController?.navigationBar.prefersLargeTitles = true
    }

    private func setupDataSource() {
        let animation = AnimationConfiguration(insertAnimation: .fade, reloadAnimation: .fade, deleteAnimation: .fade)
        dataSource = RxCollectionViewSectionedAnimatedDataSource<HomeSectionModel>(
            animationConfiguration: animation,
            configureCell: { [weak self] dataSource, collectionView, indexPath, item in
                return self?.configureCell(collectionView: collectionView, indexPath: indexPath, item: item) ?? UICollectionViewCell()
            },
            configureSupplementaryView: { [weak self] dataSource, collectionView, kind, indexPath in
                switch kind {
                case FestivalPageIndicatorView.elementKind:
                    let view = collectionView.dequeueReusableSupplementaryView(
                        ofKind: kind,
                        withReuseIdentifier: FestivalPageIndicatorView.reuseIdentifier,
                        for: indexPath
                    ) as! FestivalPageIndicatorView

                    let totalPages = dataSource[indexPath.section].items.count
                    let currentPage = self?.homeView.currentPage ?? 0
                    view.configure(currentPage: currentPage + 1, totalPages: totalPages)
                    return view

                case UICollectionView.elementKindSectionHeader:
                    return self?.configureSupplementaryView(collectionView: collectionView, kind: kind, indexPath: indexPath, section: dataSource[indexPath.section]) ?? UICollectionReusableView()

                default:
                    return UICollectionReusableView()
                }
            }
        )

        // Setup skeleton compatibility
        homeView.setupSkeletonCompatibility()
    }

    // MARK: - Data Source Configuration
    private func configureCell(collectionView: UICollectionView, indexPath: IndexPath, item: HomeSectionItem) -> UICollectionViewCell {
        switch item {
        case .festival(let festival):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FestivalCardCell.reuseIdentifier, for: indexPath) as? FestivalCardCell else {  return UICollectionViewCell() }
            cell.configure(with: festival)
            return cell

        case .place(let place):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PlaceCardCell.reuseIdentifier, for: indexPath) as? PlaceCardCell else { return UICollectionViewCell() }
            cell.configure(with: place)
            return cell

        case .theme(let theme):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ThemeCardCell.reuseIdentifier, for: indexPath) as? ThemeCardCell else { return UICollectionViewCell() }
            cell.configure(with: theme)
            return cell

        case .areaCode(let areaCode):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AreaQuickLinkCell.reuseIdentifier, for: indexPath) as? AreaQuickLinkCell else { return UICollectionViewCell() }
            cell.configure(with: areaCode)
            return cell

        case .placeholder(let text, _):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PlaceholderCardCell.reuseIdentifier, for: indexPath) as? PlaceholderCardCell else { return UICollectionViewCell() }
            cell.configure(with: text)
            return cell
        }
    }

    private func configureSupplementaryView(collectionView: UICollectionView, kind: String, indexPath: IndexPath, section: HomeSectionModel) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader else {
            return UICollectionReusableView()
        }

        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: SectionHeaderView.reuseIdentifier, for: indexPath) as! SectionHeaderView

        let actionTitle: String? = {
            switch section.section {
            case .nearby: return LocalizedKeys.Action.openMap.localized
            default: return nil
            }
        }()

        headerView.configure(title: section.section.headerTitle, actionTitle: actionTitle)

        // Header action handling
        headerView.actionHandler = { [weak self] in
            self?.handleHeaderAction(for: section)
        }

        return headerView
    }

    // MARK: - Event Handling
    private func handleCellSelection(at indexPath: IndexPath, reactor: HomeReactor) {
        guard indexPath.section < reactor.currentState.sections.count,
              indexPath.item < reactor.currentState.sections[indexPath.section].items.count else { return }

        let item = reactor.currentState.sections[indexPath.section].items[indexPath.item]

        switch item {
        case .festival(let festival):
            navigateToFestivalDetail(festival: festival)

        case .place(let place):
            navigateToPlaceDetail(place: place)

        case .theme(let theme):
            // TODO: Navigate to theme category
            print("Theme selected: \(theme.title)")

        case .areaCode(let areaCode):
            // TODO: Navigate to area-based places
            print("Area selected: \(areaCode.displayName)")

        case .placeholder(_, _):
            // TODO: Handle placeholder action
            print("Placeholder tapped")
        }
    }

    private func handleHeaderAction(for section: HomeSectionModel) {
        switch section.section {
        case .festival:
            // TODO: Navigate to festival list
            print("Navigate to festival list")
            break
        case .nearby:
            navigateToMap()
            break
        case .theme:
            // TODO: Navigate to theme list
            print("Navigate to theme list")
            break
        case .areaQuickLink:
            // TODO: areaQuickLink to theme list
            print("areaQuickLink to theme list")
            break
        case .placeholder:
            // TODO: Handle placeholder action
            print("Handle placeholder action")
            break
        }
    }
}
