//
//  PlaceDetailView+DataSource.swift
//  KoreaSpots
//
//  Created by YoungJin on 9/29/25.
//

import UIKit
import RxDataSources

// MARK: - DataSource
extension PlaceDetailView {

    func createDataSource() -> RxCollectionViewSectionedAnimatedDataSource<PlaceDetailSectionModel> {
        return RxCollectionViewSectionedAnimatedDataSource<PlaceDetailSectionModel>(
            configureCell: { [weak self] dataSource, collectionView, indexPath, item in
                guard let self = self else { return UICollectionViewCell() }
                return self.configureCell(collectionView: collectionView, indexPath: indexPath, item: item)
            },
            configureSupplementaryView: { [weak self] dataSource, collectionView, kind, indexPath in
                guard let self = self else { return UICollectionReusableView() }
                return self.configureSupplementaryView(
                    collectionView: collectionView,
                    kind: kind,
                    indexPath: indexPath,
                    sections: dataSource.sectionModels
                )
            }
        )
    }

    // MARK: - Cell Configuration

    private func configureCell(
        collectionView: UICollectionView,
        indexPath: IndexPath,
        item: PlaceDetailSectionItem
    ) -> UICollectionViewCell {
        switch item {
        case .image(let placeImage):
            return configureImageCell(collectionView: collectionView, indexPath: indexPath, placeImage: placeImage)

        case .basicInfo(let place):
            return configureBasicInfoCell(collectionView: collectionView, indexPath: indexPath, place: place)

        case .description(let text):
            return configureDescriptionCell(collectionView: collectionView, indexPath: indexPath, text: text)

        case .operatingInfo(let operatingInfo):
            return configureOperatingInfoCell(collectionView: collectionView, indexPath: indexPath, operatingInfo: operatingInfo)

        case .location(let place):
            return configureLocationCell(collectionView: collectionView, indexPath: indexPath, place: place)

        case .nearbyPlace(let place):
            return configureNearbyPlaceCell(collectionView: collectionView, indexPath: indexPath, place: place)

        case .coursePlace(let courseDetail, let index):
            return configureCoursePlaceCell(collectionView: collectionView, indexPath: indexPath, courseDetail: courseDetail, index: index)
        }
    }

    // MARK: - Individual Cell Configurations

    private func configureImageCell(
        collectionView: UICollectionView,
        indexPath: IndexPath,
        placeImage: PlaceImage
    ) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PlaceImageCell.reuseIdentifier, for: indexPath) as! PlaceImageCell
        cell.configure(with: placeImage.originImageURL)
        return cell
    }

    private func configureBasicInfoCell(
        collectionView: UICollectionView,
        indexPath: IndexPath,
        place: Place
    ) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PlaceBasicInfoCell.reuseIdentifier, for: indexPath) as! PlaceBasicInfoCell
        cell.configure(with: place)
        return cell
    }

    private func configureDescriptionCell(
        collectionView: UICollectionView,
        indexPath: IndexPath,
        text: String
    ) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PlaceDescriptionCell.reuseIdentifier, for: indexPath) as! PlaceDescriptionCell
        cell.configure(with: text)

        // 더보기 버튼 콜백: 셀 높이 재계산
        cell.onToggleExpand = { [weak collectionView] in
            collectionView?.performBatchUpdates(nil, completion: nil)
        }

        return cell
    }

    private func configureOperatingInfoCell(
        collectionView: UICollectionView,
        indexPath: IndexPath,
        operatingInfo: OperatingInfo
    ) -> UICollectionViewCell {
        // specificInfo의 타입에 따라 적절한 Cell 반환
        guard let specificInfo = operatingInfo.specificInfo else {
            // specificInfo가 없으면 기본 PlaceOperatingInfoCell 사용
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PlaceOperatingInfoCell.reuseIdentifier, for: indexPath) as! PlaceOperatingInfoCell
            cell.configure(with: operatingInfo)
            return cell
        }

        switch specificInfo {
        case .festival:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FestivalOperatingInfoCell.reuseIdentifier, for: indexPath) as! FestivalOperatingInfoCell
            cell.configure(with: operatingInfo)
            return cell

        case .touristSpot:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TouristSpotOperatingInfoCell.reuseIdentifier, for: indexPath) as! TouristSpotOperatingInfoCell
            cell.configure(with: operatingInfo)
            return cell

        case .culturalFacility:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CulturalFacilityOperatingInfoCell.reuseIdentifier, for: indexPath) as! CulturalFacilityOperatingInfoCell
            cell.configure(with: operatingInfo)
            return cell

        case .leisureSports:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LeisureSportsOperatingInfoCell.reuseIdentifier, for: indexPath) as! LeisureSportsOperatingInfoCell
            cell.configure(with: operatingInfo)
            return cell

        case .accommodation:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AccommodationOperatingInfoCell.reuseIdentifier, for: indexPath) as! AccommodationOperatingInfoCell
            cell.configure(with: operatingInfo)
            return cell

        case .shopping:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ShoppingOperatingInfoCell.reuseIdentifier, for: indexPath) as! ShoppingOperatingInfoCell
            cell.configure(with: operatingInfo)
            return cell

        case .restaurant:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RestaurantOperatingInfoCell.reuseIdentifier, for: indexPath) as! RestaurantOperatingInfoCell
            cell.configure(with: operatingInfo)
            return cell

        case .travelCourse:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TravelCourseOperatingInfoCell.reuseIdentifier, for: indexPath) as! TravelCourseOperatingInfoCell
            cell.configure(with: operatingInfo)
            return cell
        }
    }

    private func configureLocationCell(
        collectionView: UICollectionView,
        indexPath: IndexPath,
        place: Place
    ) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PlaceLocationCell.reuseIdentifier, for: indexPath) as! PlaceLocationCell
        cell.configure(with: place)
        return cell
    }

    private func configureNearbyPlaceCell(
        collectionView: UICollectionView,
        indexPath: IndexPath,
        place: Place
    ) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PlaceCardCell.reuseIdentifier, for: indexPath) as! PlaceCardCell
        cell.configure(with: place)
        return cell
    }

    private func configureCoursePlaceCell(
        collectionView: UICollectionView,
        indexPath: IndexPath,
        courseDetail: CourseDetail,
        index: Int
    ) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CoursePlaceCell.reuseIdentifier, for: indexPath) as! CoursePlaceCell
        cell.configure(with: courseDetail, index: index)
        return cell
    }

    // MARK: - Supplementary View Configuration

    private func configureSupplementaryView(
        collectionView: UICollectionView,
        kind: String,
        indexPath: IndexPath,
        sections: [PlaceDetailSectionModel]
    ) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: SectionHeaderView.reuseIdentifier,
                for: indexPath
            ) as! SectionHeaderView

            let sectionType = sections[indexPath.section].section
            header.configure(with: sectionType.headerTitle)
            return header
        }

        return UICollectionReusableView()
    }
}
