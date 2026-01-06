//
//  TripDetailViewController.swift
//  KoreaSpots
//
//  Created by Watson22_YJ on 11/16/25.
//

import UIKit
import ReactorKit
import RxSwift
import RxCocoa

final class TripDetailViewController: BaseViewController, View {

    // MARK: - Section & Item

    enum CarouselSection: Hashable {
        case photos
    }

    enum RouteSection: Hashable {
        case visitedPlaces
    }

    // MARK: - Properties

    var disposeBag = DisposeBag()
    let tripDetailView = TripDetailView()

    private var carouselDataSource: UICollectionViewDiffableDataSource<CarouselSection, TripPhoto>!
    private var routeDataSource: UICollectionViewDiffableDataSource<RouteSection, VisitedPlace>!

    private let editButton = UIBarButtonItem(
        title: "편집",
        style: .plain,
        target: nil,
        action: nil
    )

    // MARK: - Lifecycle

    override func loadView() {
        view = tripDetailView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupDataSources()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Reload trip data when returning from editor
        reactor?.action.onNext(.reloadTrip)
    }

    // MARK: - Bind

    func bind(reactor: TripDetailReactor) {
        // Ensure DataSource is initialized
        if carouselDataSource == nil || routeDataSource == nil {
            setupDataSources()
        }

        // Action: viewDidLoad
        Observable.just(())
            .map { TripDetailReactor.Action.viewDidLoad }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        // Action: Edit button
        editButton.rx.tap
            .bind(with: self) { owner, _ in
                owner.navigateToTripEditor(trip: reactor.currentState.trip)
            }
            .disposed(by: disposeBag)

        // State: Trip
        reactor.state
            .map { $0.trip }
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: reactor.currentState.trip)
            .drive(with: self) { owner, trip in
                owner.title = trip.title
                owner.tripDetailView.configure(with: trip)
                owner.applyRouteSnapshot(visitedPlaces: trip.visitedPlaces.sorted { $0.order < $1.order })
            }
            .disposed(by: disposeBag)

        // State: All photos (for carousel)
        reactor.state
            .map { $0.allPhotos }
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: [])
            .drive(with: self) { owner, photos in
                owner.tripDetailView.configurePhotos(with: photos)
                owner.applyCarouselSnapshot(photos: photos)
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

        // Route: Cell selection
        tripDetailView.routeContainerView.collectionView.rx.itemSelected
            .do(onNext: { [weak self] indexPath in
                self?.tripDetailView.routeContainerView.collectionView.deselectItem(at: indexPath, animated: true)
            })
            .compactMap { [weak self] indexPath -> VisitedPlace? in
                return self?.routeDataSource.itemIdentifier(for: indexPath)
            }
            .bind(with: self) { owner, place in
                owner.showPlaceActionSheet(for: place)
            }
            .disposed(by: disposeBag)

        // Carousel: Cell selection (full screen photo viewer)
        tripDetailView.photoCarouselCollectionView.rx.itemSelected
            .compactMap { [weak self] indexPath -> (TripPhoto, Int)? in
                guard let photo = self?.carouselDataSource.itemIdentifier(for: indexPath) else { return nil }
                return (photo, indexPath.item)
            }
            .bind(with: self) { owner, item in
                owner.showPhotoViewer(photo: item.0, index: item.1, allPhotos: reactor.currentState.allPhotos)
            }
            .disposed(by: disposeBag)
    }

    // MARK: - Setup

    override func setupNaviBar() {
        super.setupNaviBar()
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.rightBarButtonItem = editButton
    }

    private func setupDataSources() {
        guard carouselDataSource == nil else { return }

        // Carousel DataSource
        let carouselCellRegistration = UICollectionView.CellRegistration<PhotoCarouselCell, TripPhoto> { cell, indexPath, photo in
            cell.configure(with: photo)
        }

        carouselDataSource = UICollectionViewDiffableDataSource<CarouselSection, TripPhoto>(
            collectionView: tripDetailView.photoCarouselCollectionView
        ) { collectionView, indexPath, photo in
            return collectionView.dequeueConfiguredReusableCell(
                using: carouselCellRegistration,
                for: indexPath,
                item: photo
            )
        }

        // Route DataSource
        let timelineCellRegistration = UICollectionView.CellRegistration<VisitedPlaceTimelineCell, VisitedPlace> { [weak self] cell, indexPath, place in
            guard let self = self else { return }
            let totalCount = self.reactor?.currentState.trip.visitedPlaces.count ?? 0
            let isLast = indexPath.item == totalCount - 1
            cell.configure(with: place, order: place.order + 1, isLast: isLast)
        }

        routeDataSource = UICollectionViewDiffableDataSource<RouteSection, VisitedPlace>(
            collectionView: tripDetailView.routeContainerView.collectionView
        ) { collectionView, indexPath, place in
            return collectionView.dequeueConfiguredReusableCell(
                using: timelineCellRegistration,
                for: indexPath,
                item: place
            )
        }
    }

    // MARK: - Snapshot

    private func applyCarouselSnapshot(photos: [TripPhoto]) {
        var snapshot = NSDiffableDataSourceSnapshot<CarouselSection, TripPhoto>()
        snapshot.appendSections([.photos])
        snapshot.appendItems(photos, toSection: .photos)
        carouselDataSource.apply(snapshot, animatingDifferences: false)
    }

    private func applyRouteSnapshot(visitedPlaces: [VisitedPlace]) {
        var snapshot = NSDiffableDataSourceSnapshot<RouteSection, VisitedPlace>()
        snapshot.appendSections([.visitedPlaces])
        snapshot.appendItems(visitedPlaces, toSection: .visitedPlaces)
        routeDataSource.apply(snapshot, animatingDifferences: true)

        // Update collection view height after applying snapshot
        tripDetailView.routeContainerView.updateCollectionViewHeight(for: visitedPlaces.count)
    }

    // MARK: - Navigation

    private func navigateToTripEditor(trip: Trip) {
        let viewController = AppContainer.shared.makeTripEditorViewController(trip: trip)
        navigationController?.pushViewController(viewController, animated: true)
    }

    // MARK: - Actions

    private func showPlaceActionSheet(for place: VisitedPlace) {
        let alert = UIAlertController(title: place.placeNameSnapshot, message: nil, preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title: "취소", style: .cancel))

        present(alert, animated: true)
    }

    private func showPhotoViewer(photo: TripPhoto, index: Int, allPhotos: [TripPhoto]) {
        // TODO: Implement full-screen photo viewer
        print("Show photo viewer for: \(photo.photoId)")
    }
}

// MARK: - PhotoCarouselCell

final class PhotoCarouselCell: UICollectionViewCell {

    private let imageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
        $0.backgroundColor = .systemGray5
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        contentView.addSubview(imageView)
        imageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    func configure(with photo: TripPhoto) {
        // Load from local path
        if !photo.localPath.isEmpty,
           FileManager.default.fileExists(atPath: photo.localPath),
           let image = UIImage(contentsOfFile: photo.localPath) {
            imageView.image = image
        } else {
            imageView.image = UIImage(systemName: "photo")
            imageView.tintColor = .tertiaryLabel
            imageView.contentMode = .scaleAspectFit
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        imageView.contentMode = .scaleAspectFill
    }
}
