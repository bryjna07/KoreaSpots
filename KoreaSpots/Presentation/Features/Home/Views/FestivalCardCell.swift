//
//  FestivalCardCell.swift
//  KoreaSpots
//
//  Created by YoungJin on 9/25/25.
//

import UIKit
import SnapKit
import Then
import SkeletonView

final class FestivalCardCell: BaseCollectionViewCell, CollectionViewCellConfigurable, SkeletonableCell {

    // MARK: - UI Components
    private let containerView = UIView()
    private let imageView = UIImageView()
    private let overlayView = UIView() // 텍스트 가독성을 위한 이미지뷰 위 오버레이뷰
    private let titleLabel = UILabel()
    private let periodLabel = UILabel()
    private let locationLabel = UILabel()

    // MARK: - SkeletonableCell
    var viewsToHideOnSkeleton: [UIView] {
        return [overlayView]  // 스켈레톤 표시 시 overlayView 숨김
    }

    // MARK: - Configuration
    func configure(with model: Place) {
        configureFestival(model)
    }

    private func configureFestival(_ place: Place) {
        titleLabel.text = place.title

        guard let eventMeta = place.eventMeta else { return }
        periodLabel.text = DateFormatterUtil.formatPeriod(start: eventMeta.eventStartDate, end: eventMeta.eventEndDate)

        locationLabel.text = place.address

        // ImageLoader를 사용한 축제 배너 이미지 로딩
        imageView.loadFestivalBanner(from: place.imageURL)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.cancelImageLoad()
        imageView.image = nil
        overlayView.isHidden = false
    }
}

    // MARK: - ConfigureUI
extension FestivalCardCell {
    override func configureHierarchy() {
        contentView.addSubview(containerView)
        containerView.addSubviews(
            imageView, overlayView, titleLabel, periodLabel, locationLabel
        )
    }
    
    override func configureLayout() {
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        imageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        overlayView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        locationLabel.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.bottom.equalToSuperview().inset(12)
        }
        
        periodLabel.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.bottom.equalTo(locationLabel.snp.top).offset(-4)
        }
        
        titleLabel.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.bottom.equalTo(periodLabel.snp.top).offset(-8)
        }
    }
    
    override func configureView() {
        super.configureView()
        
        containerView.do {
            $0.backgroundColor = .secondBackGround
//            $0.layer.cornerRadius = Constants.UI.CornerRadius.medium
            $0.layer.masksToBounds = true
            $0.isSkeletonable = true
        }

        imageView.do {
            $0.contentMode = .scaleAspectFill
            $0.backgroundColor = .secondBackGround
            $0.isSkeletonable = true
        }
        
        overlayView.do {
            $0.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        }
        
        titleLabel.do {
            $0.font = FontManager.Card.title
            $0.textColor = .white
            $0.numberOfLines = 2
            $0.isSkeletonable = true
        }

        periodLabel.do {
            $0.font = FontManager.Card.subtitle
            $0.textColor = .white
            $0.isSkeletonable = true
        }

        locationLabel.do {
            $0.font = FontManager.Card.description
            $0.textColor = .white.withAlphaComponent(0.8)
            $0.isSkeletonable = true
        }
    }
}
