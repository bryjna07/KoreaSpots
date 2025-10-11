//
//  RectangleCell.swift
//  KoreaSpots
//
//  Created by YoungJin on 9/25/25.
//

import UIKit
import SnapKit
import Then
import SkeletonView

final class RectangleCell: BaseCollectionViewCell {

    // MARK: - UI Components
    private let containerView = UIView()
    private let iconImageView = UIImageView()
    private let titleLabel = UILabel()

    // MARK: - Configuration
    func configure(with category: Category) {
        titleLabel.text = category.title
        iconImageView.image = category.icon
    }

    func configure(with cat3: Cat3) {
        titleLabel.text = cat3.labelKo
        // Cat3에 대한 기본 아이콘 설정 (추후 개별 아이콘 매핑 가능)
        iconImageView.image = UIImage(systemName: "mappin.circle.fill")
    }
}

    // MARK: - ConfigureUI
extension RectangleCell {
    override func configureHierarchy() {
        contentView.addSubview(containerView)
        containerView.addSubviews(
            iconImageView, titleLabel
        )
    }

    override func configureLayout() {
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        iconImageView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(12)
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(32)
        }

        titleLabel.snp.makeConstraints {
            $0.top.equalTo(iconImageView.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(8)
            $0.bottom.equalToSuperview().inset(8)
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

        iconImageView.do {
            $0.contentMode = .scaleAspectFit
            $0.tintColor = .gray
            $0.isSkeletonable = true
        }

        titleLabel.do {
            $0.font = FontManager.Card.subtitle
            $0.textColor = .black
            $0.textAlignment = .center
            $0.isSkeletonable = true
        }
    }
}
