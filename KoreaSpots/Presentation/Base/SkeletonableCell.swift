//
//  SkeletonableCell.swift
//  KoreaSpots
//
//  Created by YoungJin on 10/14/25.
//

import UIKit
import SkeletonView

/// 스켈레톤 애니메이션을 표시할 수 있는 셀
protocol SkeletonableCell: BaseCollectionViewCell {
    /// 스켈레톤 표시 시 숨겨야 하는 뷰들 (예: overlayView)
    var viewsToHideOnSkeleton: [UIView] { get }
}

// MARK: - Default Implementation
extension SkeletonableCell {

    // 기본적으로 숨길 뷰가 없음
    var viewsToHideOnSkeleton: [UIView] {
        return []
    }

    /// 스켈레톤 표시
    func showSkeletonView() {
        isSkeletonable = true
        contentView.isSkeletonable = true

        // 스켈레톤 표시 중에는 터치 불가
        isUserInteractionEnabled = false
        
        // 숨겨야 할 뷰들 처리 (예: overlayView)
        viewsToHideOnSkeleton.forEach { $0.isHidden = true }

        // 그라디언트 애니메이션
        let gradient = SkeletonGradient(baseColor: .secondBackGround)
        let animation = SkeletonAnimationBuilder().makeSlidingAnimation(withDirection: .leftRight)

        showAnimatedGradientSkeleton(
            usingGradient: gradient,
            animation: animation,
            transition: .crossDissolve(0.25)
        )
    }

    /// 스켈레톤 숨김
    func hideSkeletonView() {
        // 숨겼던 뷰들 복원
        viewsToHideOnSkeleton.forEach { $0.isHidden = false }

        // 터치 다시 활성화
        isUserInteractionEnabled = true

        stopSkeletonAnimation()
        hideSkeleton(reloadDataAfter: false, transition: .crossDissolve(0.25))
    }
}
