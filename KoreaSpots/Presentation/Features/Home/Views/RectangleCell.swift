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
        iconImageView.image = UIImage(systemName: category.iconName)
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
            $0.backgroundColor = .systemGray6
            $0.layer.cornerRadius = Constants.UI.CornerRadius.medium
            $0.isSkeletonable = true
        }

        iconImageView.do {
            $0.contentMode = .scaleAspectFit
            $0.tintColor = .systemBlue
            $0.isSkeletonable = true
        }

        titleLabel.do {
            $0.font = FontManager.Card.subtitle
            $0.textColor = .label
            $0.textAlignment = .center
            $0.isSkeletonable = true
        }
    }
}
