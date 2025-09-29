//
//  AreaQuickLinkCell.swift
//  KoreaSpots
//
//  Created by YoungJin on 9/27/25.
//

import UIKit
import SnapKit
import Then

final class AreaQuickLinkCell: BaseCollectionViewCell {

    // MARK: - UI Components
    private let containerView = UIView()
    private let iconImageView = UIImageView()
    private let areaNameLabel = UILabel()

    override func prepareForReuse() {
        super.prepareForReuse()
        iconImageView.image = nil
        areaNameLabel.text = nil
    }

    // MARK: - Configuration
    func configure(with areaCode: AreaCode) {
        iconImageView.image = UIImage(systemName: areaCode.iconName)?.withConfiguration(
            UIImage.SymbolConfiguration(pointSize: 24, weight: .medium)
        )
        areaNameLabel.text = areaCode.displayName
    }
}

// MARK: - UI Configuration
extension AreaQuickLinkCell {
    override func configureHierarchy() {
        contentView.addSubview(containerView)
        containerView.addSubviews(iconImageView, areaNameLabel)
    }

    override func configureLayout() {
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        iconImageView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.centerX.equalToSuperview()
            $0.size.equalTo(Constants.UI.CollectionView.AreaQuickLink.imageSize)
        }

        areaNameLabel.snp.makeConstraints {
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
            $0.contentMode = .center
            $0.tintColor = .systemBlue
            $0.backgroundColor = .systemGray6
            $0.layer.cornerRadius = Constants.UI.CollectionView.AreaQuickLink.imageSize / 2
            $0.clipsToBounds = true
            $0.layer.borderWidth = 1.5
            $0.layer.borderColor = UIColor.systemGray5.cgColor
        }

        areaNameLabel.do {
            $0.font = .systemFont(ofSize: 12, weight: .medium)
            $0.textColor = .label
            $0.textAlignment = .center
            $0.numberOfLines = 1
            $0.adjustsFontSizeToFitWidth = true
            $0.minimumScaleFactor = 0.8
        }
    }
}
