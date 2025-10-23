//
//  PlaceImageCell.swift
//  KoreaSpots
//
//  Created by YoungJin on 10/09/25.
//

import UIKit
import SnapKit
import Then
import SkeletonView

final class PlaceImageCell: BaseCollectionViewCell, SkeletonableCell {

    // MARK: - UI Components
    private let imageView = UIImageView()

    // MARK: - Configuration
    func configure(with imageURL: String?) {
        imageView.loadImage(
            from: imageURL,
            size: .detail,
            cachePolicy: .diskAndMemory
        )
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.cancelImageLoad()
        imageView.image = nil
    }

    // MARK: - ConfigureUI
    override func configureHierarchy() {
        super.configureHierarchy()
        contentView.addSubview(imageView)
    }

    override func configureLayout() {
        super.configureLayout()
        imageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    override func configureView() {
        super.configureView()

        contentView.do {
            $0.layer.cornerRadius = Constants.UI.CornerRadius.medium
            $0.layer.masksToBounds = true
            $0.isSkeletonable = true
        }

        imageView.do {
            $0.contentMode = .scaleAspectFill
            $0.clipsToBounds = true
            $0.backgroundColor = .systemGray5
            $0.isSkeletonable = true
        }
    }
}
