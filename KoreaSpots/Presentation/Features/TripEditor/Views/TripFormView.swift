//
//  TripFormView.swift
//  KoreaSpots
//
//  Created by YoungJin on 10/10/25.
//

import UIKit
import SnapKit
import Then

final class TripFormView: BaseView {

    // MARK: - Callbacks

    var onTitleChanged: ((String) -> Void)?
    var onStartDateChanged: ((Date) -> Void)?
    var onEndDateChanged: ((Date) -> Void)?
    var onMemoChanged: ((String) -> Void)?

    // MARK: - UI Components

    private let contentView = UIView()

    // Title Section
    private let titleLabel = UILabel()
    let titleTextField = UITextField()

    // Dates Section
    private let datesLabel = UILabel()
    private let datesStackView = UIStackView()
    private let startDateLabel = UILabel()
    let startDatePicker = UIDatePicker()
    private let endDateLabel = UILabel()
    let endDatePicker = UIDatePicker()

    // Memo Section
    private let memoLabel = UILabel()
    let memoTextView = UITextView()

    // MARK: - ConfigureUI

    override func configureHierarchy() {
        addSubview(contentView)

        contentView.addSubview(titleLabel)
        contentView.addSubview(titleTextField)
        contentView.addSubview(datesLabel)
        contentView.addSubview(datesStackView)
        contentView.addSubview(memoLabel)
        contentView.addSubview(memoTextView)

        setupDatesStack()
    }

    override func configureLayout() {
        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        // Title Section
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.leading.trailing.equalToSuperview().inset(16)
        }

        titleTextField.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(44)
        }

        // Dates Section
        datesLabel.snp.makeConstraints {
            $0.top.equalTo(titleTextField.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(16)
        }

        datesStackView.snp.makeConstraints {
            $0.top.equalTo(datesLabel.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(16)
        }

        // Memo Section
        memoLabel.snp.makeConstraints {
            $0.top.equalTo(datesStackView.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(16)
        }

        memoTextView.snp.makeConstraints {
            $0.top.equalTo(memoLabel.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.bottom.equalToSuperview().offset(-16)
            $0.height.equalTo(120)
        }
    }

    override func configureView() {
        super.configureView()

        // Title
        titleLabel.do {
            $0.text = "제목"
            $0.font = .systemFont(ofSize: 14, weight: .semibold)
            $0.textColor = .secondaryLabel
        }

        titleTextField.do {
            $0.placeholder = "여행 제목을 입력하세요"
            $0.font = .systemFont(ofSize: 18, weight: .semibold)
            $0.borderStyle = .roundedRect
            $0.clearButtonMode = .whileEditing
            $0.returnKeyType = .done
        }

        // Dates
        datesLabel.do {
            $0.text = "날짜"
            $0.font = .systemFont(ofSize: 14, weight: .semibold)
            $0.textColor = .secondaryLabel
        }

        datesStackView.do {
            $0.axis = .vertical
            $0.spacing = 12
            $0.distribution = .fill
        }

        startDateLabel.do {
            $0.text = "시작일"
            $0.font = .systemFont(ofSize: 15, weight: .medium)
            $0.textColor = .label
        }

        startDatePicker.do {
            $0.datePickerMode = .date
            $0.preferredDatePickerStyle = .compact
        }

        endDateLabel.do {
            $0.text = "종료일"
            $0.font = .systemFont(ofSize: 15, weight: .medium)
            $0.textColor = .label
        }

        endDatePicker.do {
            $0.datePickerMode = .date
            $0.preferredDatePickerStyle = .compact
        }

        // Memo
        memoLabel.do {
            $0.text = "메모"
            $0.font = .systemFont(ofSize: 14, weight: .semibold)
            $0.textColor = .secondaryLabel
        }

        memoTextView.do {
            $0.font = .systemFont(ofSize: 16, weight: .regular)
            $0.layer.borderWidth = 1
            $0.layer.borderColor = UIColor.separator.cgColor
            $0.layer.cornerRadius = 8
            $0.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        }

        setupBindings()
    }

    // MARK: - Private Methods

    private func setupDatesStack() {
        // Start date container
        let startDateContainer = UIView()
        startDateContainer.addSubview(startDateLabel)
        startDateContainer.addSubview(startDatePicker)

        startDateLabel.snp.makeConstraints {
            $0.leading.top.bottom.equalToSuperview()
            $0.width.equalTo(60)
        }

        startDatePicker.snp.makeConstraints {
            $0.leading.equalTo(startDateLabel.snp.trailing).offset(12)
            $0.trailing.top.bottom.equalToSuperview()
            $0.height.equalTo(36)
        }

        // End date container
        let endDateContainer = UIView()
        endDateContainer.addSubview(endDateLabel)
        endDateContainer.addSubview(endDatePicker)

        endDateLabel.snp.makeConstraints {
            $0.leading.top.bottom.equalToSuperview()
            $0.width.equalTo(60)
        }

        endDatePicker.snp.makeConstraints {
            $0.leading.equalTo(endDateLabel.snp.trailing).offset(12)
            $0.trailing.top.bottom.equalToSuperview()
            $0.height.equalTo(36)
        }

        datesStackView.addArrangedSubview(startDateContainer)
        datesStackView.addArrangedSubview(endDateContainer)
    }

    private func setupBindings() {
        titleTextField.addTarget(self, action: #selector(titleTextFieldChanged), for: .editingChanged)
        titleTextField.addTarget(self, action: #selector(titleTextFieldDone), for: .editingDidEndOnExit)
        startDatePicker.addTarget(self, action: #selector(startDatePickerChanged), for: .valueChanged)
        endDatePicker.addTarget(self, action: #selector(endDatePickerChanged), for: .valueChanged)
        memoTextView.delegate = self
    }

    // MARK: - Actions

    @objc private func titleTextFieldChanged() {
        onTitleChanged?(titleTextField.text ?? "")
    }

    @objc private func titleTextFieldDone() {
        titleTextField.resignFirstResponder()
    }

    @objc private func startDatePickerChanged() {
        onStartDateChanged?(startDatePicker.date)
    }

    @objc private func endDatePickerChanged() {
        onEndDateChanged?(endDatePicker.date)
    }

    // MARK: - Public Methods

    func configure(title: String, startDate: Date, endDate: Date, memo: String) {
        titleTextField.text = title
        startDatePicker.date = startDate
        endDatePicker.date = endDate
        memoTextView.text = memo
    }
}

// MARK: - UITextViewDelegate

extension TripFormView: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        onMemoChanged?(textView.text)
    }
}
