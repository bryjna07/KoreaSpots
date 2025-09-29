//
//  SectionHeaderView.swift
//  KoreaSpots
//
//  Created by YoungJin on 9/25/25.
//

import UIKit
import SnapKit
import Then

struct SectionHeaderModel {
    let title: String
    let actionTitle: String?

    init(title: String, actionTitle: String? = nil) {
        self.title = title
        self.actionTitle = actionTitle
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
        backgroundColor = .white

        stackView.do {
            $0.axis = .horizontal
            $0.alignment = .center
            $0.distribution = .equalSpacing
        }

        titleLabel.do {
            $0.font = FontManager.Header.sectionTitle
            $0.textColor = .label
        }

        actionButton.do {
            $0.titleLabel?.font = FontManager.Header.actionButton
            $0.setTitleColor(.systemBlue, for: .normal)
            $0.addTarget(self, action: #selector(actionButtonTapped), for: .touchUpInside)
        }
    }
}
