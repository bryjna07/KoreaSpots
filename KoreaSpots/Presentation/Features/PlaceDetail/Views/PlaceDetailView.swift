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
            $0.backgroundColor = .systemBackground
            $0.showsVerticalScrollIndicator = false
            $0.contentInsetAdjustmentBehavior = .automatic
            $0.isSkeletonable = true
            $0.refreshControl = refreshControl
        }

        registerCells()
        registerHeaderFooter()
    }

    private func registerCells() {
        collectionView.register(cell: PlaceImageCell.self, forCellWithReuseIdentifier: "ImageCarouselCell")
        collectionView.register(cell: PlaceBasicInfoCell.self, forCellWithReuseIdentifier: "PlaceBasicInfoCell")
        collectionView.register(cell: PlaceDescriptionCell.self, forCellWithReuseIdentifier: "PlaceDescriptionCell")
        collectionView.register(cell: PlaceOperatingInfoCell.self, forCellWithReuseIdentifier: "PlaceOperatingInfoCell")
        collectionView.register(cell: PlaceLocationCell.self, forCellWithReuseIdentifier: "PlaceLocationCell")
        collectionView.register(cell: PlaceCardCell.self, forCellWithReuseIdentifier: "NearbyPlaceCell")
    }

    private func registerHeaderFooter() {
        collectionView.register(header: SectionHeaderView.self, reuseIdentifier: SectionHeaderView.reuseIdentifier)
    }
}

