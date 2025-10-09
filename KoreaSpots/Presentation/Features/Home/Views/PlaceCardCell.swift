//
//  PlaceCardCell.swift
//  KoreaSpots
//
//  Created by YoungJin on 9/25/25.
//

import UIKit
import SnapKit
import Then
import SkeletonView

final class PlaceCardCell: BaseCollectionViewCell {

    // MARK: - UI Components
    private let containerView = UIView()
    private let imageView = UIImageView()
    private let titleLabel = UILabel()
    private let addressLabel = UILabel()
    private let distanceLabel = UILabel()

    // MARK: - Configuration
    func configure(with place: Place) {
        titleLabel.text = place.title
        addressLabel.text = place.address

        if let distance = place.distance {
            if distance < 1000 {
                distanceLabel.text = "\(distance)m"
            } else {
                let km = Double(distance) / 1000.0
                distanceLabel.text = String(format: "%.1fkm", km)
            }
            distanceLabel.isHidden = false
        } else {
            distanceLabel.isHidden = true
        }

        // ImageLoader를 사용한 관광지 이미지 로딩
        imageView.loadTourismImage(from: place.imageURL, type: .attraction)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.cancelImageLoad()
        imageView.image = nil
    }
}

    // MARK: - ConfigureUI
extension PlaceCardCell {
    override func configureHierarchy() {
        contentView.addSubview(containerView)
        containerView.addSubviews(
            imageView, titleLabel, addressLabel, distanceLabel
        )
    }
    
    override func configureLayout() {
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        imageView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview().inset(8)
            $0.height.equalTo(100)
        }

        titleLabel.snp.makeConstraints {
            $0.top.equalTo(imageView.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(8)
        }

        addressLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(4)
            $0.leading.trailing.equalToSuperview().inset(8)
        }

        distanceLabel.snp.makeConstraints {
            $0.top.equalTo(addressLabel.snp.bottom).offset(4)
            $0.leading.trailing.equalToSuperview().inset(8)
            $0.bottom.lessThanOrEqualToSuperview().inset(8)
        }
    }
    
    override func configureView() {
        super.configureView()
        
        containerView.do {
            $0.backgroundColor = .white
            $0.layer.cornerRadius = Constants.UI.CornerRadius.medium
            $0.layer.shadowColor = UIColor.black.cgColor
            $0.layer.shadowOpacity = Constants.UI.Shadow.opacity
            $0.layer.shadowOffset = Constants.UI.Shadow.offset
            $0.layer.shadowRadius = Constants.UI.Shadow.radius
            $0.isSkeletonable = true
        }

        imageView.do {
            $0.contentMode = .scaleAspectFill
            $0.backgroundColor = .secondBackGround
            $0.layer.cornerRadius = Constants.UI.CornerRadius.small
            $0.layer.masksToBounds = true
            $0.isSkeletonable = true
        }

        titleLabel.do {
            $0.font = FontManager.Card.title
            $0.textColor = .textPrimary
            $0.numberOfLines = 2
            $0.isSkeletonable = true
        }

        addressLabel.do {
            $0.font = FontManager.Card.description
            $0.textColor = .textTertiary
            $0.numberOfLines = 1
            $0.isSkeletonable = true
        }

        distanceLabel.do {
            $0.font = FontManager.caption3
            $0.textColor = .textSecondary
        }
    }
}
