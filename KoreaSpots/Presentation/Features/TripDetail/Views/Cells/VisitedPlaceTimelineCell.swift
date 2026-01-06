//
//  VisitedPlaceTimelineCell.swift
//  KoreaSpots
//
//  Created by Watson22_YJ on 11/16/25.
//

import UIKit
import SnapKit
import Then

final class VisitedPlaceTimelineCell: BaseCollectionViewCell {

    // MARK: - UI Components

    private let orderLabel = UILabel().then {
        $0.font = FontManager.title1
        $0.textColor = .primary
        $0.textAlignment = .center
    }

    private let thumbnailImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 8
        $0.backgroundColor = .systemGray6
    }

    private let placeNameLabel = UILabel().then {
        $0.font = FontManager.bodyBold
        $0.textColor = .label
        $0.numberOfLines = 2
    }

    private let visitTimeLabel = UILabel().then {
        $0.font = FontManager.caption1
        $0.textColor = .secondaryLabel
    }

    private let ratingStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 2
        $0.alignment = .center
    }

    private let noteLabel = UILabel().then {
        $0.font = FontManager.caption1
        $0.textColor = .tertiaryLabel
        $0.numberOfLines = 2
    }

    private let containerView = UIView().then {
        $0.backgroundColor = .systemBackground
        $0.layer.cornerRadius = 12
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.separator.cgColor
    }

    private let verticalLine = UIView().then {
        $0.backgroundColor = UIColor.primary.withAlphaComponent(0.3)
    }

    // MARK: - Setup

    override func configureHierarchy() {
        contentView.addSubviews(orderLabel, verticalLine, containerView)
        containerView.addSubviews(
            thumbnailImageView,
            placeNameLabel,
            visitTimeLabel,
            ratingStackView,
            noteLabel
        )
    }

    override func configureLayout() {
        orderLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(8)
            $0.leading.equalToSuperview().offset(8)
            $0.size.equalTo(32)
        }

        verticalLine.snp.makeConstraints {
            $0.top.equalTo(orderLabel.snp.bottom).offset(4)
            $0.centerX.equalTo(orderLabel)
            $0.width.equalTo(2)
            $0.bottom.equalToSuperview()
        }

        containerView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalTo(orderLabel.snp.trailing).offset(12)
            $0.trailing.equalToSuperview().inset(16)
            $0.bottom.equalToSuperview().inset(12)
        }

        thumbnailImageView.snp.makeConstraints {
            $0.leading.top.bottom.equalToSuperview().inset(12)
            $0.width.equalTo(80)
            $0.height.equalTo(80)
        }

        placeNameLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(12)
            $0.leading.equalTo(thumbnailImageView.snp.trailing).offset(12)
            $0.trailing.equalToSuperview().inset(12)
        }

        visitTimeLabel.snp.makeConstraints {
            $0.top.equalTo(placeNameLabel.snp.bottom).offset(4)
            $0.leading.equalTo(placeNameLabel)
            $0.trailing.equalToSuperview().inset(12)
        }

        ratingStackView.snp.makeConstraints {
            $0.top.equalTo(visitTimeLabel.snp.bottom).offset(4)
            $0.leading.equalTo(placeNameLabel)
        }

        noteLabel.snp.makeConstraints {
            $0.top.equalTo(ratingStackView.snp.bottom).offset(4)
            $0.leading.equalTo(placeNameLabel)
            $0.trailing.equalToSuperview().inset(12)
        }
    }

    override func configureView() {
        super.configureView()
        backgroundColor = .clear
    }

    // MARK: - Configuration

    func configure(with place: VisitedPlace, order: Int, isLast: Bool) {
        orderLabel.text = "\(order)"
        placeNameLabel.text = place.placeNameSnapshot

        // Thumbnail
        if let thumbnailURL = place.thumbnailURLSnapshot, !thumbnailURL.isEmpty {
            thumbnailImageView.loadPlaceThumbnail(from: thumbnailURL)
        } else {
            thumbnailImageView.image = UIImage(systemName: "photo")
            thumbnailImageView.tintColor = .tertiaryLabel
        }

        // Visit time
        if let visitTime = place.visitedTime {
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            visitTimeLabel.text = formatter.string(from: visitTime)
            visitTimeLabel.isHidden = false
        } else {
            visitTimeLabel.isHidden = true
        }

        // Rating
        configureRating(place.rating)

        // Note
        if let note = place.note, !note.isEmpty {
            noteLabel.text = note
            noteLabel.isHidden = false
        } else {
            noteLabel.isHidden = true
        }

        // Hide vertical line for last item
        verticalLine.isHidden = isLast
    }

    private func configureRating(_ rating: Int?) {
        ratingStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        guard let rating = rating, rating > 0 else {
            ratingStackView.isHidden = true
            return
        }

        ratingStackView.isHidden = false

        for i in 0..<5 {
            let starImageView = UIImageView()
            starImageView.contentMode = .scaleAspectFit
            starImageView.tintColor = .systemYellow

            if i < rating {
                starImageView.image = UIImage(systemName: "star.fill")
            } else {
                starImageView.image = UIImage(systemName: "star")
            }

            starImageView.snp.makeConstraints {
                $0.size.equalTo(14)
            }

            ratingStackView.addArrangedSubview(starImageView)
        }
    }

    // MARK: - Reuse

    override func prepareForReuse() {
        super.prepareForReuse()
        thumbnailImageView.image = nil
        placeNameLabel.text = nil
        visitTimeLabel.text = nil
        noteLabel.text = nil
        ratingStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
    }
}
