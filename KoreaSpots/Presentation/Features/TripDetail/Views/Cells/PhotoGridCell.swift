//
//  PhotoGridCell.swift
//  KoreaSpots
//
//  Created by Watson22_YJ on 11/16/25.
//

import UIKit
import SnapKit
import Then

final class PhotoGridCell: BaseCollectionViewCell {

    // MARK: - UI Components

    private let imageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
        $0.backgroundColor = .systemGray6
    }

    private let coverBadge = UIView().then {
        $0.backgroundColor = UIColor.primary
        $0.layer.cornerRadius = 10
        $0.isHidden = true
    }

    private let coverLabel = UILabel().then {
        $0.text = "대표"
        $0.font = FontManager.caption1
        $0.textColor = .white
        $0.textAlignment = .center
    }

    // MARK: - Setup

    override func configureHierarchy() {
        contentView.addSubviews(imageView, coverBadge)
        coverBadge.addSubview(coverLabel)
    }

    override func configureLayout() {
        imageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        coverBadge.snp.makeConstraints {
            $0.top.leading.equalToSuperview().inset(4)
            $0.height.equalTo(20)
            $0.width.equalTo(36)
        }

        coverLabel.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    override func configureView() {
        super.configureView()
        backgroundColor = .clear
    }

    // MARK: - Configuration

    func configure(with photo: TripPhoto) {
        loadLocalImage(path: photo.localPath)
        coverBadge.isHidden = !photo.isCover
    }

    private func loadLocalImage(path: String) {
        // Handle both absolute and relative paths
        let fileURL: URL
        if path.hasPrefix("/") {
            fileURL = URL(fileURLWithPath: path)
        } else {
            // Assume it's in Documents directory
            let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            fileURL = documentsPath.appendingPathComponent(path)
        }

        if let imageData = try? Data(contentsOf: fileURL),
           let image = UIImage(data: imageData) {
            imageView.image = image
        } else {
            imageView.image = UIImage(systemName: "photo")
            imageView.tintColor = .tertiaryLabel
        }
    }

    // MARK: - Reuse

    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        coverBadge.isHidden = true
    }
}
