//
//  PlaceOperatingInfoCell.swift
//  KoreaSpots
//
//  Created by YoungJin on 9/29/25.
//

import UIKit
import SnapKit
import Then
import SkeletonView

final class PlaceOperatingInfoCell: BaseCollectionViewCell {

    // MARK: - UI Components
    private let containerView = UIView()
    private let stackView = UIStackView()

    // MARK: - Configuration
    func configure(with operatingInfo: OperatingInfo) {
        setupInfoRows(with: operatingInfo)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        clearStackView()
    }
}

// MARK: - ConfigureUI
extension PlaceOperatingInfoCell {

    override func configureHierarchy() {
        contentView.addSubview(containerView)
        containerView.addSubview(stackView)
    }

    override func configureLayout() {
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(Constants.Layout.standardPadding)
        }

        stackView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(Constants.Layout.standardPadding)
        }
    }

    override func configureView() {
        super.configureView()

        containerView.do {
            $0.backgroundColor = .backGround
            $0.layer.cornerRadius = Constants.UI.CornerRadius.medium
            $0.layer.borderWidth = 1
            $0.layer.borderColor = UIColor.systemGray4.cgColor
            $0.isSkeletonable = true
        }

        stackView.do {
            $0.axis = .vertical
            $0.spacing = Constants.Layout.smallPadding
            $0.distribution = .fill
            $0.alignment = .fill
        }
    }
}

// MARK: - Private Methods
private extension PlaceOperatingInfoCell {

    func clearStackView() {
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
    }

    func setupInfoRows(with operatingInfo: OperatingInfo) {
        clearStackView()

        if let useTime = operatingInfo.useTime, !useTime.isEmpty {
            let row = createInfoRow(title: "운영시간", content: useTime)
            stackView.addArrangedSubview(row)
        }

        if let restDate = operatingInfo.restDate, !restDate.isEmpty {
            let row = createInfoRow(title: "휴무일", content: restDate)
            stackView.addArrangedSubview(row)
        }

        if let useFee = operatingInfo.useFee, !useFee.isEmpty {
            let row = createInfoRow(title: "이용요금", content: useFee)
            stackView.addArrangedSubview(row)
        }

        if let homepage = operatingInfo.homepage, !homepage.isEmpty {
            let row = createInfoRow(title: "홈페이지", content: homepage)
            stackView.addArrangedSubview(row)
        }
    }

    func createInfoRow(title: String, content: String) -> UIView {
        let containerView = UIView()
        let titleLabel = UILabel()
        let contentLabel = UILabel()

        containerView.addSubviews(titleLabel, contentLabel)

        titleLabel.do {
            $0.text = title
            $0.font = FontManager.caption1
            $0.textColor = .secondaryLabel
            $0.setContentHuggingPriority(.required, for: .horizontal)
            $0.setContentCompressionResistancePriority(.required, for: .horizontal)
            $0.isSkeletonable = true
        }

        contentLabel.do {
            $0.text = content
            $0.font = FontManager.body
            $0.textColor = .label
            $0.numberOfLines = 0
            $0.isSkeletonable = true
        }

        titleLabel.snp.makeConstraints {
            $0.top.leading.equalToSuperview()
            $0.width.equalTo(80)
        }

        contentLabel.snp.makeConstraints {
            $0.top.trailing.bottom.equalToSuperview()
            $0.leading.equalTo(titleLabel.snp.trailing).offset(Constants.Layout.standardPadding)
        }

        return containerView
    }
}
