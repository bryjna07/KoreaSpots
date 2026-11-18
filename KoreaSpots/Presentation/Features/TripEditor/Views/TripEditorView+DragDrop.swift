//
//  TripEditorView+DragDrop.swift
//  KoreaSpots
//
//  Created by YoungJin on 11/12/25.
//

// 역할: 장소 목록 선택 및 드래그 앤 드롭 순서 변경
// 의존: UICollectionViewDragDelegate, UICollectionViewDropDelegate
// 사용처: TripEditorView

import UIKit
import SnapKit
import Then
import MapKit

// MARK: - UICollectionViewDelegate

extension TripEditorView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == placesCollectionView {
            onPlaceSelected?(indexPath)
        }
    }
}

// MARK: - UICollectionViewDragDelegate

extension TripEditorView: UICollectionViewDragDelegate {
    func collectionView(
        _ collectionView: UICollectionView,
        itemsForBeginning session: UIDragSession,
        at indexPath: IndexPath
    ) -> [UIDragItem] {
        guard collectionView == placesCollectionView,
              indexPath.item < places.count else { return [] }

        let place = places[indexPath.item]
        let itemProvider = NSItemProvider(object: place.entryId as NSString)
        let dragItem = UIDragItem(itemProvider: itemProvider)
        dragItem.localObject = place

        return [dragItem]
    }

    func collectionView(_ collectionView: UICollectionView, dragPreviewParametersForItemAt indexPath: IndexPath) -> UIDragPreviewParameters? {
        let parameters = UIDragPreviewParameters()
        parameters.backgroundColor = .clear
        return parameters
    }
}

// MARK: - UICollectionViewDropDelegate

extension TripEditorView: UICollectionViewDropDelegate {
    func collectionView(
        _ collectionView: UICollectionView,
        dropSessionDidUpdate session: UIDropSession,
        withDestinationIndexPath destinationIndexPath: IndexPath?
    ) -> UICollectionViewDropProposal {
        guard collectionView == placesCollectionView,
              collectionView.hasActiveDrag else {
            return UICollectionViewDropProposal(operation: .forbidden)
        }
        return UICollectionViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        performDropWith coordinator: UICollectionViewDropCoordinator
    ) {
        guard collectionView == placesCollectionView,
              let destinationIndexPath = coordinator.destinationIndexPath,
              let item = coordinator.items.first,
              let sourceIndexPath = item.sourceIndexPath,
              let place = item.dragItem.localObject as? VisitedPlace else {
            return
        }

        // Perform the reorder
        places.remove(at: sourceIndexPath.item)
        places.insert(place, at: destinationIndexPath.item)

        // Update order property
        let reorderedPlaces = places.enumerated().map { index, place in
            VisitedPlace(
                entryId: place.entryId,
                placeId: place.placeId,
                placeNameSnapshot: place.placeNameSnapshot,
                thumbnailURLSnapshot: place.thumbnailURLSnapshot,
                areaCode: place.areaCode,
                sigunguCode: place.sigunguCode,
                addedAt: place.addedAt,
                order: index,
                note: place.note,
                rating: place.rating,
                location: place.location,
                visitedTime: place.visitedTime,
                stayDuration: place.stayDuration,
                routeIndex: place.routeIndex
            )
        }

        self.places = reorderedPlaces

        // Update snapshot
        var snapshot = NSDiffableDataSourceSnapshot<Section, VisitedPlace>()
        snapshot.appendSections([.places])
        snapshot.appendItems(reorderedPlaces, toSection: .places)
        placesDataSource.apply(snapshot, animatingDifferences: false)

        // Update route map
        updateRouteMap(with: reorderedPlaces)

        // Notify parent
        onPlacesReordered?(reorderedPlaces)

        coordinator.drop(item.dragItem, toItemAt: destinationIndexPath)
    }
}
