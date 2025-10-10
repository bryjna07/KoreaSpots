//
//  TripRecordView.swift
//  KoreaSpots
//
//  Created by YoungJin on 10/10/25.
//

import UIKit
import SnapKit
import Then

final class TripRecordView: BaseView {

    // MARK: - UI Components
    let statisticsHeaderView = TripStatisticsHeaderView()
    lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
}

    // MARK: - Hierarchy & Layout

extension TripRecordView {
    override func configureHierarchy() {
        addSubviews(statisticsHeaderView, collectionView)
    }

    override func configureLayout() {
        statisticsHeaderView.snp.makeConstraints {
            $0.top.leading.trailing.equalTo(safeAreaLayoutGuide)
            $0.height.equalTo(150)
        }

        collectionView.snp.makeConstraints {
            $0.top.equalTo(statisticsHeaderView.snp.bottom)
            $0.leading.trailing.bottom.equalTo(safeAreaLayoutGuide)
        }
    }
    
    override func configureView() {
        super.configureView()

        collectionView.do {
            $0.backgroundColor = .backGround
            $0.showsVerticalScrollIndicator = true
            $0.contentInsetAdjustmentBehavior = .automatic
            $0.allowsSelection = true
        }
    }
}

    // MARK: - Compositional Layout

extension TripRecordView {
    func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { sectionIndex, environment in
            // Only trips section with list configuration
            return self.createTripsSection(environment: environment)
        }
        return layout
    }

    func createTripsSection(environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        var configuration = UICollectionLayoutListConfiguration(appearance: .plain)
        configuration.showsSeparators = false
        configuration.backgroundColor = .clear

        let section = NSCollectionLayoutSection.list(
            using: configuration,
            layoutEnvironment: environment
        )

        section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 0, bottom: 16, trailing: 0)

        return section
    }
}
