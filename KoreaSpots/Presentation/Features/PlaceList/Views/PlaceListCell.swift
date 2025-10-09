//
//  PlaceListCell.swift
//  KoreaSpots
//
//  Created by YoungJin on 10/08/25.
//

import UIKit
import SnapKit
import Then

final class PlaceListCell: BaseCollectionViewCell {

    private let thumbnail = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 8
        $0.backgroundColor = UIColor(white: 0.9, alpha: 1) // Placeholder background
    }

    private let titleLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 16, weight: .semibold)
        $0.textColor = .label
        $0.numberOfLines = 2
    }

    private let subtitleLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 13, weight: .regular)
        $0.textColor = .secondaryLabel
        $0.numberOfLines = 1
    }

    private let labelsStack = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 4
        $0.alignment = .leading
        $0.distribution = .fill
    }

    private let containerStack = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 12
        $0.alignment = .center
        $0.distribution = .fill
    }

    // MARK: - ConfigureUI
    override func configureHierarchy() {
        super.configureHierarchy()

        contentView.addSubview(containerStack)

        labelsStack.addArrangedSubview(titleLabel)
        labelsStack.addArrangedSubview(subtitleLabel)

        containerStack.addArrangedSubview(thumbnail)
        containerStack.addArrangedSubview(labelsStack)
    }

    override func configureLayout() {
        super.configureLayout()

        containerStack.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(12).priority(.high)
            $0.leading.trailing.equalToSuperview().inset(12)
        }

        thumbnail.snp.makeConstraints {
            $0.width.equalTo(80)
            $0.height.equalTo(80).priority(.high)
        }
    }

    override func configureView() {
        super.configureView()
        backgroundColor = .systemBackground
    }
    
    // MARK: - Configure
    func configure(with place: Place) {
        titleLabel.text = place.title
        subtitleLabel.text = place.address

        // Load thumbnail image
        thumbnail.loadPlaceThumbnail(from: place.imageURL)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        thumbnail.cancelImageLoad()
        thumbnail.image = nil
        titleLabel.text = nil
        subtitleLabel.text = nil
    }
}
