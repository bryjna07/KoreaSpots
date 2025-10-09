//
//  CategorySectionHeader.swift
//  KoreaSpots
//
//  Created by Claude on 9/30/25.
//

import UIKit
import SnapKit
import Then

final class CategorySectionHeader: BaseReusableView {

    // MARK: - UI Components
    private let titleLabel = UILabel()
    private let moreButton = UIButton(type: .system)

    // MARK: - Properties
    var onMoreButtonTapped: (() -> Void)?

    // MARK: - ConfigureUI
    override func configureHierarchy() {
        addSubviews(titleLabel, moreButton)
    }

    override func configureLayout() {
        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(Constants.UI.Spacing.xLarge)
            $0.centerY.equalToSuperview()
        }

        moreButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-Constants.UI.Spacing.xLarge)
            $0.centerY.equalToSuperview()
        }
    }

    override func configureView() {
        super.configureView()

        titleLabel.do {
            $0.font = FontManager.Header.sectionTitle
            $0.textColor = .textPrimary
        }

        moreButton.do {
            $0.titleLabel?.font = FontManager.Header.actionButton
            $0.setTitleColor(.textSecondary, for: .normal)
            $0.addTarget(self, action: #selector(moreButtonTapped), for: .touchUpInside)
        }
    }

    // MARK: - Actions
    @objc private func moreButtonTapped() {
        onMoreButtonTapped?()
    }

    // MARK: - Configuration
    /// TODO: - 컬러 변경 필요
    func configure(cat2: Cat2, isExpanded: Bool, showMoreButton: Bool) {
        titleLabel.text = cat2.labelKo

        if showMoreButton {
            moreButton.isHidden = false
            let title = isExpanded ? "접기" : "더보기"
            let iconName = isExpanded ? "chevron.up" : "chevron.down"

            let config = UIImage.SymbolConfiguration(pointSize: 12, weight: .medium)
            let icon = UIImage(systemName: iconName, withConfiguration: config)

            moreButton.setTitle(" \(title)", for: .normal)
            moreButton.setImage(icon, for: .normal)
            moreButton.semanticContentAttribute = .forceRightToLeft
        } else {
            moreButton.isHidden = true
        }
    }

    // MARK: - Prepare for Reuse
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        moreButton.isHidden = false
        onMoreButtonTapped = nil
    }
}
