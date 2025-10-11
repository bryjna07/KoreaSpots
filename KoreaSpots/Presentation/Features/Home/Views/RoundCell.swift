//
//  RoundCell.swift
//  KoreaSpots
//
//  Created by YoungJin on 9/27/25.
//

import UIKit
import SnapKit
import Then

final class RoundCell: BaseCollectionViewCell {

    // MARK: - UI Components
    private let containerView = UIView()
    private let iconImageView = UIImageView()
    private let titleLabel = UILabel()

    override func prepareForReuse() {
        super.prepareForReuse()
        iconImageView.cancelImageLoad()
        iconImageView.image = nil
        titleLabel.text = nil
    }

    // MARK: - Configuration
    func configure(with theme: Theme) {
        iconImageView.loadImage(
            from: theme.imageName,
            placeholder: UIImage(systemName: "photo"),
            size: .thumbnail,
            cachePolicy: .aggressive
        )
        titleLabel.text = theme.title
    }
}

// MARK: - UI Configuration
extension RoundCell {
    override func configureHierarchy() {
        contentView.addSubview(containerView)
        containerView.addSubviews(iconImageView, titleLabel)
    }

    override func configureLayout() {
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        iconImageView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.centerX.equalToSuperview()
            $0.size.equalTo(Constants.UI.CollectionView.Theme.imageSize)
        }

        titleLabel.snp.makeConstraints {
            $0.top.equalTo(iconImageView.snp.bottom).offset(Constants.UI.Spacing.small)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.lessThanOrEqualToSuperview()
        }
    }

    override func configureView() {
        super.configureView()

        containerView.do {
            $0.backgroundColor = .clear
        }

        iconImageView.do {
            $0.contentMode = .scaleAspectFill
            $0.tintColor = .secondBackGround
            $0.backgroundColor = .onPrimary
            $0.layer.cornerRadius = Constants.UI.CollectionView.Theme.imageSize / 2
            $0.clipsToBounds = true
            $0.layer.borderWidth = 1.5
            $0.layer.borderColor = UIColor.secondBackGround.cgColor
        }

        titleLabel.do {
            $0.font = FontManager.caption2
            $0.textColor = .textPrimary
            $0.textAlignment = .center
            $0.numberOfLines = 1
            $0.adjustsFontSizeToFitWidth = true
            $0.minimumScaleFactor = 0.8
        }
    }
}
