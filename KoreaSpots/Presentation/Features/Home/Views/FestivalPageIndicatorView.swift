//
//  FestivalPageIndicatorView.swift
//  KoreaSpots
//
//  Created by YoungJin on 9/27/25.
//

import UIKit
import SnapKit
import Then

// MARK: - Festival Page Indicator (Custom Label View)
final class FestivalPageIndicatorView: BaseReusableView {

    private let label = UILabel()

    // MARK: - Override Methods
    override func configureHierarchy() {
        addSubview(label)
    }

    override func configureLayout() {
        label.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(Constants.UI.Spacing.medium)
            $0.top.equalToSuperview().offset(-16)
            $0.height.equalTo(Constants.UI.Label.pageIndicatorHeight)
            $0.width.greaterThanOrEqualTo(Constants.UI.Label.pageIndicatorMinWidth)
        }
    }

    override func configureView() {
        super.configureView()
        backgroundColor = .clear

        label.do {
            $0.textColor = .white
            $0.backgroundColor = UIColor.black.withAlphaComponent(Constants.UI.Alpha.secondary)
            $0.layer.cornerRadius = Constants.UI.CornerRadius.medium
            $0.clipsToBounds = true
            $0.textAlignment = .center
            $0.font = .systemFont(ofSize: 12, weight: .semibold)
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        // 재사용 시 숨김 상태를 명시적으로 리셋
        // configure에서 totalPages에 따라 다시 판단할 것
        isHidden = false
    }

    // MARK: - Public Methods
    func configure(currentPage: Int, totalPages: Int) {
        label.text = "\(currentPage)/\(totalPages)"
        isHidden = totalPages <= 1
    }
}
