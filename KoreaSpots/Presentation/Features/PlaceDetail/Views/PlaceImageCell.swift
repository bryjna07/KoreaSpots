//
//  PlaceImageCell.swift
//  KoreaSpots
//
//  Created by YoungJin on 10/09/25.
//

import UIKit
import SnapKit
import Then

final class PlaceImageCell: BaseCollectionViewCell {

    // MARK: - UI Components
    private let imageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
        $0.backgroundColor = .systemGray5
    }

    // MARK: - Configuration
    func configure(with imageURL: String?) {
        imageView.loadImage(
            from: imageURL,
            placeholder: UIImage(systemName: "photo"),
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
        contentView.layer.cornerRadius = Constants.UI.CornerRadius.medium
        contentView.layer.masksToBounds = true
    }
}
