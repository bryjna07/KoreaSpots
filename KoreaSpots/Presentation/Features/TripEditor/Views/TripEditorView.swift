//
//  TripEditorView.swift
//  KoreaSpots
//
//  Created by YoungJin on 10/10/25.
//

import UIKit
import SnapKit
import Then
import MapKit

final class TripEditorView: BaseView {

    // MARK: - Section

    enum Section: Hashable {
        case photos
        case places
    }

    enum Item: Hashable {
        case photo(TripPhoto)
        case addPhoto
        case place(VisitedPlace)
    }

    // MARK: - Properties

    private var placesDataSource: UICollectionViewDiffableDataSource<Section, VisitedPlace>!
    private var photosDataSource: UICollectionViewDiffableDataSource<Int, Item>!

    // Callbacks
    var onAddPlacesTapped: (() -> Void)?
    var onPlaceSelected: ((IndexPath) -> Void)?
    var onAddPhotosTapped: (() -> Void)?
    var onPhotoDeleteTapped: ((TripPhoto) -> Void)?
    var onPlacesReordered: (([VisitedPlace]) -> Void)?

    // Data
    private var places: [VisitedPlace] = []
    private var photos: [TripPhoto] = []

    // MARK: - UI Components

    private let scrollView = UIScrollView()
    private let contentView = UIView()

    // Photos section
    private let photosSectionHeader = UIView()
    private let photosLabel = UILabel()
    private let photosCountLabel = UILabel()

    lazy var photosCollectionView: UICollectionView = {
        let layout = createPhotosLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.showsHorizontalScrollIndicator = false
        return cv
    }()

    let formView = TripFormView()

    private let placesHeaderView = UIView()
    private let placesLabel = UILabel()
    private let addPlacesButton = UIButton(type: .system)

    lazy var placesCollectionView: UICollectionView = {
        let layout = createPlacesLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.delegate = self
        cv.isScrollEnabled = false
        return cv
    }()

    // Route map preview
    private let routeMapContainerView = UIView()
    private let routeMapHeaderLabel = UILabel()
    let routeMapView = MKMapView()
    private let routeEmptyLabel = UILabel()

    let saveButton = UIButton(type: .system)

    // MARK: - ConfigureUI

    override func configureHierarchy() {
        addSubview(scrollView)
        scrollView.addSubview(contentView)

        contentView.addSubviews(
            formView,
            placesHeaderView,
            placesCollectionView,
            routeMapContainerView,
            photosSectionHeader,
            photosCollectionView,
            saveButton
        )

        photosSectionHeader.addSubviews(photosLabel, photosCountLabel)
        placesHeaderView.addSubviews(placesLabel, addPlacesButton)
        routeMapContainerView.addSubviews(routeMapHeaderLabel, routeMapView, routeEmptyLabel)
    }

    override func configureLayout() {
        scrollView.snp.makeConstraints {
            $0.edges.equalTo(safeAreaLayoutGuide)
        }

        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
        }

        // Form view (상단)
        formView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.leading.trailing.equalToSuperview()
        }

        // Places header
        placesHeaderView.snp.makeConstraints {
            $0.top.equalTo(formView.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(44)
        }

        placesLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.centerY.equalToSuperview()
        }

        addPlacesButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-16)
            $0.centerY.equalToSuperview()
            $0.height.equalTo(32)
        }

        // Places collection view
        placesCollectionView.snp.makeConstraints {
            $0.top.equalTo(placesHeaderView.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(0)
        }

        // Route map container
        routeMapContainerView.snp.makeConstraints {
            $0.top.equalTo(placesCollectionView.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(0)
        }

        routeMapHeaderLabel.snp.makeConstraints {
            $0.top.leading.equalToSuperview()
        }

        routeMapView.snp.makeConstraints {
            $0.top.equalTo(routeMapHeaderLabel.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview().priority(.high)
        }

        routeEmptyLabel.snp.makeConstraints {
            $0.center.equalTo(routeMapView)
        }

        // Photos section header (경로미리보기 아래)
        photosSectionHeader.snp.makeConstraints {
            $0.top.equalTo(routeMapContainerView.snp.bottom).offset(16)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(44)
        }

        photosLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.centerY.equalToSuperview()
        }

        photosCountLabel.snp.makeConstraints {
            $0.leading.equalTo(photosLabel.snp.trailing).offset(8)
            $0.centerY.equalToSuperview()
        }

        // Photos collection view
        photosCollectionView.snp.makeConstraints {
            $0.top.equalTo(photosSectionHeader.snp.bottom)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(120)
        }

        // Save button (최하단)
        saveButton.snp.makeConstraints {
            $0.top.equalTo(photosCollectionView.snp.bottom).offset(24)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.bottom.equalToSuperview().offset(-16)
            $0.height.equalTo(50)
        }
    }

    override func configureView() {
        super.configureView()

        // Photos section
        photosLabel.do {
            $0.text = "사진"
            $0.font = .systemFont(ofSize: 18, weight: .bold)
            $0.textColor = .label
        }

        photosCountLabel.do {
            $0.text = "0장"
            $0.font = FontManager.caption1
            $0.textColor = .secondaryLabel
        }

        placesLabel.do {
            $0.text = "방문 장소"
            $0.font = .systemFont(ofSize: 18, weight: .bold)
            $0.textColor = .label
        }

        addPlacesButton.do {
            $0.setTitle("+ 추가", for: .normal)
            $0.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        }

        // Route map
        routeMapHeaderLabel.do {
            $0.text = "경로 미리보기"
            $0.font = .systemFont(ofSize: 16, weight: .semibold)
            $0.textColor = .label
        }

        routeMapView.do {
            $0.layer.cornerRadius = 8
            $0.clipsToBounds = true
            $0.isUserInteractionEnabled = false
            $0.showsUserLocation = false
        }

        routeEmptyLabel.do {
            $0.text = "방문 장소를 추가하면\n경로가 표시됩니다"
            $0.font = FontManager.caption1
            $0.textColor = .tertiaryLabel
            $0.textAlignment = .center
            $0.numberOfLines = 2
            $0.isHidden = true
        }

        saveButton.do {
            $0.setTitle("저장", for: .normal)
            $0.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
            $0.backgroundColor = .bluePastel
            $0.setTitleColor(.white, for: .normal)
            $0.layer.cornerRadius = 12
        }

        configurePhotosDataSource()
        configurePlacesDataSource()
        setupBindings()
        setupDragAndDrop()
    }

    // MARK: - Private Methods

    private func setupBindings() {
        addPlacesButton.addTarget(self, action: #selector(addPlacesButtonTapped), for: .touchUpInside)
    }

    private func setupDragAndDrop() {
        placesCollectionView.dragDelegate = self
        placesCollectionView.dropDelegate = self
        placesCollectionView.dragInteractionEnabled = true
    }

    @objc private func addPlacesButtonTapped() {
        onAddPlacesTapped?()
    }

    // MARK: - Photos Layout

    private func createPhotosLayout() -> UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .absolute(100),
            heightDimension: .absolute(100)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .absolute(100),
            heightDimension: .absolute(100)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        section.interGroupSpacing = 8
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)

        return UICollectionViewCompositionalLayout(section: section)
    }

    // MARK: - Places Layout

    private func createPlacesLayout() -> UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(80)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(80)
        )
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)
        section.interGroupSpacing = 8

        return UICollectionViewCompositionalLayout(section: section)
    }

    // MARK: - Photos DataSource

    private func configurePhotosDataSource() {
        let photoCellRegistration = UICollectionView.CellRegistration<EditorPhotoCell, Item> { [weak self] cell, indexPath, item in
            switch item {
            case .photo(let photo):
                cell.configure(with: photo)
                cell.onDeleteTapped = { [weak self] in
                    self?.onPhotoDeleteTapped?(photo)
                }
            case .addPhoto:
                cell.configureAsAddButton()
                cell.onAddTapped = { [weak self] in
                    self?.onAddPhotosTapped?()
                }
            default:
                break
            }
        }

        photosDataSource = UICollectionViewDiffableDataSource<Int, Item>(
            collectionView: photosCollectionView
        ) { collectionView, indexPath, item in
            return collectionView.dequeueConfiguredReusableCell(
                using: photoCellRegistration,
                for: indexPath,
                item: item
            )
        }

        // Initial snapshot with add button only
        var snapshot = NSDiffableDataSourceSnapshot<Int, Item>()
        snapshot.appendSections([0])
        snapshot.appendItems([.addPhoto], toSection: 0)
        photosDataSource.apply(snapshot, animatingDifferences: false)
    }

    // MARK: - Places DataSource

    private func configurePlacesDataSource() {
        let placeCellRegistration = UICollectionView.CellRegistration<TripPlaceCell, VisitedPlace> { cell, _, place in
            cell.configure(with: place)
        }

        placesDataSource = UICollectionViewDiffableDataSource<Section, VisitedPlace>(
            collectionView: placesCollectionView
        ) { collectionView, indexPath, place in
            return collectionView.dequeueConfiguredReusableCell(
                using: placeCellRegistration,
                for: indexPath,
                item: place
            )
        }
    }

    // MARK: - Public Methods

    func updateForm(title: String, startDate: Date, endDate: Date, memo: String) {
        formView.configure(title: title, startDate: startDate, endDate: endDate, memo: memo)
    }

    func updatePhotos(_ photos: [TripPhoto]) {
        self.photos = photos

        photosCountLabel.text = "\(photos.count)장"

        var snapshot = NSDiffableDataSourceSnapshot<Int, Item>()
        snapshot.appendSections([0])

        // Add photo items
        let photoItems = photos.map { Item.photo($0) }
        snapshot.appendItems(photoItems, toSection: 0)

        // Add "add photo" button at the end
        snapshot.appendItems([.addPhoto], toSection: 0)

        photosDataSource.apply(snapshot, animatingDifferences: false)
    }

    func updatePlaces(_ places: [VisitedPlace]) {
        self.places = places

        var snapshot = NSDiffableDataSourceSnapshot<Section, VisitedPlace>()
        snapshot.appendSections([.places])
        snapshot.appendItems(places, toSection: .places)
        placesDataSource.apply(snapshot, animatingDifferences: false)

        // Update collection view height based on content
        let itemHeight: CGFloat = 80
        let spacing: CGFloat = 8
        let totalHeight = CGFloat(places.count) * itemHeight + CGFloat(max(0, places.count - 1)) * spacing

        placesCollectionView.snp.updateConstraints {
            $0.height.equalTo(totalHeight)
        }

        // Update route map
        updateRouteMap(with: places)

        layoutIfNeeded()
    }

    func updateRouteMap(with places: [VisitedPlace]) {
        // Clear existing annotations and overlays
        routeMapView.removeAnnotations(routeMapView.annotations)
        routeMapView.removeOverlays(routeMapView.overlays)

        // Filter places with location
        let placesWithLocation = places.compactMap { place -> (VisitedPlace, GeoPoint)? in
            guard let location = place.location,
                  location.lat != 0 && location.lng != 0 else { return nil }
            return (place, location)
        }.sorted { $0.0.order < $1.0.order }

        if placesWithLocation.isEmpty {
            routeMapContainerView.snp.updateConstraints {
                $0.height.equalTo(0)
            }
            routeEmptyLabel.isHidden = true
            return
        }

        // Show map container
        routeMapContainerView.snp.updateConstraints {
            $0.height.equalTo(230)
        }
        routeEmptyLabel.isHidden = true

        // Add annotations
        for (index, (place, location)) in placesWithLocation.enumerated() {
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(latitude: location.lat, longitude: location.lng)
            annotation.title = "\(index + 1). \(place.placeNameSnapshot)"
            routeMapView.addAnnotation(annotation)
        }

        // Add route polyline
        if placesWithLocation.count >= 2 {
            let coordinates = placesWithLocation.map {
                CLLocationCoordinate2D(latitude: $0.1.lat, longitude: $0.1.lng)
            }
            let polyline = MKPolyline(coordinates: coordinates, count: coordinates.count)
            routeMapView.addOverlay(polyline)
        }

        // Fit map to show all annotations
        let annotations = routeMapView.annotations
        if !annotations.isEmpty {
            routeMapView.showAnnotations(annotations, animated: false)
        }
    }
}

// MARK: - UICollectionViewDelegate

extension TripEditorView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == placesCollectionView {
            onPlaceSelected?(indexPath)
        }
    }
}

// MARK: - UICollectionViewDragDelegate

extension TripEditorView: UICollectionViewDragDelegate {
    func collectionView(
        _ collectionView: UICollectionView,
        itemsForBeginning session: UIDragSession,
        at indexPath: IndexPath
    ) -> [UIDragItem] {
        guard collectionView == placesCollectionView,
              indexPath.item < places.count else { return [] }

        let place = places[indexPath.item]
        let itemProvider = NSItemProvider(object: place.entryId as NSString)
        let dragItem = UIDragItem(itemProvider: itemProvider)
        dragItem.localObject = place

        return [dragItem]
    }

    func collectionView(_ collectionView: UICollectionView, dragPreviewParametersForItemAt indexPath: IndexPath) -> UIDragPreviewParameters? {
        let parameters = UIDragPreviewParameters()
        parameters.backgroundColor = .clear
        return parameters
    }
}

// MARK: - UICollectionViewDropDelegate

extension TripEditorView: UICollectionViewDropDelegate {
    func collectionView(
        _ collectionView: UICollectionView,
        dropSessionDidUpdate session: UIDropSession,
        withDestinationIndexPath destinationIndexPath: IndexPath?
    ) -> UICollectionViewDropProposal {
        guard collectionView == placesCollectionView,
              collectionView.hasActiveDrag else {
            return UICollectionViewDropProposal(operation: .forbidden)
        }
        return UICollectionViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        performDropWith coordinator: UICollectionViewDropCoordinator
    ) {
        guard collectionView == placesCollectionView,
              let destinationIndexPath = coordinator.destinationIndexPath,
              let item = coordinator.items.first,
              let sourceIndexPath = item.sourceIndexPath,
              let place = item.dragItem.localObject as? VisitedPlace else {
            return
        }

        // Perform the reorder
        places.remove(at: sourceIndexPath.item)
        places.insert(place, at: destinationIndexPath.item)

        // Update order property
        let reorderedPlaces = places.enumerated().map { index, place in
            VisitedPlace(
                entryId: place.entryId,
                placeId: place.placeId,
                placeNameSnapshot: place.placeNameSnapshot,
                thumbnailURLSnapshot: place.thumbnailURLSnapshot,
                areaCode: place.areaCode,
                sigunguCode: place.sigunguCode,
                addedAt: place.addedAt,
                order: index,
                note: place.note,
                rating: place.rating,
                location: place.location,
                visitedTime: place.visitedTime,
                stayDuration: place.stayDuration,
                routeIndex: place.routeIndex
            )
        }

        self.places = reorderedPlaces

        // Update snapshot
        var snapshot = NSDiffableDataSourceSnapshot<Section, VisitedPlace>()
        snapshot.appendSections([.places])
        snapshot.appendItems(reorderedPlaces, toSection: .places)
        placesDataSource.apply(snapshot, animatingDifferences: false)

        // Update route map
        updateRouteMap(with: reorderedPlaces)

        // Notify parent
        onPlacesReordered?(reorderedPlaces)

        coordinator.drop(item.dragItem, toItemAt: destinationIndexPath)
    }
}

// MARK: - EditorPhotoCell

final class EditorPhotoCell: UICollectionViewCell {

    private let imageView = UIImageView()
    private let deleteButton = UIButton(type: .system)
    private let addIconImageView = UIImageView()
    private let addLabel = UILabel()

    var onDeleteTapped: (() -> Void)?
    var onAddTapped: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        contentView.addSubviews(imageView, deleteButton, addIconImageView, addLabel)

        contentView.layer.cornerRadius = 8
        contentView.clipsToBounds = true
        contentView.backgroundColor = .secondBackGround

        imageView.do {
            $0.contentMode = .scaleAspectFill
            $0.clipsToBounds = true
        }

        imageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        deleteButton.do {
            $0.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
            $0.tintColor = .white
            $0.backgroundColor = UIColor.black.withAlphaComponent(0.5)
            $0.layer.cornerRadius = 12
            $0.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
        }

        deleteButton.snp.makeConstraints {
            $0.top.trailing.equalToSuperview().inset(4)
            $0.size.equalTo(24)
        }

        addIconImageView.do {
            $0.image = UIImage(systemName: "plus")
            $0.tintColor = .tertiaryLabel
            $0.contentMode = .scaleAspectFit
            $0.isHidden = true
        }

        addIconImageView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview().offset(-10)
            $0.size.equalTo(24)
        }

        addLabel.do {
            $0.text = "추가"
            $0.font = FontManager.caption1
            $0.textColor = .tertiaryLabel
            $0.textAlignment = .center
            $0.isHidden = true
        }

        addLabel.snp.makeConstraints {
            $0.top.equalTo(addIconImageView.snp.bottom).offset(4)
            $0.centerX.equalToSuperview()
        }

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(cellTapped))
        contentView.addGestureRecognizer(tapGesture)
    }

    func configure(with photo: TripPhoto) {
        imageView.isHidden = false
        deleteButton.isHidden = false
        addIconImageView.isHidden = true
        addLabel.isHidden = true
        contentView.backgroundColor = .systemGray5

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

    func configureAsAddButton() {
        imageView.isHidden = true
        imageView.image = nil
        deleteButton.isHidden = true
        addIconImageView.isHidden = false
        addLabel.isHidden = false
        contentView.backgroundColor = .secondBackGround
    }

    @objc private func deleteButtonTapped() {
        onDeleteTapped?()
    }

    @objc private func cellTapped() {
        if !addIconImageView.isHidden {
            onAddTapped?()
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        imageView.contentMode = .scaleAspectFill
        onDeleteTapped = nil
        onAddTapped = nil
    }
}
