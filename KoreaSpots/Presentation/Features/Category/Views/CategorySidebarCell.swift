//
//  CategorySidebarCell.swift
//  KoreaSpots
//
//  Created by YoungJin on 9/30/25.
//

import UIKit
import SnapKit
import Then

final class CategorySidebarCell: UICollectionViewListCell {

    // MARK: - UI Components
    private let titleLabel = UILabel()
    private let highlightBar = UIView()

    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureHierarchy()
        configureLayout()
        configureView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - ConfigureUI
    private func configureHierarchy() {
        contentView.addSubviews(titleLabel, highlightBar)
    }

    private func configureLayout() {
        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(Constants.UI.Spacing.small)
            $0.trailing.equalToSuperview().offset(-Constants.UI.Spacing.medium)
            $0.centerY.equalToSuperview()
        }

        highlightBar.snp.makeConstraints {
            $0.trailing.equalToSuperview()
            $0.centerY.equalToSuperview()
            $0.width.equalTo(4)
            $0.height.equalTo(24)
        }
    }

    private func configureView() {
        
        automaticallyUpdatesBackgroundConfiguration = false
        backgroundConfiguration = UIBackgroundConfiguration.clear()
        
        titleLabel.do {
            $0.textAlignment = .center
            $0.font = FontManager.body
            $0.textColor = .label
            $0.numberOfLines = 0
        }

        highlightBar.do {
            $0.backgroundColor = .textSecondary
            $0.layer.cornerRadius = Constants.UI.CornerRadius.xSmall
            $0.isHidden = true
        }
    }

    // MARK: - Configuration
    func configure(cat2: Cat2, isHighlighted: Bool) {
        titleLabel.text = cat2.labelKo
        titleLabel.font = isHighlighted ? FontManager.caption2Bold : FontManager.caption2
        titleLabel.textColor = isHighlighted ? .textSecondary : .textPrimary
        highlightBar.isHidden = !isHighlighted
        backgroundColor = isHighlighted ? UIColor.textPrimary.withAlphaComponent(0.08) : .clear
    }

    // MARK: - Prepare for Reuse
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        titleLabel.font = FontManager.body
        titleLabel.textColor = .label
        highlightBar.isHidden = true
        backgroundColor = .clear
    }
}
