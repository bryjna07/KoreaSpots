//
//  TripDetailView.swift
//  KoreaSpots
//
//  Created by Watson22_YJ on 11/16/25.
//

import UIKit
import SnapKit
import Then

final class TripDetailView: BaseView {

    // MARK: - UI Components

    let scrollView = UIScrollView().then {
        $0.showsVerticalScrollIndicator = true
        $0.alwaysBounceVertical = true
    }
    let contentView = UIView()

    // MARK: - Photo Carousel Section

    lazy var photoCarouselCollectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: createCarouselLayout()
    ).then {
        $0.backgroundColor = .systemGray6
        $0.showsHorizontalScrollIndicator = false
        $0.isPagingEnabled = true
    }

    let pageControl = UIPageControl().then {
        $0.currentPageIndicatorTintColor = .primary
        $0.pageIndicatorTintColor = .systemGray4
        $0.hidesForSinglePage = true
    }

    private let emptyPhotoView = UIView().then {
        $0.backgroundColor = .systemGray6
        $0.isHidden = true
    }

    private let emptyPhotoImageView = UIImageView().then {
        $0.image = UIImage(systemName: "photo.on.rectangle.angled")
        $0.tintColor = .tertiaryLabel
        $0.contentMode = .scaleAspectFit
    }

    private let emptyPhotoLabel = UILabel().then {
        $0.text = "사진이 없습니다"
        $0.font = FontManager.caption1
        $0.textColor = .tertiaryLabel
        $0.textAlignment = .center
    }

    // MARK: - Trip Info Section

    private let infoContainerView = UIView().then {
        $0.backgroundColor = .systemBackground
    }

    private let dateIconImageView = UIImageView().then {
        $0.image = UIImage(systemName: "calendar")
        $0.tintColor = .secondaryLabel
        $0.contentMode = .scaleAspectFit
    }

    private let dateLabel = UILabel().then {
        $0.font = FontManager.body
        $0.textColor = .label
    }

    private let durationLabel = UILabel().then {
        $0.font = FontManager.caption1
        $0.textColor = .secondaryLabel
    }

    private let memoContainerView = UIView().then {
        $0.backgroundColor = .systemGray6
        $0.layer.cornerRadius = 8
        $0.isHidden = true
    }

    private let memoLabel = UILabel().then {
        $0.font = FontManager.body
        $0.textColor = .label
        $0.numberOfLines = 0
    }

    // MARK: - Places Section

    private let placesSectionHeader = UIView()

    private let placesIconImageView = UIImageView().then {
        $0.image = UIImage(systemName: "mappin.and.ellipse")
        $0.tintColor = .primary
        $0.contentMode = .scaleAspectFit
    }

    private let placesTitleLabel = UILabel().then {
        $0.text = "방문 장소"
        $0.font = FontManager.bodyBold
        $0.textColor = .label
    }

    private let placesCountLabel = UILabel().then {
        $0.font = FontManager.caption1
        $0.textColor = .secondaryLabel
    }

    // Route: 방문지 리스트 + 지도
    let routeContainerView = TripRouteContainerView()

    // MARK: - Properties

    var photos: [TripPhoto] = [] {
        didSet {
            updatePhotoCarousel()
        }
    }

    // MARK: - Hierarchy & Layout

    override func configureHierarchy() {
        addSubview(scrollView)
        scrollView.addSubview(contentView)

        contentView.addSubviews(
            photoCarouselCollectionView,
            pageControl,
            emptyPhotoView,
            infoContainerView,
            placesSectionHeader,
            routeContainerView
        )

        emptyPhotoView.addSubviews(emptyPhotoImageView, emptyPhotoLabel)

        infoContainerView.addSubviews(
            dateIconImageView,
            dateLabel,
            durationLabel,
            memoContainerView
        )
        memoContainerView.addSubview(memoLabel)

        placesSectionHeader.addSubviews(
            placesIconImageView,
            placesTitleLabel,
            placesCountLabel
        )
    }

    override func configureLayout() {
        scrollView.snp.makeConstraints {
            $0.edges.equalTo(safeAreaLayoutGuide)
        }

        contentView.snp.makeConstraints {
            $0.edges.equalTo(scrollView.contentLayoutGuide)
            $0.width.equalTo(scrollView.frameLayoutGuide)
        }

        // Photo Carousel
        photoCarouselCollectionView.snp.makeConstraints {
            $0.top.horizontalEdges.equalToSuperview()
            $0.height.equalTo(250)
        }

        pageControl.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(photoCarouselCollectionView.snp.bottom).offset(-8)
        }

        emptyPhotoView.snp.makeConstraints {
            $0.edges.equalTo(photoCarouselCollectionView)
        }

        emptyPhotoImageView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview().offset(-12)
            $0.size.equalTo(48)
        }

        emptyPhotoLabel.snp.makeConstraints {
            $0.top.equalTo(emptyPhotoImageView.snp.bottom).offset(8)
            $0.centerX.equalToSuperview()
        }

        // Info Section
        infoContainerView.snp.makeConstraints {
            $0.top.equalTo(photoCarouselCollectionView.snp.bottom)
            $0.horizontalEdges.equalToSuperview()
        }

        dateIconImageView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.leading.equalToSuperview().offset(16)
            $0.size.equalTo(20)
        }

        dateLabel.snp.makeConstraints {
            $0.centerY.equalTo(dateIconImageView)
            $0.leading.equalTo(dateIconImageView.snp.trailing).offset(8)
        }

        durationLabel.snp.makeConstraints {
            $0.centerY.equalTo(dateIconImageView)
            $0.leading.equalTo(dateLabel.snp.trailing).offset(8)
            $0.trailing.lessThanOrEqualToSuperview().offset(-16)
        }

        memoContainerView.snp.makeConstraints {
            $0.top.equalTo(dateIconImageView.snp.bottom).offset(12)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.bottom.equalToSuperview().offset(-16)
        }

        memoLabel.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(12)
        }

        // Places Section Header
        placesSectionHeader.snp.makeConstraints {
            $0.top.equalTo(infoContainerView.snp.bottom).offset(8)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(44)
        }

        placesIconImageView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(20)
        }

        placesTitleLabel.snp.makeConstraints {
            $0.leading.equalTo(placesIconImageView.snp.trailing).offset(8)
            $0.centerY.equalToSuperview()
        }

        placesCountLabel.snp.makeConstraints {
            $0.leading.equalTo(placesTitleLabel.snp.trailing).offset(8)
            $0.centerY.equalToSuperview()
        }

        // Route Container - 높이 제한 없이 콘텐츠에 맞게 조정
        routeContainerView.snp.makeConstraints {
            $0.top.equalTo(placesSectionHeader.snp.bottom)
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-16)
        }
    }

    override func configureView() {
        backgroundColor = .systemBackground
    }

    // MARK: - Public Methods

    func configure(with trip: Trip) {
        // Date formatting
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd"

        let startDateString = dateFormatter.string(from: trip.startDate)
        let endDateString = dateFormatter.string(from: trip.endDate)

        if Calendar.current.isDate(trip.startDate, inSameDayAs: trip.endDate) {
            dateLabel.text = startDateString
        } else {
            dateLabel.text = "\(startDateString) - \(endDateString)"
        }

        // Duration calculation
        let days = Calendar.current.dateComponents([.day], from: trip.startDate, to: trip.endDate).day ?? 0
        if days == 0 {
            durationLabel.text = "(당일치기)"
        } else {
            durationLabel.text = "(\(days + 1)일)"
        }

        // Memo
        if !trip.memo.isEmpty {
            memoContainerView.isHidden = false
            memoLabel.text = trip.memo
        } else {
            memoContainerView.isHidden = true
        }

        // Places count
        placesCountLabel.text = "\(trip.visitedPlaces.count)곳"

        // Configure route
        routeContainerView.configure(with: trip.visitedPlaces)
    }

    func configurePhotos(with photos: [TripPhoto]) {
        self.photos = photos
    }

    private func updatePhotoCarousel() {
        let hasPhotos = !photos.isEmpty
        photoCarouselCollectionView.isHidden = !hasPhotos
        pageControl.isHidden = !hasPhotos
        emptyPhotoView.isHidden = hasPhotos

        pageControl.numberOfPages = photos.count
        pageControl.currentPage = 0

        photoCarouselCollectionView.reloadData()
    }

    // MARK: - Carousel Layout

    private func createCarouselLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPaging

        section.visibleItemsInvalidationHandler = { [weak self] visibleItems, point, environment in
            let pageIndex = Int(round(point.x / environment.container.contentSize.width))
            self?.pageControl.currentPage = pageIndex
        }

        return UICollectionViewCompositionalLayout(section: section)
    }
}
