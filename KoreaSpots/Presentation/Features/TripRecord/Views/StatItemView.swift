//
//  StatItemView.swift
//  KoreaSpots
//
//  Created by YoungJin on 10/10/25.
//

import UIKit
import SnapKit
import Then

// MARK: - StatItemView

final class StatItemView: BaseView {

    private let iconImageView = UIImageView()
    private let titleLabel = UILabel()
    private let valueLabel = UILabel()
    private let stackView = UIStackView()

    func configure(icon: String, title: String, value: String) {
        iconImageView.image = UIImage(systemName: icon)
        titleLabel.text = title
        valueLabel.text = value
    }
}

extension StatItemView {
    override func configureHierarchy() {
        addSubview(stackView)
        stackView.addArrangedSubviews(iconImageView, titleLabel, valueLabel)
    }
    
    override func configureLayout() {
        stackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        iconImageView.snp.makeConstraints {
            $0.width.height.equalTo(24)
        }
    }
    
    override func configureView() {
        super.configureView()
        iconImageView.do {
            $0.contentMode = .scaleAspectFit
            $0.tintColor = .textPrimary
        }

        titleLabel.do {
            $0.font = FontManager.caption2
            $0.textColor = .secondaryLabel
            $0.textAlignment = .center
        }

        valueLabel.do {
            $0.font = FontManager.bodyBold
            $0.textColor = .label
            $0.textAlignment = .center
        }

        stackView.do {
            $0.axis = .vertical
            $0.spacing = 4
            $0.alignment = .center
        }
    }
}
