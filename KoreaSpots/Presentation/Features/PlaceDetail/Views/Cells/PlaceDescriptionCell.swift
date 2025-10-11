//
//  PlaceDescriptionCell.swift
//  KoreaSpots
//
//  Created by YoungJin on 9/29/25.
//

import UIKit
import SnapKit
import Then
import SkeletonView

final class PlaceDescriptionCell: BaseCollectionViewCell {

    // MARK: - UI Components
    private let containerView = UIView()
    private let descriptionLabel = UILabel()
    private let moreButton = UIButton(type: .system)

    // MARK: - Properties
    private var isExpanded = false
    private var fullText = ""
    var onToggleExpand: (() -> Void)?

    // MARK: - Configuration
    func configure(with description: String) {
        fullText = description
        updateDescription()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        fullText = ""
        isExpanded = false
        descriptionLabel.text = nil
        onToggleExpand = nil
    }

    @objc private func moreButtonTapped() {
        isExpanded.toggle()
        updateDescription()

        // 레이아웃 갱신 알림
        onToggleExpand?()
    }
}

// MARK: - ConfigureUI
extension PlaceDescriptionCell {

    override func configureHierarchy() {
        contentView.addSubview(containerView)
        containerView.addSubviews(
            descriptionLabel,
            moreButton
        )
    }

    override func configureLayout() {
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        descriptionLabel.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview().inset(Constants.Layout.standardPadding)
        }

        moreButton.snp.makeConstraints {
            $0.top.equalTo(descriptionLabel.snp.bottom).offset(Constants.Layout.smallPadding)
            $0.leading.equalToSuperview().inset(Constants.Layout.standardPadding)
            $0.trailing.lessThanOrEqualToSuperview().inset(Constants.Layout.standardPadding)
            $0.bottom.equalToSuperview().inset(Constants.Layout.standardPadding)
            $0.height.equalTo(Constants.UI.ButtonHeight.small)
        }
    }

    override func configureView() {
        super.configureView()

        containerView.do {
            $0.backgroundColor = .systemGray6
            $0.layer.cornerRadius = Constants.UI.CornerRadius.medium
            $0.isSkeletonable = true
        }

        descriptionLabel.do {
            $0.font = FontManager.body
            $0.textColor = .label
            $0.numberOfLines = 0
            $0.isSkeletonable = true
        }

        moreButton.do {
            $0.setTitleColor(.textSecondary, for: .normal)
            $0.titleLabel?.font = FontManager.caption1
            $0.contentHorizontalAlignment = .left
            $0.addTarget(self, action: #selector(moreButtonTapped), for: .touchUpInside)
        }
    }
}

// MARK: - Private Methods
private extension PlaceDescriptionCell {

    func updateDescription() {
        if isExpanded {
            descriptionLabel.text = fullText
            descriptionLabel.numberOfLines = 0
            moreButton.setTitle("접기 ∧", for: .normal)
        } else {
            // 3줄까지만 표시
            descriptionLabel.numberOfLines = 3
            descriptionLabel.text = fullText

            // 3줄을 넘는지 확인
            if needsMoreButton() {
                moreButton.setTitle("더보기 ∨", for: .normal)
                moreButton.isHidden = false
            } else {
                moreButton.isHidden = true
            }
        }
    }

    func needsMoreButton() -> Bool {
        guard !fullText.isEmpty else { return false }

        // 임시로 3줄 제한으로 높이 계산
        let maxSize = CGSize(
            width: frame.width - (Constants.Layout.standardPadding * 2),
            height: .greatestFiniteMagnitude
        )

        let fullTextHeight = fullText.boundingRect(
            with: maxSize,
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: [.font: FontManager.body ?? UIFont.systemFont(ofSize: 16)],
            context: nil
        ).height

        let threeLineHeight = (FontManager.body?.lineHeight ?? 16) * 3

        return fullTextHeight > threeLineHeight
    }
}

///TODO: - 카드셀 탭에서만 정보 표시되는중. - 해결 필요
