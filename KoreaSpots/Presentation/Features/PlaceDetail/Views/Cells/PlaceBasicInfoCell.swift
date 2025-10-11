//
//  PlaceBasicInfoCell.swift
//  KoreaSpots
//
//  Created by YoungJin on 9/29/25.
//

import UIKit
import SnapKit
import Then
import SkeletonView

final class PlaceBasicInfoCell: BaseCollectionViewCell {

    // MARK: - UI Components
    private let titleLabel = UILabel()
    /// TODO: - CustomUI
    private let categoryTagView = UIView()
    private let categoryLabel = UILabel()
    private let addressLabel = UILabel()
    private let phoneLabel = UILabel()

    // MARK: - Configuration
    func configure(with place: Place) {
        titleLabel.text = place.title
        addressLabel.text = place.address
        phoneLabel.text = place.tel ?? "전화번호 정보 없음"

        // ContentType에 따른 카테고리 표시
        let categoryText = getCategoryText(for: place.contentTypeId)
        categoryLabel.text = categoryText
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        addressLabel.text = nil
        phoneLabel.text = nil
        categoryLabel.text = nil
    }
}

// MARK: - ConfigureUI
extension PlaceBasicInfoCell {

    override func configureHierarchy() {
        contentView.addSubviews(
            titleLabel,
            categoryTagView,
            addressLabel,
            phoneLabel
        )

        categoryTagView.addSubview(categoryLabel)
    }

    override func configureLayout() {
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(Constants.Layout.mediumPadding)
            $0.leading.equalToSuperview().inset(Constants.Layout.standardPadding)
            $0.trailing.lessThanOrEqualTo(categoryTagView.snp.leading).offset(-Constants.Layout.smallPadding)
        }

        categoryTagView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(Constants.Layout.mediumPadding)
            $0.trailing.equalToSuperview().inset(Constants.Layout.standardPadding)
            $0.height.equalTo(28)
        }

        categoryLabel.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(Constants.Layout.smallPadding)
        }

        addressLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(Constants.Layout.smallPadding)
            $0.leading.trailing.equalToSuperview().inset(Constants.Layout.standardPadding)
        }

        phoneLabel.snp.makeConstraints {
            $0.top.equalTo(addressLabel.snp.bottom).offset(Constants.Layout.smallPadding)
            $0.leading.trailing.equalToSuperview().inset(Constants.Layout.standardPadding)
            $0.bottom.lessThanOrEqualToSuperview().inset(Constants.Layout.mediumPadding)
        }
    }

    override func configureView() {
        super.configureView()

        backgroundColor = .backGround
        isSkeletonable = true

        titleLabel.do {
            $0.font = FontManager.title1
            $0.textColor = .label
            $0.numberOfLines = 2
            $0.isSkeletonable = true
        }

        categoryTagView.do {
            $0.backgroundColor = .greenPastel
            $0.layer.cornerRadius = Constants.UI.CornerRadius.medium
            $0.isSkeletonable = true
        }

        categoryLabel.do {
            $0.font = FontManager.caption1
            $0.textColor = .white
            $0.textAlignment = .center
            $0.isSkeletonable = true
        }

        addressLabel.do {
            $0.font = FontManager.body
            $0.textColor = .secondaryLabel
            $0.numberOfLines = 2
            $0.isSkeletonable = true
        }

        phoneLabel.do {
            $0.font = FontManager.body
            $0.textColor = .secondaryLabel
            $0.isSkeletonable = true
        }
    }
}

// MARK: - Helper Methods
private extension PlaceBasicInfoCell {

    func getCategoryText(for contentTypeId: Int) -> String {
        switch contentTypeId {
        case 12: return "관광지"
        case 14: return "문화시설"
        case 15: return "축제/공연/행사"
        case 25: return "여행코스"
        case 28: return "레포츠"
        case 32: return "숙박"
        case 38: return "쇼핑"
        case 39: return "음식점"
        default: return "기타"
        }
    }
}
