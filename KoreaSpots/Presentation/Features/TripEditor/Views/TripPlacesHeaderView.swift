//
//  TripPlacesHeaderView.swift
//  KoreaSpots
//
//  Created by YoungJin on 10/10/25.
//

import UIKit
import SnapKit
import Then
import RxSwift

final class TripPlacesHeaderView: BaseReusableView {

    // MARK: - Properties

    var onAddButtonTapped: (() -> Void)?

    // MARK: - UI Components

    private let titleLabel = UILabel()
    private let addButton = UIButton(type: .system)

    // MARK: - ConfigureUI

    override func configureHierarchy() {
        addSubview(titleLabel)
        addSubview(addButton)
    }

    override func configureLayout() {
        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(16)
            $0.centerY.equalToSuperview()
        }

        addButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(16)
            $0.centerY.equalToSuperview()
            $0.height.equalTo(32)
        }
    }

    override func configureView() {
        super.configureView()

        titleLabel.do {
            $0.text = "방문 장소"
            $0.font = .systemFont(ofSize: 18, weight: .bold)
        }

        addButton.do {
            $0.setTitle("+ 추가", for: .normal)
            $0.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
            $0.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
        }
    }

    // MARK: - Actions

    @objc private func addButtonTapped() {
        onAddButtonTapped?()
    }

    // MARK: - Reuse

    override func prepareForReuse() {
        super.prepareForReuse()
        onAddButtonTapped = nil
    }
}
