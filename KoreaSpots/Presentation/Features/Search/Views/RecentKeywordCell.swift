//
//  RecentKeywordCell.swift
//  KoreaSpots
//
//  Created by YoungJin on 10/09/25.
//

import UIKit
import SnapKit
import Then

final class RecentKeywordCell: BaseCollectionViewCell {

    // MARK: - UI Components

    private let containerView = UIView()
    private let keywordLabel = UILabel()
    let deleteButton = UIButton(type: .system)

    var onDeleteTapped: (() -> Void)?

    // MARK: - Configuration

    func configure(with keyword: String) {
        keywordLabel.text = keyword
    }

    // MARK: - Actions

    @objc private func deleteButtonTapped() {
        onDeleteTapped?()
    }

    // MARK: - Size Calculation

    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        setNeedsLayout()
        layoutIfNeeded()

        // Calculate width based on content
        let labelSize = keywordLabel.intrinsicContentSize
        let deleteButtonWidth: CGFloat = 20
        let horizontalPadding: CGFloat = 12 + 4 + 8 // leading + spacing + trailing
        let verticalPadding: CGFloat = 6 + 6 // top + bottom
        let calculatedWidth = labelSize.width + deleteButtonWidth + horizontalPadding
        let calculatedHeight = labelSize.height + verticalPadding

        var frame = layoutAttributes.frame
        frame.size.width = calculatedWidth
        frame.size.height = calculatedHeight
        layoutAttributes.frame = frame

        return layoutAttributes
    }
}

extension RecentKeywordCell {
    override func configureHierarchy() {
        contentView.addSubview(containerView)
        containerView.addSubviews(keywordLabel, deleteButton)
    }
    
    override func configureLayout() {
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        keywordLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(12)
            $0.top.bottom.equalToSuperview().inset(6)
            $0.trailing.equalTo(deleteButton.snp.leading).offset(-4)
        }

        deleteButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-8)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(20)
        }
    }
    
    override func configureView() {
        super.configureView()

        containerView.do {
            $0.backgroundColor = .secondBackGround
            $0.layer.cornerRadius = 16
            $0.layer.masksToBounds = true
        }

        keywordLabel.do {
            $0.font = .systemFont(ofSize: 14, weight: .medium)
            $0.textColor = .label
            $0.numberOfLines = 1
        }

        deleteButton.do {
            $0.setImage(UIImage(systemName: "xmark"), for: .normal)
            $0.tintColor = .secondaryLabel
            $0.contentMode = .center
            $0.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
        }
    }
}
