//
//  HomeView+CollectionViewLayout.swift
//  KoreaSpots
//
//  Created by YoungJin on 9/27/25.
//

import UIKit

// MARK: - CollectionViewLayout
extension HomeView {
    func createLayout() -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout { sectionIndex, environment in
            switch sectionIndex {
            case 0: // Festival Section
                return self.createFestivalSection(environment: environment)
            case 1: // Nearby Places Section
                return self.createNearbySection()
            case 2: // Theme Section
                return self.createThemeSection()
            case 3: // Area QuickLink Section
                return self.createAreaQuickLinkSection()
            default: // Placeholder Section
                return self.createPlaceholderSection()
            }
        }
    }

    func createFestivalSection(environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(Constants.UI.CollectionView.Festival.itemHeight)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPaging
        section.interGroupSpacing = 0
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: Constants.UI.Spacing.medium, trailing: 0)

        section.boundarySupplementaryItems = [createSectionHeader(), createPageIndicatorFooter()]

        return section
    }

    func createNearbySection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .absolute(Constants.UI.CollectionView.Place.itemWidth),
            heightDimension: .absolute(Constants.UI.CollectionView.Place.itemHeight)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .absolute(Constants.UI.CollectionView.Place.itemWidth),
            heightDimension: .absolute(Constants.UI.CollectionView.Place.itemHeight)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        section.interGroupSpacing = Constants.UI.Spacing.medium
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: Constants.UI.Spacing.xLarge, bottom: Constants.UI.Spacing.xxLarge, trailing: Constants.UI.Spacing.xLarge)
        section.boundarySupplementaryItems = [createSectionHeader()]

        return section
    }

    func createThemeSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(Constants.UI.CollectionView.Theme.itemWidthFraction),
            heightDimension: .absolute(Constants.UI.CollectionView.Theme.itemHeight)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(
            top: 0,
            leading: Constants.UI.Spacing.tiny,
            bottom: Constants.UI.Spacing.small,
            trailing: Constants.UI.Spacing.tiny
        )

        let rowSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(Constants.UI.CollectionView.Theme.itemHeight)
        )
        let rowGroup = NSCollectionLayoutGroup.horizontal(
            layoutSize: rowSize,
            repeatingSubitem: item,
            count: Constants.UI.CollectionView.Theme.columnsCount
        )

        let containerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(Constants.UI.CollectionView.Theme.containerHeight)
        )
        let containerGroup = NSCollectionLayoutGroup.vertical(
            layoutSize: containerSize,
            repeatingSubitem: rowGroup,
            count: Constants.UI.CollectionView.Theme.rowsCount
        )

        let section = NSCollectionLayoutSection(group: containerGroup)
        section.contentInsets = NSDirectionalEdgeInsets(
            top: 0,
            leading: Constants.UI.Spacing.xLarge,
            bottom: Constants.UI.Spacing.xxLarge,
            trailing: Constants.UI.Spacing.xLarge
        )
        section.boundarySupplementaryItems = [createSectionHeader()]
        return section
    }

    func createAreaQuickLinkSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .absolute(Constants.UI.CollectionView.AreaQuickLink.itemWidth),
            heightDimension: .absolute(Constants.UI.CollectionView.AreaQuickLink.itemHeight)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .absolute(Constants.UI.CollectionView.AreaQuickLink.itemWidth),
            heightDimension: .absolute(Constants.UI.CollectionView.AreaQuickLink.itemHeight)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        section.interGroupSpacing = Constants.UI.CollectionView.AreaQuickLink.spacing
        section.contentInsets = NSDirectionalEdgeInsets(
            top: 0,
            leading: Constants.UI.Spacing.xLarge,
            bottom: Constants.UI.Spacing.xxLarge,
            trailing: Constants.UI.Spacing.xLarge
        )
        section.boundarySupplementaryItems = [createSectionHeader()]
        return section
    }

    func createPlaceholderSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(Constants.UI.CollectionView.Festival.defaultPlaceholderHeight)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(Constants.UI.CollectionView.Festival.defaultPlaceholderHeight)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: Constants.UI.Spacing.xLarge, bottom: Constants.UI.Spacing.xxLarge, trailing: Constants.UI.Spacing.xLarge)
        section.boundarySupplementaryItems = [createSectionHeader()]

        return section
    }

    func createSectionHeader() -> NSCollectionLayoutBoundarySupplementaryItem {
        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(Constants.UI.CollectionView.Header.height)
        )
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        return header
    }

    func createPageIndicatorFooter() -> NSCollectionLayoutBoundarySupplementaryItem {
        let footerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(Constants.UI.CollectionView.Footer.minimumHeight)
        )
        let footer = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: footerSize,
            elementKind: FestivalPageIndicatorView.elementKind,
            alignment: .bottom
        )
        footer.pinToVisibleBounds = true
        footer.zIndex = Constants.UI.CollectionView.PageIndicator.zIndex
        // Footer가 섹션 컨텐츠 위에 overlay되도록 offset 조정
        footer.contentInsets = NSDirectionalEdgeInsets(
            top: Constants.UI.CollectionView.PageIndicator.overlayTopOffset,
            leading: 0,
            bottom: 0,
            trailing: 0
        )
        return footer
    }
}

