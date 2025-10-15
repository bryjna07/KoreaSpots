//
//  FavoriteViewController.swift
//  KoreaSpots
//
//  Created by YoungJin on 10/11/25.
//

import UIKit
import ReactorKit
import RxSwift
import RxCocoa

final class FavoriteViewController: BaseViewController, View, ScreenNavigatable {

    // MARK: - Properties

    var disposeBag = DisposeBag()
    private let favoriteView = FavoriteView()
    private var dataSource: UICollectionViewDiffableDataSource<Section, PlaceItem>!

    enum Section: Hashable {
        case main
    }

    struct PlaceItem: Hashable {
        let id: String
        let place: Place
        let isFavorite: Bool

        init(place: Place, isFavorite: Bool = true) {
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

    // MARK: - Lifecycle

    override func loadView() {
        view = favoriteView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupDataSource()
        setupCollectionView()
    }

    // MARK: - Bind

    func bind(reactor: FavoriteReactor) {
        // DataSource 초기화 보장
        if dataSource == nil {
            setupDataSource()
        }

        // Action: viewDidLoad
        Observable.just(())
            .map { FavoriteReactor.Action.viewDidLoad }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        // State: Favorites
        reactor.state
            .map { $0.favorites }
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: [])
            .drive(with: self) { owner, places in
                owner.applySnapshot(places: places)
            }
            .disposed(by: disposeBag)

        // State: Favorite count
        reactor.state
            .map { $0.favoriteCount }
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: 0)
            .drive(with: self) { owner, count in
                owner.favoriteView.updateFavoriteCount(count)

                if count == 0 {
                    owner.favoriteView.showEmptyState()
                } else {
                    owner.favoriteView.showFavorites()
                }
            }
            .disposed(by: disposeBag)

        // State: Error
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
    }

    // MARK: - Setup

    override func setupNaviBar() {
        super.setupNaviBar()
        navigationItem.title = "즐겨찾기"
    }

    private func setupDataSource() {
        // 이미 초기화되었으면 skip
        guard dataSource == nil else { return }

        let cellRegistration = UICollectionView.CellRegistration<PlaceListCell, PlaceItem> { [weak self] cell, indexPath, item in
            guard let self = self else { return }

            cell.configure(with: item.place, showTag: false, isFavorite: item.isFavorite)

            // Favorite button tap with alert for removal
            cell.favoriteButton.rx.tap
                .bind(with: self) { owner, _ in
                    owner.showDeleteConfirmAlert(
                        title: "즐겨찾기 삭제",
                        message: "즐겨찾기에서 삭제하시겠습니까?"
                    ) {
                        owner.reactor?.action.onNext(.toggleFavorite(item.place, item.isFavorite))
                    }
                }
                .disposed(by: cell.disposeBag)
        }

        dataSource = UICollectionViewDiffableDataSource<Section, PlaceItem>(
            collectionView: favoriteView.collectionView
        ) { collectionView, indexPath, item in
            return collectionView.dequeueConfiguredReusableCell(
                using: cellRegistration,
                for: indexPath,
                item: item
            )
        }
    }

    private func setupCollectionView() {
        // Cell selection
        favoriteView.collectionView.rx.itemSelected
            .compactMap { [weak self] indexPath -> Place? in
                return self?.dataSource.itemIdentifier(for: indexPath)?.place
            }
            .bind(with: self) { owner, place in
                owner.navigateToPlaceDetail(place: place)
            }
            .disposed(by: disposeBag)

        // Compositional Layout을 사용하므로 별도 delegate 설정 불필요
    }

    // MARK: - Snapshot

    private func applySnapshot(places: [Place]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, PlaceItem>()
        snapshot.appendSections([.main])

        let items = places.map { PlaceItem(place: $0, isFavorite: true) }
        snapshot.appendItems(items, toSection: .main)

        dataSource.apply(snapshot, animatingDifferences: true)
    }

    // MARK: - Navigation

    func navigateToPlaceDetail(place: Place) {
        let viewController = AppContainer.shared.makePlaceDetailViewController(place: place)
        navigationController?.pushViewController(viewController, animated: true)
    }
}
