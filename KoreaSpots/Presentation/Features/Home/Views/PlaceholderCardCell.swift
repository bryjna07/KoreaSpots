//
//  PlaceholderCardCell.swift
//  KoreaSpots
//
//  Created by YoungJin on 9/25/25.
//

import UIKit
import SnapKit
import Then
import SkeletonView

final class PlaceholderCardCell: BaseCollectionViewCell {

    // MARK: - UI Components
    private let containerView = UIView()
    private let iconImageView = UIImageView()
    private let titleLabel = UILabel()

    // MARK: - Configuration
    func configure(with text: String) {
        titleLabel.text = text
    }
}

    // MARK: - ConfigureUI
extension PlaceholderCardCell {
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
            $0.centerY.equalToSuperview().offset(-10)
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(24)
        }

        titleLabel.snp.makeConstraints {
            $0.top.equalTo(iconImageView.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(16)
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
            $0.image = UIImage(systemName: Constants.Icon.Theme.placeholder)
            $0.contentMode = .scaleAspectFit
            $0.tintColor = .systemGray3
            $0.isSkeletonable = true
        }

        titleLabel.do {
            $0.font = FontManager.bodyMedium
            $0.textColor = .systemGray2
            $0.textAlignment = .center
            $0.isSkeletonable = true
        }

        // Enable skeleton for the entire cell
        isSkeletonable = true
    }
}
