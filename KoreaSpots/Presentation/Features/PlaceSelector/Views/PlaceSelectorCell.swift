//
//  PlaceSelectorCell.swift
//  KoreaSpots
//
//  Created by YoungJin on 10/10/25.
//

import UIKit
import SnapKit
import Then
import Kingfisher

final class PlaceSelectorCell: BaseCollectionViewCell {

    // MARK: - UI Components
    
    private let thumbnailImageView = UIImageView()
    private let titleLabel = UILabel()
    private let addressLabel = UILabel()
    private let checkmarkImageView = UIImageView()
    // Add separator
    private let separator = UIView()

    // MARK: - Configuration

    func configure(with place: Place, isSelected: Bool) {
        titleLabel.text = place.title
        addressLabel.text = place.address

        if let imageURL = place.imageURL, let url = URL(string: imageURL) {
            thumbnailImageView.kf.setImage(
                with: url,
                placeholder: UIImage(systemName: "photo"),
                options: [.transition(.fade(0.2))]
            )
        } else {
            thumbnailImageView.image = UIImage(systemName: "photo")
        }

        checkmarkImageView.isHidden = !isSelected
        contentView.backgroundColor = isSelected ? .systemBlue.withAlphaComponent(0.1) : .systemBackground
    }

    // MARK: - Reuse

    override func prepareForReuse() {
        super.prepareForReuse()
        thumbnailImageView.kf.cancelDownloadTask()
        thumbnailImageView.image = nil
        titleLabel.text = nil
        addressLabel.text = nil
        checkmarkImageView.isHidden = true
    }
}

extension PlaceSelectorCell {
    override func configureHierarchy() {
        contentView.addSubviews(thumbnailImageView, titleLabel, addressLabel, checkmarkImageView, separator)
    }
    
    override func configureLayout() {
        thumbnailImageView.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(16)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(60)
        }

        checkmarkImageView.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(16)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(24)
        }

        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(12)
            $0.leading.equalTo(thumbnailImageView.snp.trailing).offset(12)
            $0.trailing.equalTo(checkmarkImageView.snp.leading).offset(-12)
        }

        addressLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(4)
            $0.leading.equalTo(thumbnailImageView.snp.trailing).offset(12)
            $0.trailing.equalTo(checkmarkImageView.snp.leading).offset(-12)
            $0.bottom.lessThanOrEqualToSuperview().inset(12)
        }
        
        separator.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(0.5)
        }
    }
    
    override func configureView() {
        super.configureView()
        
        contentView.backgroundColor = .backGround
        separator.backgroundColor = .separator
        
        thumbnailImageView.do {
            $0.contentMode = .scaleAspectFill
            $0.clipsToBounds = true
            $0.layer.cornerRadius = 8
            $0.backgroundColor = .systemGray6
        }

        titleLabel.do {
            $0.font = .systemFont(ofSize: 16, weight: .semibold)
            $0.textColor = .label
            $0.numberOfLines = 2
        }

        addressLabel.do {
            $0.font = .systemFont(ofSize: 14, weight: .regular)
            $0.textColor = .secondaryLabel
            $0.numberOfLines = 1
        }

        checkmarkImageView.do {
            $0.image = UIImage(systemName: "checkmark.circle.fill")
            $0.tintColor = .systemBlue
            $0.contentMode = .scaleAspectFit
            $0.isHidden = true
        }
    }
}
