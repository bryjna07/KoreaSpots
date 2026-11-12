//
//  TripEditorView+DataSource.swift
//  KoreaSpots
//
//  Created by YoungJin on 11/12/25.
//

// 역할: Diffable DataSource 구성, 폼/사진/장소/경로 지도 갱신, 장소 삭제
// 의존: TripPlaceCell, EditorPhotoCell, TripFormView
// 사용처: TripEditorView

import UIKit
import SnapKit
import Then
import MapKit

extension TripEditorView {

    func deletePlace(_ place: VisitedPlace) {
        // places 배열에서 제거
        places.removeAll { $0.entryId == place.entryId }

        // order 재정렬
        let reorderedPlaces = places.enumerated().map { index, p in
            VisitedPlace(
                entryId: p.entryId,
                placeId: p.placeId,
                placeNameSnapshot: p.placeNameSnapshot,
                thumbnailURLSnapshot: p.thumbnailURLSnapshot,
                areaCode: p.areaCode,
                sigunguCode: p.sigunguCode,
                addedAt: p.addedAt,
                order: index,
                note: p.note,
                rating: p.rating,
                location: p.location,
                visitedTime: p.visitedTime,
                stayDuration: p.stayDuration,
                routeIndex: p.routeIndex
            )
        }
        self.places = reorderedPlaces

        // 스냅샷 업데이트
        var snapshot = NSDiffableDataSourceSnapshot<Section, VisitedPlace>()
        snapshot.appendSections([.places])
        snapshot.appendItems(reorderedPlaces, toSection: .places)
        placesDataSource.apply(snapshot, animatingDifferences: true)

        // 컬렉션뷰 높이 업데이트
        let itemHeight: CGFloat = 76
        let spacing: CGFloat = 8
        let totalHeight = CGFloat(reorderedPlaces.count) * itemHeight + CGFloat(max(0, reorderedPlaces.count - 1)) * spacing
        placesCollectionView.snp.updateConstraints {
            $0.height.equalTo(totalHeight)
        }

        // 경로 지도 업데이트
        updateRouteMap(with: reorderedPlaces)

        layoutIfNeeded()

        // 부모에게 알림
        onPlaceDeleteTapped?(place)
    }

    // MARK: - Photos DataSource

    func configurePhotosDataSource() {
        let photoCellRegistration = UICollectionView.CellRegistration<EditorPhotoCell, Item> { [weak self] cell, indexPath, item in
            switch item {
            case .photo(let photo):
                cell.configure(with: photo)
                cell.onDeleteTapped = { [weak self] in
                    self?.onPhotoDeleteTapped?(photo)
                }
            case .addPhoto:
                cell.configureAsAddButton()
                cell.onAddTapped = { [weak self] in
                    self?.onAddPhotosTapped?()
                }
            default:
                break
            }
        }

        photosDataSource = UICollectionViewDiffableDataSource<Int, Item>(
            collectionView: photosCollectionView
        ) { collectionView, indexPath, item in
            return collectionView.dequeueConfiguredReusableCell(
                using: photoCellRegistration,
                for: indexPath,
                item: item
            )
        }

        // Initial snapshot with add button only
        var snapshot = NSDiffableDataSourceSnapshot<Int, Item>()
        snapshot.appendSections([0])
        snapshot.appendItems([.addPhoto], toSection: 0)
        photosDataSource.apply(snapshot, animatingDifferences: false)
    }

    // MARK: - Places DataSource

    func configurePlacesDataSource() {
        let placeCellRegistration = UICollectionView.CellRegistration<TripPlaceCell, VisitedPlace> { [weak self] cell, _, place in
            cell.configure(with: place)
            cell.onDeleteTapped = { [weak self] in
                self?.deletePlace(place)
            }
        }

        placesDataSource = UICollectionViewDiffableDataSource<Section, VisitedPlace>(
            collectionView: placesCollectionView
        ) { collectionView, indexPath, place in
            return collectionView.dequeueConfiguredReusableCell(
                using: placeCellRegistration,
                for: indexPath,
                item: place
            )
        }
    }

    // MARK: - Public Methods

    func updateForm(title: String, startDate: Date, endDate: Date, memo: String) {
        formView.configure(title: title, startDate: startDate, endDate: endDate, memo: memo)
    }

    func updatePhotos(_ photos: [TripPhoto]) {
        self.photos = photos

        photosCountLabel.text = "\(photos.count)장"

        var snapshot = NSDiffableDataSourceSnapshot<Int, Item>()
        snapshot.appendSections([0])

        // Add photo items
        let photoItems = photos.map { Item.photo($0) }
        snapshot.appendItems(photoItems, toSection: 0)

        // Add "add photo" button at the end
        snapshot.appendItems([.addPhoto], toSection: 0)

        photosDataSource.apply(snapshot, animatingDifferences: false)
    }

    func updatePlaces(_ places: [VisitedPlace]) {
        self.places = places

        var snapshot = NSDiffableDataSourceSnapshot<Section, VisitedPlace>()
        snapshot.appendSections([.places])
        snapshot.appendItems(places, toSection: .places)
        placesDataSource.apply(snapshot, animatingDifferences: false)

        // Update collection view height based on content
        let itemHeight: CGFloat = 76
        let spacing: CGFloat = 8
        let totalHeight = CGFloat(places.count) * itemHeight + CGFloat(max(0, places.count - 1)) * spacing

        placesCollectionView.snp.updateConstraints {
            $0.height.equalTo(totalHeight)
        }

        // Update route map
        updateRouteMap(with: places)

        layoutIfNeeded()
    }

    func updateRouteMap(with places: [VisitedPlace]) {
        // Clear existing annotations and overlays
        routeMapView.removeAnnotations(routeMapView.annotations)
        routeMapView.removeOverlays(routeMapView.overlays)

        // Filter places with location
        let placesWithLocation = places.compactMap { place -> (VisitedPlace, GeoPoint)? in
            guard let location = place.location,
                  location.lat != 0 && location.lng != 0 else { return nil }
            return (place, location)
        }.sorted { $0.0.order < $1.0.order }

        if placesWithLocation.isEmpty {
            routeMapContainerView.snp.updateConstraints {
                $0.height.equalTo(0)
            }
            routeEmptyLabel.isHidden = true
            return
        }

        // Show map container
        routeMapContainerView.snp.updateConstraints {
            $0.height.equalTo(230)
        }
        routeEmptyLabel.isHidden = true

        // Add annotations
        for (index, (place, location)) in placesWithLocation.enumerated() {
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(latitude: location.lat, longitude: location.lng)
            annotation.title = "\(index + 1). \(place.placeNameSnapshot)"
            routeMapView.addAnnotation(annotation)
        }

        // Add route polyline
        if placesWithLocation.count >= 2 {
            let coordinates = placesWithLocation.map {
                CLLocationCoordinate2D(latitude: $0.1.lat, longitude: $0.1.lng)
            }
            let polyline = MKPolyline(coordinates: coordinates, count: coordinates.count)
            routeMapView.addOverlay(polyline)
        }

        // Fit map to show all annotations
        let annotations = routeMapView.annotations
        if !annotations.isEmpty {
            routeMapView.showAnnotations(annotations, animated: false)
        }
    }
}
