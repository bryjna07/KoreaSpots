//
//  AttributionFooterView.swift
//  KoreaSpots
//
//  Created by YoungJin on 1/23/25.
//

import UIKit
import SnapKit
import Then

final class AttributionFooterView: BaseReusableView {
    
    // MARK: - UI Components
    private let divider = UIView()
    private let titleLabel = UILabel()
    private let contentLabel = UILabel()

    // MARK: - ConfigureUI
    override func configureHierarchy() {
        addSubviews(divider, titleLabel, contentLabel)
    }

    override func configureLayout() {
        divider.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.leading.trailing.equalToSuperview().inset(Constants.UI.Spacing.large)
            $0.height.equalTo(1)
        }

        titleLabel.snp.makeConstraints {
            $0.top.equalTo(divider.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview().inset(Constants.UI.Spacing.large)
        }

        contentLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(Constants.UI.Spacing.large)
            $0.bottom.equalToSuperview().inset(20)
        }
    }

    override func configureView() {
        super.configureView()

        backgroundColor = .backGround

        divider.do {
            $0.backgroundColor = .separator
        }

        titleLabel.do {
            $0.text = "출처"
            $0.font = FontManager.caption1
            $0.textColor = .textSecondary
            $0.textAlignment = .left
        }

        contentLabel.do {
            $0.numberOfLines = 0
            $0.font = FontManager.caption2
            $0.textColor = .textSecondary
            $0.textAlignment = .left

            let text = "ⓒ한국관광공사, TourAPI 4.0\n본 저작물은 광양시에서 2024년 작성하여 공공누리 제 1유형으로 개방한 '광양햇살체(작성자: 광양시)'를 이용하였습니다."

            // 줄 간격 설정
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 4
            paragraphStyle.alignment = .left

            let attributedString = NSMutableAttributedString(string: text)
            attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: text.count))

            $0.attributedText = attributedString
        }
    }
}
