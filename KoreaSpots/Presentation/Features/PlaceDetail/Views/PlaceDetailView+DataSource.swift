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
        }
    }

    // MARK: - Individual Cell Configurations

    private func configureImageCell(
        collectionView: UICollectionView,
        indexPath: IndexPath,
        placeImage: PlaceImage
    ) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCarouselCell", for: indexPath) as! FestivalCardCell

        // PlaceImage를 Festival로 변환하여 configure
        let mockFestival = Festival(
            contentId: placeImage.contentId,
            title: placeImage.imageName ?? "",
            address: "",
            imageURL: placeImage.originImageURL,
            eventStartDate: "",
            eventEndDate: "",
            tel: nil,
            mapX: nil,
            mapY: nil,
            overview: nil
        )
        cell.configure(with: mockFestival)
        return cell
    }

    private func configureBasicInfoCell(
        collectionView: UICollectionView,
        indexPath: IndexPath,
        place: Place
    ) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PlaceBasicInfoCell", for: indexPath) as! PlaceBasicInfoCell
        cell.configure(with: place)
        return cell
    }

    private func configureDescriptionCell(
        collectionView: UICollectionView,
        indexPath: IndexPath,
        text: String
    ) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PlaceDescriptionCell", for: indexPath) as! PlaceDescriptionCell
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PlaceOperatingInfoCell", for: indexPath) as! PlaceOperatingInfoCell
        cell.configure(with: operatingInfo)
        return cell
    }

    private func configureLocationCell(
        collectionView: UICollectionView,
        indexPath: IndexPath,
        place: Place
    ) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PlaceLocationCell", for: indexPath) as! PlaceLocationCell
        cell.configure(with: place)
        return cell
    }

    private func configureNearbyPlaceCell(
        collectionView: UICollectionView,
        indexPath: IndexPath,
        place: Place
    ) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NearbyPlaceCell", for: indexPath) as! PlaceCardCell
        cell.configure(with: place)
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