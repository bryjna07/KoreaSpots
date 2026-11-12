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

    var placesDataSource: UICollectionViewDiffableDataSource<Section, VisitedPlace>!
    var photosDataSource: UICollectionViewDiffableDataSource<Int, Item>!

    // Callbacks
    var onAddPlacesTapped: (() -> Void)?
    var onPlaceSelected: ((IndexPath) -> Void)?
    var onAddPhotosTapped: (() -> Void)?
    var onPhotoDeleteTapped: ((TripPhoto) -> Void)?
    var onPlacesReordered: (([VisitedPlace]) -> Void)?
    var onPlaceDeleteTapped: ((VisitedPlace) -> Void)?

    // Data
    var places: [VisitedPlace] = []
    var photos: [TripPhoto] = []

    // MARK: - UI Components

    private let scrollView = UIScrollView()
    private let contentView = UIView()

    // Photos section
    private let photosSectionHeader = UIView()
    private let photosLabel = UILabel()
    let photosCountLabel = UILabel()

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
    let routeMapContainerView = UIView()
    private let routeMapHeaderLabel = UILabel()
    let routeMapView = MKMapView()
    let routeEmptyLabel = UILabel()

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
}
