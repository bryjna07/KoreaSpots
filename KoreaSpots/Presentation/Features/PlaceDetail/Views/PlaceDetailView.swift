//
//  PlaceDetailView.swift
//  KoreaSpots
//
//  Created by YoungJin on 9/29/25.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import SnapKit
import Then
import SkeletonView

final class PlaceDetailView: BaseView {

    // MARK: - UI Components
    lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
    let refreshControl = UIRefreshControl()

    // MARK: - Properties
    lazy var dataSource = createDataSource()

    // MARK: - Public Methods
    func endRefreshing() {
        refreshControl.endRefreshing()
    }

    func showSkeleton() {
        collectionView.showAnimatedGradientSkeleton()
    }

    func hideSkeleton() {
        collectionView.hideSkeleton()
    }
}

// MARK: - BaseView Methods
extension PlaceDetailView {

    override func configureHierarchy() {
        addSubview(collectionView)
    }

    override func configureLayout() {
        collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    override func configureView() {
        super.configureView()

        collectionView.do {
            $0.backgroundColor = .backGround
            $0.showsVerticalScrollIndicator = false
            $0.contentInsetAdjustmentBehavior = .automatic
            $0.isSkeletonable = true
            $0.refreshControl = refreshControl
        }

        registerCells()
        registerHeaderFooter()
    }

    private func registerCells() {
        collectionView.register(cell: PlaceImageCell.self, forCellWithReuseIdentifier: PlaceImageCell.reuseIdentifier)
        collectionView.register(cell: PlaceBasicInfoCell.self, forCellWithReuseIdentifier: PlaceBasicInfoCell.reuseIdentifier)
        collectionView.register(cell: PlaceDescriptionCell.self, forCellWithReuseIdentifier: PlaceDescriptionCell.reuseIdentifier)
        collectionView.register(cell: PlaceOperatingInfoCell.self, forCellWithReuseIdentifier: PlaceOperatingInfoCell.reuseIdentifier)
        collectionView.register(cell: PlaceLocationCell.self, forCellWithReuseIdentifier: PlaceLocationCell.reuseIdentifier)
        collectionView.register(cell: PlaceCardCell.self, forCellWithReuseIdentifier: PlaceCardCell.reuseIdentifier)
        collectionView.register(cell: CoursePlaceCell.self, forCellWithReuseIdentifier: CoursePlaceCell.reuseIdentifier)

        // ContentTypeId별 운영정보 Cell 등록
        collectionView.register(cell: FestivalOperatingInfoCell.self, forCellWithReuseIdentifier: FestivalOperatingInfoCell.reuseIdentifier)
        collectionView.register(cell: TouristSpotOperatingInfoCell.self, forCellWithReuseIdentifier: TouristSpotOperatingInfoCell.reuseIdentifier)
        collectionView.register(cell: CulturalFacilityOperatingInfoCell.self, forCellWithReuseIdentifier: CulturalFacilityOperatingInfoCell.reuseIdentifier)
        collectionView.register(cell: LeisureSportsOperatingInfoCell.self, forCellWithReuseIdentifier: LeisureSportsOperatingInfoCell.reuseIdentifier)
        collectionView.register(cell: AccommodationOperatingInfoCell.self, forCellWithReuseIdentifier: AccommodationOperatingInfoCell.reuseIdentifier)
        collectionView.register(cell: ShoppingOperatingInfoCell.self, forCellWithReuseIdentifier: ShoppingOperatingInfoCell.reuseIdentifier)
        collectionView.register(cell: RestaurantOperatingInfoCell.self, forCellWithReuseIdentifier: RestaurantOperatingInfoCell.reuseIdentifier)
        collectionView.register(cell: TravelCourseOperatingInfoCell.self, forCellWithReuseIdentifier: TravelCourseOperatingInfoCell.reuseIdentifier)
    }

    private func registerHeaderFooter() {
        collectionView.register(header: SectionHeaderView.self, reuseIdentifier: SectionHeaderView.reuseIdentifier)
    }
}

