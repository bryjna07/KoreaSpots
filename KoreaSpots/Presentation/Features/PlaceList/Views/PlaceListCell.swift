//
//  PlaceListCell.swift
//  KoreaSpots
//
//  Created by YoungJin on 10/08/25.
//

import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa
import SkeletonView

final class PlaceListCell: BaseCollectionViewCell, SkeletonableCell {

    var disposeBag = DisposeBag()

    private let thumbnail = UIImageView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let labelsStack = UIStackView()
    private let containerStack = UIStackView()
    let favoriteButton = UIButton()
    private let tagLabel = UILabel()

    // MARK: - ConfigureUI
    override func configureHierarchy() {
        contentView.addSubview(containerStack)

        labelsStack.addArrangedSubviews(tagLabel, titleLabel, subtitleLabel)
        containerStack.addArrangedSubviews(thumbnail, labelsStack, favoriteButton)
    }

    override func configureLayout() {
        containerStack.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(12).priority(.high)
            $0.leading.equalToSuperview().inset(12)
            $0.trailing.equalToSuperview().inset(12)
        }

        thumbnail.snp.makeConstraints {
            $0.width.equalTo(80)
            $0.height.equalTo(80).priority(.high)
        }

        favoriteButton.snp.makeConstraints {
            $0.width.height.equalTo(32)
        }

        tagLabel.snp.makeConstraints {
            $0.height.equalTo(20)
        }
    }

    override func configureView() {
        super.configureView()

        containerStack.do {
            $0.axis = .horizontal
            $0.spacing = 12
            $0.alignment = .center
            $0.distribution = .fill
            $0.backgroundColor = .white
            $0.layer.cornerRadius = Constants.UI.CornerRadius.medium
            $0.layer.shadowColor = UIColor.black.cgColor
            $0.layer.shadowOpacity = Constants.UI.Shadow.opacity
            $0.layer.shadowOffset = Constants.UI.Shadow.offset
            $0.layer.shadowRadius = Constants.UI.Shadow.radius
            $0.isSkeletonable = true
        }

        thumbnail.do {
            $0.contentMode = .scaleAspectFill
            $0.clipsToBounds = true
            $0.layer.cornerRadius = 8
            $0.backgroundColor = .secondBackGround
            $0.isSkeletonable = true
        }

        labelsStack.do {
            $0.axis = .vertical
            $0.spacing = 4
            $0.alignment = .leading
            $0.distribution = .fill
        }

        titleLabel.do {
            $0.font = .systemFont(ofSize: 16, weight: .semibold)
            $0.textColor = .textPrimary
            $0.numberOfLines = 2
            $0.isSkeletonable = true
        }

        subtitleLabel.do {
            $0.font = .systemFont(ofSize: 13, weight: .regular)
            $0.textColor = .textSecondary
            $0.numberOfLines = 1
            $0.isSkeletonable = true
        }

        favoriteButton.do {
            $0.setImage(UIImage(systemName: "heart"), for: .normal)
            $0.setImage(UIImage(systemName: "heart.fill"), for: .selected)
            $0.tintColor = .redPastel
            $0.backgroundColor = .clear
        }

        tagLabel.do {
            $0.font = .systemFont(ofSize: 11, weight: .medium)
            $0.textColor = .white
            $0.backgroundColor = .greenPastel.withAlphaComponent(0.8)
            $0.textAlignment = .center
            $0.layer.cornerRadius = 8
            $0.layer.masksToBounds = true
            $0.isHidden = true
        }
    }
    
    // MARK: - Configure
    func configure(with place: Place, showTag: Bool = false, isFavorite: Bool = false) {
        titleLabel.text = place.title
        subtitleLabel.text = place.address
        favoriteButton.isSelected = isFavorite

        // Load thumbnail image
        thumbnail.loadPlaceThumbnail(from: place.imageURL)

        // Configure tag
        if showTag {
            configureTag(for: place)
        } else {
            tagLabel.isHidden = true
        }
    }

    private func configureTag(for place: Place) {
        var tagText: String?

        // 1. Theme12 매핑 (cat3 기반)
        if let cat3 = place.cat3,
           let theme = Theme12.allCases.first(where: {
               $0.query.cat3Filters.map { $0.rawValue }.contains(cat3)
           }) {
            tagText = theme.displayName
        }
        // 2. ContentType 기반 (Theme12에 없는 경우)
        else {
            switch place.contentTypeId {
            case 14: tagText = "문화시설"
            case 15: tagText = "축제/행사"
            case 25: tagText = "여행코스"
            case 28: tagText = "레포츠"
            case 32: tagText = "숙박"
            case 38: tagText = "쇼핑"
            case 39: tagText = "음식점"
            default: break
            }
        }

        if let tag = tagText {
            tagLabel.text = " \(tag) "
            tagLabel.isHidden = false
        } else {
            tagLabel.isHidden = true
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        thumbnail.cancelImageLoad()
        thumbnail.image = nil
        titleLabel.text = nil
        subtitleLabel.text = nil
        tagLabel.isHidden = true
        favoriteButton.isSelected = false
        disposeBag = DisposeBag()
    }
}
