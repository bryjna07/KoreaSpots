//
//  PlaceDetailView+Layout.swift
//  KoreaSpots
//
//  Created by YoungJin on 9/29/25.
//

import UIKit

// MARK: - Layout
extension PlaceDetailView {

    func createLayout() -> UICollectionViewCompositionalLayout {
        let configuration = UICollectionViewCompositionalLayoutConfiguration()
        configuration.interSectionSpacing = Constants.UI.CollectionView.PlaceDetail.Spacing.section

        return UICollectionViewCompositionalLayout(
            sectionProvider: { [weak self] sectionIndex, environment in
                guard let self = self else { return self?.createDefaultSection() }
                return self.createDefaultSection()
            },
            configuration: configuration
        )
    }

    func updateLayout(with sections: [PlaceDetailSectionModel]) {
        let configuration = UICollectionViewCompositionalLayoutConfiguration()
        configuration.interSectionSpacing = Constants.UI.CollectionView.PlaceDetail.Spacing.section

        let layout = UICollectionViewCompositionalLayout(
            sectionProvider: { [weak self] sectionIndex, environment in
                guard let self = self,
                      sectionIndex < sections.count else {
                    return self?.createDefaultSection()
                }

                let sectionType = sections[sectionIndex].section

                switch sectionType {
                case .imageCarousel:
                    return self.createImageCarouselSection()
                case .basicInfo:
                    return self.createBasicInfoSection()
                case .description:
                    return self.createDescriptionSection()
                case .operatingInfo:
                    return self.createOperatingInfoSection()
                case .location:
                    return self.createLocationSection()
                case .nearbyPlaces:
                    return self.createNearbyPlacesSection()
                case .coursePlaces:
                    return self.createCoursePlacesSection()
                }
            },
            configuration: configuration
        )

        collectionView.setCollectionViewLayout(layout, animated: false)
    }

    // MARK: - Section Layouts

    func createImageCarouselSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(Constants.UI.CollectionView.PlaceDetail.ImageCarousel.itemWidthFraction),
            heightDimension: .absolute(Constants.UI.CollectionView.PlaceDetail.ImageCarousel.height)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPaging
        section.interGroupSpacing = Constants.UI.CollectionView.PlaceDetail.ImageCarousel.itemSpacing
        section.contentInsets = NSDirectionalEdgeInsets(
            top: 0,
            leading: Constants.UI.CollectionView.PlaceDetail.ContentInsets.imageCarousel,
            bottom: 0,
            trailing: Constants.UI.CollectionView.PlaceDetail.ContentInsets.imageCarousel
        )

        return section
    }

    func createBasicInfoSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(Constants.UI.CollectionView.PlaceDetail.BasicInfo.estimatedHeight)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(Constants.UI.CollectionView.PlaceDetail.BasicInfo.estimatedHeight)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(
            top: 0,
            leading: Constants.UI.CollectionView.PlaceDetail.ContentInsets.standard,
            bottom: 0,
            trailing: Constants.UI.CollectionView.PlaceDetail.ContentInsets.standard
        )

        return section
    }

    func createDescriptionSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(Constants.UI.CollectionView.PlaceDetail.Description.estimatedHeight)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(Constants.UI.CollectionView.PlaceDetail.Description.estimatedHeight)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(
            top: 0,
            leading: Constants.UI.CollectionView.PlaceDetail.ContentInsets.standard,
            bottom: 0,
            trailing: Constants.UI.CollectionView.PlaceDetail.ContentInsets.standard
        )

        return section
    }

    func createOperatingInfoSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(Constants.UI.CollectionView.PlaceDetail.OperatingInfo.estimatedHeight)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(Constants.UI.CollectionView.PlaceDetail.OperatingInfo.estimatedHeight)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(
            top: 0,
            leading: Constants.UI.CollectionView.PlaceDetail.ContentInsets.standard,
            bottom: 0,
            trailing: Constants.UI.CollectionView.PlaceDetail.ContentInsets.standard
        )

        // Header 추가
        section.boundarySupplementaryItems = [createSectionHeader()]

        return section
    }

    func createLocationSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(Constants.UI.CollectionView.PlaceDetail.Location.height)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(Constants.UI.CollectionView.PlaceDetail.Location.height)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(
            top: 0,
            leading: Constants.UI.CollectionView.PlaceDetail.ContentInsets.standard,
            bottom: 0,
            trailing: Constants.UI.CollectionView.PlaceDetail.ContentInsets.standard
        )

        // Header 추가
        section.boundarySupplementaryItems = [createSectionHeader()]

        return section
    }

    func createNearbyPlacesSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .absolute(Constants.UI.CollectionView.PlaceDetail.NearbyPlaces.itemWidth),
            heightDimension: .absolute(Constants.UI.CollectionView.PlaceDetail.NearbyPlaces.itemHeight)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .absolute(Constants.UI.CollectionView.PlaceDetail.NearbyPlaces.itemWidth),
            heightDimension: .absolute(Constants.UI.CollectionView.PlaceDetail.NearbyPlaces.itemHeight)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        section.interGroupSpacing = Constants.UI.CollectionView.PlaceDetail.NearbyPlaces.itemSpacing
        section.contentInsets = NSDirectionalEdgeInsets(
            top: 0,
            leading: Constants.UI.CollectionView.PlaceDetail.ContentInsets.standard,
            bottom: 0,
            trailing: Constants.UI.CollectionView.PlaceDetail.ContentInsets.standard
        )

        // Header 추가
        section.boundarySupplementaryItems = [createSectionHeader()]

        return section
    }

    func createCoursePlacesSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(84)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(84)
        )
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 8
        section.contentInsets = NSDirectionalEdgeInsets(
            top: 0,
            leading: Constants.UI.CollectionView.PlaceDetail.ContentInsets.standard,
            bottom: 0,
            trailing: Constants.UI.CollectionView.PlaceDetail.ContentInsets.standard
        )

        // Header 추가
        section.boundarySupplementaryItems = [createSectionHeader()]

        return section
    }

    func createDefaultSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(44)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(44)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(
            top: 0,
            leading: Constants.UI.CollectionView.PlaceDetail.ContentInsets.standard,
            bottom: 0,
            trailing: Constants.UI.CollectionView.PlaceDetail.ContentInsets.standard
        )

        return section
    }

    // MARK: - Helper Methods

    private func createSectionHeader() -> NSCollectionLayoutBoundarySupplementaryItem {
        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(Constants.UI.CollectionView.PlaceDetail.Header.height)
        )
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        return header
    }
}