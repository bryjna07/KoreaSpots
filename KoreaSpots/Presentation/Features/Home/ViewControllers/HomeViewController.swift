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

        // Search Button Action
        homeView.searchButton.rx.tap
            .bind(with: self) { owner, _ in
                owner.navigateToSearch()
            }
            .disposed(by: disposeBag)

        // State - 섹션 데이터 바인딩 (각 셀이 더미 데이터인지 확인하여 스켈레톤 제어)
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

        // Location Updates (권한 허용 시)
        reactor.observeLocationUpdates()
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        // Authorization Status (권한 거부 감지)
        reactor.observeAuthorizationStatus()
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
                guard let self = self, let reactor = self.reactor else { return UICollectionReusableView() }

                switch kind {
                case FestivalPageIndicatorView.elementKind:
                    let view = collectionView.dequeueReusableSupplementaryView(
                        ofKind: kind,
                        withReuseIdentifier: FestivalPageIndicatorView.reuseIdentifier,
                        for: indexPath
                    ) as! FestivalPageIndicatorView

                    let totalPages = dataSource[indexPath.section].items.count
                    let currentPage = self.homeView.currentPage
                    view.configure(currentPage: currentPage + 1, totalPages: totalPages)
                    return view

                case UICollectionView.elementKindSectionHeader:
                    return self.configureSupplementaryView(collectionView: collectionView, kind: kind, indexPath: indexPath, section: dataSource[indexPath.section])

                default:
                    return UICollectionReusableView()
                }
            }
        )
    }

    // MARK: - Data Source Configuration
    private func configureCell(collectionView: UICollectionView, indexPath: IndexPath, item: HomeSectionItem) -> UICollectionViewCell {
        switch item {
        case .festival(let festival):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FestivalCardCell.reuseIdentifier, for: indexPath) as? FestivalCardCell else {  return UICollectionViewCell() }
            cell.configure(with: festival)
            collectionView.configureSkeletonIfNeeded(for: cell, with: festival)
            return cell

        case .place(let place):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PlaceCardCell.reuseIdentifier, for: indexPath) as? PlaceCardCell else { return UICollectionViewCell() }
            cell.configure(with: place)
            collectionView.configureSkeletonIfNeeded(for: cell, with: place)
            return cell

        case .category(let category):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RectangleCell.reuseIdentifier, for: indexPath) as? RectangleCell else { return UICollectionViewCell() }
            cell.configure(with: category)
            return cell

        case .theme(let theme):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RoundCell.reuseIdentifier, for: indexPath) as? RoundCell else { return UICollectionViewCell() }
            cell.configure(with: theme)
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
            navigateToFestivalDetail(place: festival)

        case .place(let place):
            navigateToPlaceDetail(place: place)

        case .category(let category):
            navigateToCategoryPlaceList(category: category)

        case .theme(let theme):
            navigateToThemePlaceList(theme: theme)
        }
    }

    private func handleHeaderAction(for section: HomeSectionModel) {
        switch section.section {
        case .festival:
            // TODO: Navigate to festival list
            print("Navigate to festival list")
        case .nearby:
            navigateToNearbyPlaceList()
        case .category:
            // TODO: Navigate to category list
            print("Navigate to category list")
        case .theme:
            // TODO: Navigate to theme list
            print("Navigate to theme list")
        }
    }

    // MARK: - Navigation Methods
    private func navigateToCategoryPlaceList(category: Category) {
        guard let contentTypeId = category.contentType.contentTypeId?.rawValue else { return }

        // Cat2 파라미터 추출 (축제는 A0207, 공연/행사는 A0208)
        let cat2 = category.contentType.cat2?.rawValue

        let viewController = AppContainer.shared.makePlaceListViewController(
            initialArea: nil,
            contentTypeId: contentTypeId,
            cat1: nil,
            cat2: cat2,
            cat3: nil
        )
        viewController.title = category.title
        navigationController?.pushViewController(viewController, animated: true)
    }

    private func navigateToNearbyPlaceList() {
        guard let reactor = reactor else { return }

        let areaCode = reactor.currentState.currentAreaCode
        let viewController = AppContainer.shared.makePlaceListViewController(
            initialArea: areaCode,
            contentTypeId: nil
        )
        viewController.title = LocalizedKeys.Home.nearby.localized
        navigationController?.pushViewController(viewController, animated: true)
    }

    private func navigateToThemePlaceList(theme: Theme) {
        guard let contentTypeId = theme.contentTypeId else {
            print("⚠️ Theme \(theme.title) has no contentTypeId")
            return
        }

        // Cat3 필터링을 위한 쿼리 문자열 생성
        let cat3Query = theme.theme12.query.cat3Filters
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
}
