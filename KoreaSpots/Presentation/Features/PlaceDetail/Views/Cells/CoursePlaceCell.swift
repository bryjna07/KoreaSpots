//
//  CoursePlaceCell.swift
//  KoreaSpots
//
//  Created by YoungJin on 10/28/25.
//

import UIKit
import SnapKit
import Then

final class CoursePlaceCell: BaseCollectionViewCell {

    // MARK: - UI Components
    private let containerView = UIView()
    private let courseImageView = UIImageView()
    private let courseNumberLabel = UILabel()
    private let titleLabel = UILabel()

    // MARK: - Configuration
    func configure(with courseDetail: CourseDetail, index: Int) {
        courseNumberLabel.text = "\(index)"
        titleLabel.text = courseDetail.subName ?? "코스 \(index)"

        // 코스 이미지 설정 (ImageLoader 사용, 썸네일 크기, 이미지 없으면 noImage 표시)
        courseImageView.loadPlaceThumbnailWithNoImagePlaceholder(from: courseDetail.subDetailImg)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        courseImageView.cancelImageLoad()
        courseImageView.image = nil
        courseNumberLabel.text = nil
        titleLabel.text = nil
    }
}

// MARK: - ConfigureUI
extension CoursePlaceCell {
    override func configureHierarchy() {
        contentView.addSubview(containerView)
        containerView.addSubviews(courseImageView, courseNumberLabel, titleLabel)
    }

    override func configureLayout() {
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        courseImageView.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(12)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(60)
        }

        courseNumberLabel.snp.makeConstraints {
            $0.leading.equalTo(courseImageView.snp.trailing).offset(12)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(32)
        }

        titleLabel.snp.makeConstraints {
            $0.leading.equalTo(courseNumberLabel.snp.trailing).offset(12)
            $0.trailing.equalToSuperview().inset(12)
            $0.centerY.equalToSuperview()
        }
    }

    override func configureView() {
        super.configureView()

        containerView.do {
            $0.backgroundColor = .white
            $0.layer.cornerRadius = Constants.UI.CornerRadius.medium
            $0.layer.shadowColor = UIColor.black.cgColor
            $0.layer.shadowOpacity = Constants.UI.Shadow.opacity
            $0.layer.shadowOffset = Constants.UI.Shadow.offset
            $0.layer.shadowRadius = Constants.UI.Shadow.radius
        }

        courseImageView.do {
            $0.contentMode = .scaleAspectFill
            $0.clipsToBounds = true
            $0.backgroundColor = .systemGray6
            $0.layer.cornerRadius = Constants.UI.CornerRadius.small
        }

        courseNumberLabel.do {
            $0.font = FontManager.title2
            $0.textColor = .primary
            $0.textAlignment = .center
            $0.backgroundColor = .primary.withAlphaComponent(0.1)
            $0.layer.cornerRadius = 16
            $0.clipsToBounds = true
        }

        titleLabel.do {
            $0.font = FontManager.title3
            $0.textColor = .textPrimary
            $0.numberOfLines = 2
        }
    }
}
