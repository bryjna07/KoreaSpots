//
//  TripDatesCell.swift
//  KoreaSpots
//
//  Created by YoungJin on 10/10/25.
//

import UIKit
import SnapKit
import Then

final class TripDatesCell: UICollectionViewCell {

    // MARK: - Properties

    var onStartDateChanged: ((Date) -> Void)?
    var onEndDateChanged: ((Date) -> Void)?

    // MARK: - UI Components

    private let startDatePicker = UIDatePicker().then {
        $0.datePickerMode = .date
        $0.preferredDatePickerStyle = .compact
    }

    private let endDatePicker = UIDatePicker().then {
        $0.datePickerMode = .date
        $0.preferredDatePickerStyle = .compact
    }

    private let separatorLabel = UILabel().then {
        $0.text = "~"
        $0.font = .systemFont(ofSize: 16, weight: .medium)
        $0.textAlignment = .center
    }

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
        setupActions()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setupViews() {
        contentView.addSubview(startDatePicker)
        contentView.addSubview(separatorLabel)
        contentView.addSubview(endDatePicker)
    }

    private func setupConstraints() {
        startDatePicker.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(8)
            $0.centerY.equalToSuperview()
        }

        separatorLabel.snp.makeConstraints {
            $0.leading.equalTo(startDatePicker.snp.trailing).offset(8)
            $0.centerY.equalToSuperview()
            $0.width.equalTo(20)
        }

        endDatePicker.snp.makeConstraints {
            $0.leading.equalTo(separatorLabel.snp.trailing).offset(8)
            $0.trailing.lessThanOrEqualToSuperview().inset(8)
            $0.centerY.equalToSuperview()
        }
    }

    private func setupActions() {
        startDatePicker.addTarget(self, action: #selector(startDateChanged), for: .valueChanged)
        endDatePicker.addTarget(self, action: #selector(endDateChanged), for: .valueChanged)
    }

    // MARK: - Configuration

    func configure(startDate: Date, endDate: Date) {
        startDatePicker.date = startDate
        endDatePicker.date = endDate
    }

    // MARK: - Actions

    @objc private func startDateChanged() {
        onStartDateChanged?(startDatePicker.date)
    }

    @objc private func endDateChanged() {
        onEndDateChanged?(endDatePicker.date)
    }
}
