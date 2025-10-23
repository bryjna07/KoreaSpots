//
//  UICollectionView+Extension.swift
//  KoreaSpots
//
//  Created by YoungJin on 10/15/25.
//

import UIKit.UICollectionView

extension UICollectionView {
    /// 더미 데이터 셀에 스켈레톤 적용
    func configureSkeletonIfNeeded<T: SkeletonDataIdentifiable>(
        for cell: UICollectionViewCell,
        with data: T
    ) {
        guard let skeletonCell = cell as? SkeletonableCell else { return }
        
        if data.isSkeletonData {
            skeletonCell.showSkeletonView()
        } else {
            skeletonCell.hideSkeletonView()
        }
    }
}
