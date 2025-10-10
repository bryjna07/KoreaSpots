//
//  TripCell.swift
//  KoreaSpots
//
//  Created by YoungJin on 10/10/25.
//

import UIKit
import SnapKit
import Then

final class TripCell: BaseCollectionViewCell {

    // MARK: - UI Components

    private let containerView = UIView().then {
        $0.backgroundColor = .secondBackGround
        $0.layer.cornerRadius = 12
        $0.layer.masksToBounds = true
    }

    private let thumbnailImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.backgroundColor = .systemGray5
        $0.clipsToBounds = true
    }

    private let contentStackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 6
        $0.alignment = .leading
    }

    private let titleLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 16, weight: .semibold)
        $0.textColor = .label
        $0.numberOfLines = 2
    }

    private let dateLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 13, weight: .regular)
        $0.textColor = .secondaryLabel
    }

    private let memoLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 14, weight: .regular)
        $0.textColor = .label
        $0.numberOfLines = 1
    }

    private let bottomStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 4
        $0.alignment = .center
    }

    private let placeIconImageView = UIImageView().then {
        $0.image = UIImage(systemName: "mappin.circle.fill")
        $0.tintColor = .textPrimary
        $0.contentMode = .scaleAspectFit
    }

    private let placeCountLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 13, weight: .medium)
        $0.textColor = .textPrimary
    }

    // MARK: - Configuration

    func configure(with trip: Trip) {
        titleLabel.text = trip.title
        dateLabel.text = trip.dateRangeString
        memoLabel.text = trip.memo.isEmpty ? "메모 없음" : trip.memo
        placeCountLabel.text = "\(trip.visitedPlaceCount)개 관광지"

        // TODO: Load thumbnail image from coverPhotoPath
        if let coverPhotoPath = trip.coverPhotoPath {
            // Load from file system
            thumbnailImageView.image = UIImage(named: "placeholder")
        } else if let firstPlace = trip.visitedPlaces.first,
                  let thumbnailURL = firstPlace.thumbnailURLSnapshot {
            // Load from URL
            thumbnailImageView.loadPlaceThumbnail(from: thumbnailURL)
        } else {
            thumbnailImageView.image = UIImage(named: "placeholder")
        }
    }

    // MARK: - Hierarchy & Layout

    override func configureHierarchy() {
        contentView.addSubview(containerView)
        containerView.addSubviews(thumbnailImageView, contentStackView)

        bottomStackView.addArrangedSubviews(placeIconImageView, placeCountLabel)

        contentStackView.addArrangedSubviews(titleLabel, dateLabel, memoLabel, bottomStackView)
    }

    override func configureLayout() {
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16))
        }

        thumbnailImageView.snp.makeConstraints {
            $0.leading.top.bottom.equalToSuperview()
            $0.width.equalTo(120)
        }

        contentStackView.snp.makeConstraints {
            $0.leading.equalTo(thumbnailImageView.snp.trailing).offset(12)
            $0.trailing.equalToSuperview().offset(-12)
            $0.centerY.equalToSuperview()
        }

        placeIconImageView.snp.makeConstraints {
            $0.width.height.equalTo(16)
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        thumbnailImageView.image = nil
        titleLabel.text = nil
        dateLabel.text = nil
        memoLabel.text = nil
        placeCountLabel.text = nil
    }
}
