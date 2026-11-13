//
//  FestivalInfoRowCell.swift
//  KoreaSpots
//
//  Created by YoungJin on 11/13/26.
//

import UIKit
import SnapKit
import Then

/// 축제 정보 한 줄 카드 (아이콘 + 제목 + 내용). 탭 가능한 행은 우측에 화살표 표시
final class FestivalInfoRowCell: BaseCollectionViewCell {

    // MARK: - UI Components
    private let cardView = UIView()
    private let iconContainer = UIView()
    private let iconView = UIImageView()
    private let titleLabel = UILabel()
    private let contentLabel = UILabel()
    private let accessoryView = UIImageView()

    // MARK: - Configuration
    func configure(with row: FestivalInfoRow) {
        iconView.image = UIImage(systemName: row.symbol)
        titleLabel.text = row.title
        contentLabel.text = row.content

        // 탭 가능한 행: 전화 / 링크 아이콘으로 동작을 암시
        switch row.action {
        case .call:
            accessoryView.image = UIImage(systemName: "phone.arrow.up.right")
            accessoryView.isHidden = false
        case .openURL:
            accessoryView.image = UIImage(systemName: "arrow.up.right.square")
            accessoryView.isHidden = false
        case nil:
            accessoryView.isHidden = true
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        contentLabel.text = nil
        iconView.image = nil
    }
}

// MARK: - ConfigureUI
extension FestivalInfoRowCell {

    override func configureHierarchy() {
        iconContainer.addSubview(iconView)
        cardView.addSubviews(iconContainer, titleLabel, contentLabel, accessoryView)
        contentView.addSubview(cardView)
    }

    override func configureLayout() {
        // 셀 간 간격은 카드 상하 인셋으로 처리
        cardView.snp.makeConstraints {
            $0.verticalEdges.equalToSuperview().inset(Constants.Layout.smallPadding / 2)
            $0.horizontalEdges.equalToSuperview()
        }

        iconContainer.snp.makeConstraints {
            $0.top.leading.equalToSuperview().inset(Constants.Layout.mediumPadding)
            $0.size.equalTo(36)
        }

        iconView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.size.equalTo(18)
        }

        accessoryView.snp.makeConstraints {
            $0.centerY.equalTo(iconContainer)
            $0.trailing.equalToSuperview().inset(Constants.Layout.mediumPadding)
            $0.size.equalTo(20)
        }

        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(Constants.Layout.mediumPadding)
            $0.leading.equalTo(iconContainer.snp.trailing).offset(Constants.Layout.mediumPadding)
            $0.trailing.equalTo(accessoryView.snp.leading).offset(-Constants.Layout.smallPadding)
        }

        contentLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(2)
            $0.leading.equalTo(titleLabel)
            $0.trailing.equalToSuperview().inset(Constants.Layout.mediumPadding)
            $0.bottom.equalToSuperview().inset(Constants.Layout.mediumPadding)
        }
    }

    override func configureView() {
        super.configureView()

        cardView.do {
            $0.backgroundColor = .backGround
            $0.layer.cornerRadius = Constants.UI.CornerRadius.medium
            $0.layer.borderWidth = 1
            $0.layer.borderColor = UIColor.systemGray5.cgColor
        }

        iconContainer.do {
            $0.backgroundColor = UIColor.greenPastel.withAlphaComponent(0.15)
            $0.layer.cornerRadius = 18
        }

        iconView.do {
            $0.tintColor = .greenPastel
            $0.contentMode = .scaleAspectFit
        }

        titleLabel.do {
            $0.font = FontManager.caption1
            $0.textColor = .secondaryLabel
        }

        contentLabel.do {
            $0.font = FontManager.body
            $0.textColor = .label
            $0.numberOfLines = 0
        }

        accessoryView.do {
            $0.tintColor = .greenPastel
            $0.contentMode = .scaleAspectFit
        }
    }
}
