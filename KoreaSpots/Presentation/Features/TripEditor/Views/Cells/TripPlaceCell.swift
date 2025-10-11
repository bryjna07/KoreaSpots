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

final class TripPlaceCell: UICollectionViewCell {

    // MARK: - UI Components

    private let thumbnailImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 8
        $0.backgroundColor = .systemGray6
    }

    private let titleLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 16, weight: .semibold)
        $0.textColor = .label
    }

    private let reorderIcon = UIImageView().then {
        $0.image = UIImage(systemName: "line.3.horizontal")
        $0.tintColor = .secondaryLabel
        $0.contentMode = .scaleAspectFit
    }

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setupViews() {
        contentView.backgroundColor = .systemGray6
        contentView.layer.cornerRadius = 8
        contentView.addSubview(thumbnailImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(reorderIcon)
    }

    private func setupConstraints() {
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

    // MARK: - Configuration

    func configure(with place: VisitedPlace) {
        titleLabel.text = place.placeNameSnapshot

        if let thumbnailURL = place.thumbnailURLSnapshot, let url = URL(string: thumbnailURL) {
            thumbnailImageView.kf.setImage(
                with: url,
                placeholder: UIImage(systemName: "photo")
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
