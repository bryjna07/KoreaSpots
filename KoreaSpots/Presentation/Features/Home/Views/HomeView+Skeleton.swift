//
//  HomeView+Skeleton.swift
//  KoreaSpots
//
//  Created by YoungJin on 9/26/25.
//

import UIKit
import SkeletonView

// MARK: - HomeView Skeleton Extension
extension HomeView {

    func showSkeletonView() {
        // Instead of changing dataSource, enable skeleton on individual cells
        collectionView.isSkeletonable = true

        // Make sure all registered cells are skeletonable
        DispatchQueue.main.async {
            self.collectionView.visibleCells.forEach { cell in
                cell.isSkeletonable = true
                cell.showAnimatedGradientSkeleton()
            }
        }
    }

    func hideSkeletonView() {
        // Hide skeleton on all cells
        DispatchQueue.main.async {
            self.collectionView.visibleCells.forEach { cell in
                cell.hideSkeleton()
            }
        }

        collectionView.hideSkeleton()
    }

    // Enable skeleton on collection view without conflicting with RxDataSources
    func setupSkeletonCompatibility() {
        collectionView.isSkeletonable = true
    }
}
