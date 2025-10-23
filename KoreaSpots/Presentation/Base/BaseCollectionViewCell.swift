//
//  BaseCollectionViewCell.swift
//  KoreaSpots
//
//  Created by YoungJin on 9/25/25.
//

import UIKit

class BaseCollectionViewCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureHierarchy()
        configureLayout()
        configureView()
    }
    
    @available(*, unavailable, message: "Use init(frame:) instead.")
    required init?(coder: NSCoder) { nil }
    
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

extension BaseCollectionViewCell: ConfigureUI {
    
    func configureHierarchy() { }
    
    func configureLayout() { }
    
    func configureView() {
        backgroundColor = .backGround
    }
}
