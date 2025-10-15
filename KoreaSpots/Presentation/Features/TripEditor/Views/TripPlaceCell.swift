//
//  TripPlaceCell.swift
//  KoreaSpots
//
//  Created by YoungJin on 10/10/25.
//

import UIKit
import SnapKit
import Then
import Kingfisher

final class TripPlaceCell: BaseCollectionViewCell {

    // MARK: - UI Components

    private let thumbnailImageView = UIImageView()
    private let titleLabel = UILabel()
    private let reorderIcon = UIImageView()

    // MARK: - Lifecycle

    override func configureHierarchy() {
        contentView.addSubviews(thumbnailImageView, titleLabel, reorderIcon)
    }

    override func configureLayout() {
        thumbnailImageView.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(8)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(60)
        }

        reorderIcon.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(16)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(20)
        }

        titleLabel.snp.makeConstraints {
            $0.leading.equalTo(thumbnailImageView.snp.trailing).offset(12)
            $0.trailing.equalTo(reorderIcon.snp.leading).offset(-12)
            $0.centerY.equalToSuperview()
        }
    }

    override func configureView() {
        super.configureView()

        contentView.do {
            $0.backgroundColor = .systemGray6
            $0.layer.cornerRadius = 8
        }

        thumbnailImageView.do {
            $0.contentMode = .scaleAspectFill
            $0.clipsToBounds = true
            $0.layer.cornerRadius = 8
            $0.backgroundColor = .systemGray6
        }

        titleLabel.do {
            $0.font = .systemFont(ofSize: 16, weight: .semibold)
            $0.textColor = .label
        }

        reorderIcon.do {
            $0.image = UIImage(systemName: "line.3.horizontal")
            $0.tintColor = .secondaryLabel
            $0.contentMode = .scaleAspectFit
        }
    }

    // MARK: - Configuration

    func configure(with place: VisitedPlace) {
        titleLabel.text = place.placeNameSnapshot

        if let thumbnailURL = place.thumbnailURLSnapshot, let url = URL(string: thumbnailURL) {
            thumbnailImageView.kf.setImage(
                with: url
            )
        } else {
            thumbnailImageView.image = UIImage(systemName: "photo")
        }
    }

    // MARK: - Reuse

    override func prepareForReuse() {
        super.prepareForReuse()
        thumbnailImageView.kf.cancelDownloadTask()
        thumbnailImageView.image = nil
        titleLabel.text = nil
    }
}
