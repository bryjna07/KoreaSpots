//
//  SectionHeaderView.swift
//  KoreaSpots
//
//  Created by YoungJin on 9/25/25.
//

import UIKit
import SnapKit
import Then
import SkeletonView

struct SectionHeaderModel {
    let title: String
    let actionTitle: String?
    let titleFont: UIFont?

    init(title: String, actionTitle: String? = nil, titleFont: UIFont? = nil) {
        self.title = title
        self.actionTitle = actionTitle
        self.titleFont = titleFont
    }
}

final class SectionHeaderView: BaseReusableView, HeaderViewConfigurable {

    // MARK: - UI Components
    private let titleLabel = UILabel()
    private let actionButton = UIButton(type: .system)
    private let stackView = UIStackView()

    // MARK: - Properties
    var actionHandler: (() -> Void)?

    // MARK: - Actions
    @objc private func actionButtonTapped() {
        actionHandler?()
    }

    // MARK: - Configuration
    func configure(with model: SectionHeaderModel) {
        titleLabel.text = model.title

        // 폰트 커스터마이징 (지정되지 않으면 기본값 사용)
        if let customFont = model.titleFont {
            titleLabel.font = customFont
        } else {
            titleLabel.font = FontManager.Header.sectionTitle
        }

        if let actionTitle = model.actionTitle {
            actionButton.setTitle(actionTitle, for: .normal)
            actionButton.isHidden = false
        } else {
            actionButton.isHidden = true
        }
    }

    // Legacy method for backwards compatibility
    func configure(title: String, actionTitle: String? = nil) {
        configure(with: SectionHeaderModel(title: title, actionTitle: actionTitle))
    }

    // PlaceDetail용 간단한 설정 메서드 (폰트 커스터마이징 가능)
    func configure(with title: String?, font: UIFont? = nil) {
        titleLabel.text = title

        if let customFont = font {
            titleLabel.font = customFont
        } else {
            titleLabel.font = FontManager.title3
        }

        actionButton.isHidden = true
        isHidden = (title == nil)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        titleLabel.font = FontManager.Header.sectionTitle // 기본 폰트로 초기화
        actionButton.isHidden = true
        actionHandler = nil
        isHidden = false
    }

    override func configureHierarchy() {
        addSubview(stackView)
        stackView.addArrangedSubviews(
            titleLabel, actionButton
        )
    }
    
    override func configureLayout() {
        stackView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(Constants.UI.Spacing.xLarge)
            $0.top.equalToSuperview().inset(Constants.UI.Spacing.small)
            $0.bottom.equalToSuperview().inset(Constants.UI.Spacing.large)
        }
    }
    
    override func configureView() {
        super.configureView()
        isSkeletonable = true

        stackView.do {
            $0.axis = .horizontal
            $0.alignment = .center
            $0.distribution = .equalSpacing
        }

        titleLabel.do {
            $0.font = FontManager.Header.sectionTitle
            $0.textColor = .label
            $0.isSkeletonable = true
        }

        actionButton.do {
            $0.titleLabel?.font = FontManager.Header.actionButton
            $0.setTitleColor(.textSecondary, for: .normal)
            $0.addTarget(self, action: #selector(actionButtonTapped), for: .touchUpInside)
        }
    }
}
