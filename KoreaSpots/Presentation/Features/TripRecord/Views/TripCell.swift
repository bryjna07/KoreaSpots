//
//  TripCell.swift
//  KoreaSpots
//
//  Created by YoungJin on 10/10/25.
//

import UIKit
import SnapKit
import Then

final class TripCell: BaseListCell {

    // MARK: - Properties

    var onDeleteTapped: (() -> Void)?

    // MARK: - UI Components

    private let containerView = UIView()
    private let thumbnailImageView = UIImageView()
    private let contentStackView = UIStackView()
    private let titleLabel = UILabel()
    private let dateLabel = UILabel()
    private let memoLabel = UILabel()
    private let bottomStackView = UIStackView()
    private let placeIconImageView = UIImageView()
    private let placeCountLabel = UILabel()
    private let deleteButton = UIButton(type: .system)

    // MARK: - Configuration

    func configure(with trip: Trip) {
        titleLabel.text = trip.title
        dateLabel.text = trip.dateRangeString
        memoLabel.text = trip.memo.isEmpty ? "메모 없음" : trip.memo
        placeCountLabel.text = "\(trip.visitedPlaceCount)개 관광지"

        // Load thumbnail image
        // Priority: 1. First photo from photos array, 2. First place thumbnail, 3. Placeholder
        if let firstPhoto = trip.photos.first,
           !firstPhoto.localPath.isEmpty,
           FileManager.default.fileExists(atPath: firstPhoto.localPath),
           let image = UIImage(contentsOfFile: firstPhoto.localPath) {
            thumbnailImageView.image = image
        } else if let coverPhotoPath = trip.coverPhotoPath,
                  !coverPhotoPath.isEmpty,
                  FileManager.default.fileExists(atPath: coverPhotoPath),
                  let coverImage = UIImage(contentsOfFile: coverPhotoPath) {
            // Fallback to legacy coverPhotoPath
            thumbnailImageView.image = coverImage
        } else if let firstPlace = trip.visitedPlaces.first,
                  let thumbnailURL = firstPlace.thumbnailURLSnapshot {
            // Load from URL
            thumbnailImageView.loadPlaceThumbnail(from: thumbnailURL)
        } else {
            thumbnailImageView.image = UIImage(systemName: "photo.fill")
            thumbnailImageView.tintColor = .tertiaryLabel
            thumbnailImageView.contentMode = .center
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        thumbnailImageView.image = nil
        thumbnailImageView.contentMode = .scaleAspectFill
        titleLabel.text = nil
        dateLabel.text = nil
        memoLabel.text = nil
        placeCountLabel.text = nil
        onDeleteTapped = nil
    }

    // MARK: - Hierarchy & Layout

    override func configureHierarchy() {
        contentView.addSubview(containerView)
        containerView.addSubviews(thumbnailImageView, contentStackView, deleteButton)

        bottomStackView.addArrangedSubviews(placeIconImageView, placeCountLabel)

        contentStackView.addArrangedSubviews(titleLabel, dateLabel, memoLabel, bottomStackView)
    }

    override func configureLayout() {
        containerView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(8)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.bottom.equalToSuperview().offset(-8).priority(.high)
        }

        thumbnailImageView.snp.makeConstraints {
            $0.leading.top.bottom.equalToSuperview()
            $0.width.equalTo(120)
            $0.height.equalTo(120)
        }

        contentStackView.snp.makeConstraints {
            $0.leading.equalTo(thumbnailImageView.snp.trailing).offset(12)
            $0.trailing.equalTo(deleteButton.snp.leading).offset(-8)
            $0.top.equalToSuperview().offset(12)
            $0.bottom.equalToSuperview().offset(-12).priority(.high)
        }

        deleteButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-12)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(24)
        }

        placeIconImageView.snp.makeConstraints {
            $0.width.height.equalTo(16)
        }
    }

    override func configureView() {
        super.configureView()
        // Remove default list cell background and accessories
        accessories = []

        // Disable default selection style
        let backgroundConfig = UIBackgroundConfiguration.clear()
        backgroundConfiguration = backgroundConfig

        containerView.do {
            $0.backgroundColor = .secondBackGround
            $0.layer.cornerRadius = 12
            $0.layer.masksToBounds = true
        }

        thumbnailImageView.do {
            $0.contentMode = .scaleAspectFill
            $0.backgroundColor = .systemGray5
            $0.clipsToBounds = true
        }

        contentStackView.do {
            $0.axis = .vertical
            $0.spacing = 6
            $0.alignment = .leading
        }

        titleLabel.do {
            $0.font = .systemFont(ofSize: 16, weight: .semibold)
            $0.textColor = .label
            $0.numberOfLines = 2
        }

        dateLabel.do {
            $0.font = .systemFont(ofSize: 13, weight: .regular)
            $0.textColor = .secondaryLabel
        }

        memoLabel.do {
            $0.font = .systemFont(ofSize: 14, weight: .regular)
            $0.textColor = .label
            $0.numberOfLines = 1
        }

        bottomStackView.do {
            $0.axis = .horizontal
            $0.spacing = 4
            $0.alignment = .center
        }

        placeIconImageView.do {
            $0.image = UIImage(systemName: "mappin.circle.fill")
            $0.tintColor = .textPrimary
            $0.contentMode = .scaleAspectFit
        }

        placeCountLabel.do {
            $0.font = .systemFont(ofSize: 13, weight: .medium)
            $0.textColor = .textPrimary
        }

        deleteButton.do {
            $0.setImage(UIImage(systemName: "trash.fill"), for: .normal)
            $0.tintColor = .gray
            $0.backgroundColor = .systemBackground
            $0.layer.cornerRadius = 16
            $0.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
        }
    }

    @objc private func deleteButtonTapped() {
        onDeleteTapped?()
    }

    // MARK: - UICollectionViewListCell Configuration

    override func updateConfiguration(using state: UICellConfigurationState) {
        super.updateConfiguration(using: state)

        // Update background configuration based on state
        var backgroundConfig = UIBackgroundConfiguration.clear()
        if state.isHighlighted || state.isSelected {
            backgroundConfig.backgroundColor = .clear
        }
        backgroundConfiguration = backgroundConfig
    }
}

