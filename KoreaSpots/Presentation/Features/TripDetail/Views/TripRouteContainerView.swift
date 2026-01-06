//
//  TripRouteContainerView.swift
//  KoreaSpots
//
//  Created by Watson22_YJ on 11/16/25.
//

import UIKit
import SnapKit
import Then

final class TripRouteContainerView: BaseView {

    // MARK: - UI Components

    lazy var collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: createLayout()
    ).then {
        $0.backgroundColor = .systemBackground
        $0.showsVerticalScrollIndicator = false
        $0.isScrollEnabled = false
    }

    let mapContainerView = UIView().then {
        $0.backgroundColor = .systemGray6
        $0.layer.cornerRadius = 12
        $0.clipsToBounds = true
    }

    let mapView = TripRouteMapView()

    private let emptyStateLabel = UILabel().then {
        $0.text = "방문지가 없습니다."
        $0.font = FontManager.body
        $0.textColor = .secondaryLabel
        $0.textAlignment = .center
        $0.isHidden = true
    }

    // MARK: - Properties

    var visitedPlaces: [VisitedPlace] = []

    // MARK: - Hierarchy & Layout

    override func configureHierarchy() {
        addSubviews(collectionView, mapContainerView, emptyStateLabel)
        mapContainerView.addSubview(mapView)
    }

    override func configureLayout() {
        collectionView.snp.makeConstraints {
            $0.top.horizontalEdges.equalToSuperview()
            $0.height.equalTo(0) // Will be updated dynamically
        }

        mapContainerView.snp.makeConstraints {
            $0.top.equalTo(collectionView.snp.bottom).offset(16)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.bottom.equalToSuperview().inset(16)
            $0.height.equalTo(180)
        }

        mapView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        emptyStateLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.horizontalEdges.equalToSuperview().inset(32)
        }
    }

    // MARK: - Public Methods

    func configure(with visitedPlaces: [VisitedPlace]) {
        self.visitedPlaces = visitedPlaces.sorted { $0.order < $1.order }

        if visitedPlaces.isEmpty {
            emptyStateLabel.isHidden = false
            collectionView.isHidden = true
            mapContainerView.isHidden = true
        } else {
            emptyStateLabel.isHidden = true
            collectionView.isHidden = false
            mapContainerView.isHidden = false

            // Configure map
            mapView.configure(with: visitedPlaces)
        }
    }

    /// CollectionView DataSource 적용 후 높이 업데이트
    func updateCollectionViewHeight(for itemCount: Int) {
        guard itemCount > 0 else {
            collectionView.snp.updateConstraints {
                $0.height.equalTo(0)
            }
            return
        }

        // 셀 높이: thumbnail(80) + padding(12+12) + bottom inset(12) = 약 116
        let itemHeight: CGFloat = 116
        let spacing: CGFloat = 12
        let verticalInset: CGFloat = 32 // top(16) + bottom(16)
        let calculatedHeight = CGFloat(itemCount) * itemHeight + CGFloat(max(0, itemCount - 1)) * spacing + verticalInset

        collectionView.snp.updateConstraints {
            $0.height.equalTo(calculatedHeight)
        }
    }

    // MARK: - CollectionView Layout

    private func createLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(100)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(100)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 12
        section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16)

        return UICollectionViewCompositionalLayout(section: section)
    }
}
