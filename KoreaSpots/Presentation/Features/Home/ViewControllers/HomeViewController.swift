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

//        homeView.refreshControl.rx.controlEvent(.valueChanged)
//            .map { Reactor.Action.refresh }
//            .bind(to: reactor.action)
//            .disposed(by: disposeBag)

        // Search Button Action
        homeView.searchButton.rx.tap
            .bind(with: self) { owner, _ in
                owner.navigateToSearch()
            }
            .disposed(by: disposeBag)

        // State
//        reactor.state
//            .map(\.isLoading)
//            .distinctUntilChanged()
//            .asDriver(onErrorJustReturn: false)
//            .drive(with: self) { owner, isLoading in
//                if isLoading {
//                    // 뷰가 화면에 표시된 경우에만 beginRefreshing 호출
//                    if owner.isViewLoaded && owner.view.window != nil {
//                        owner.homeView.refreshControl.beginRefreshing()
//                    }
//                } else {
//                    owner.homeView.refreshControl.endRefreshing()
//                }
//            }
//            .disposed(by: disposeBag)

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
            .drive(with: self) { owner, error in
                owner.showErrorAlert(message: error)
            }
            .disposed(by: disposeBag)

        // Cell Selection
        homeView.collectionView.rx.itemSelected
            .bind(with: self) { owner, indexPath in
                owner.handleCellSelection(at: indexPath, reactor: reactor)
            }
            .disposed(by: disposeBag)

        // Location Updates
        reactor.observeLocationUpdates()
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        // Request location permission on viewDidLoad
        reactor.requestLocationPermission()
    }

    // MARK: - Setup
    override func setupNaviBar() {
        super.setupNaviBar()

        let label = UILabel()
        label.text = LocalizedKeys.Home.title.localized
        label.font = FontManager.largeTitle
        label.textColor = .textPrimary

        // 3) 왼쪽 바 버튼으로 넣기
        navigationItem.leftBarButtonItems = [
            UIBarButtonItem(customView: label)
        ]
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
            
        case .category(let category):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RectangleCell.reuseIdentifier, for: indexPath) as? RectangleCell else { return UICollectionViewCell() }
            cell.configure(with: category)
            return cell

        case .theme(let theme):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RoundCell.reuseIdentifier, for: indexPath) as? RoundCell else { return UICollectionViewCell() }
            cell.configure(with: theme)
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
                ///TODO: - 지도보기 화면
//            case .nearby: return LocalizedKeys.Action.openMap.localized
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

        case .category(let category):
            navigateToCategoryPlaceList(category: category)
            
        case .theme(let theme):
            navigateToThemePlaceList(theme: theme)

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
            navigateToNearbyPlaceList()
            break
        case .category:
            // TODO: Navigate to category list
            print("Navigate to category list")
            break
        case .theme:
            // TODO: Navigate to theme list
            print("Navigate to theme list")
            break
//        case .placeholder:
//            // TODO: Handle placeholder action
//            print("Handle placeholder action")
//            break
        }
    }

    // MARK: - Navigation Methods
    private func navigateToCategoryPlaceList(category: Category) {
        guard let contentTypeId = category.contentType.contentTypeId?.rawValue else { return }

        let viewController = AppContainer.shared.makePlaceListViewController(
            initialArea: nil,
            contentTypeId: contentTypeId
        )
        viewController.title = category.title
        navigationController?.pushViewController(viewController, animated: true)
    }

    private func navigateToNearbyPlaceList() {
        guard let reactor = reactor,
              let location = reactor.currentState.userLocation else {
            showLocationAlert()
            return
        }

        // Get AreaCode from location using LocationService
        reactor.locationService.getCurrentAreaCode()
            .subscribe(onSuccess: { [weak self] areaCode in
                let viewController = AppContainer.shared.makePlaceListViewController(
                    initialArea: areaCode,
                    contentTypeId: nil
                )
                viewController.title = LocalizedKeys.Home.nearby.localized
                self?.navigationController?.pushViewController(viewController, animated: true)
            }, onFailure: { [weak self] error in
                print("⚠️ Failed to get area code: \(error.localizedDescription)")
                // Fallback: Navigate with Seoul as default
                let viewController = AppContainer.shared.makePlaceListViewController(
                    initialArea: .seoul,
                    contentTypeId: nil
                )
                viewController.title = LocalizedKeys.Home.nearby.localized
                self?.navigationController?.pushViewController(viewController, animated: true)
            })
            .disposed(by: disposeBag)
    }

    private func navigateToThemePlaceList(theme: Theme) {
        guard let contentTypeId = theme.contentTypeId else {
            print("⚠️ Theme \(theme.title) has no contentTypeId")
            return
        }

        // Cat3 필터링을 위한 쿼리 문자열 생성
        let cat3Query = theme.theme12.query.cat3Filters
            .map { $0.rawValue }
            .joined(separator: ",")

        let viewController = AppContainer.shared.makePlaceListViewController(
            initialArea: nil,
            contentTypeId: contentTypeId,
            cat1: theme.cat1,
            cat2: theme.cat2,
            cat3: cat3Query
        )
        viewController.title = theme.title
        navigationController?.pushViewController(viewController, animated: true)
    }

    private func showLocationAlert() {
        showErrorAlert(
            message: "위치 정보를 가져올 수 없습니다.",
            title: LocalizedKeys.Common.error.localized
        )
    }
}
