//
//  TripCalendarView.swift
//  KoreaSpots
//
//  Created by YoungJin on 10/10/25.
//

import UIKit
import SnapKit
import Then
import FSCalendar

final class TripCalendarView: BaseView {

    // MARK: - UI Components

    let monthHeaderView = UIView()
    let previousMonthButton = UIButton(type: .system)
    let monthLabel = UILabel()
    let nextMonthButton = UIButton(type: .system)
    let yearDropdownContainerView = UIView()
    let yearTableView = UITableView()
    let calendar = FSCalendar()

    // MARK: - Properties

    var currentMonth: Date = Date()
    var isYearDropdownVisible: Bool = false

    // MARK: - Configuration

    override func configureHierarchy() {
        addSubviews(monthHeaderView, yearDropdownContainerView, calendar)
        monthHeaderView.addSubviews(previousMonthButton, monthLabel, nextMonthButton)
        yearDropdownContainerView.addSubview(yearTableView)
    }

    override func configureLayout() {
        monthHeaderView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(16)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.height.equalTo(40)
        }

        previousMonthButton.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(40)
        }

        monthLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }

        nextMonthButton.snp.makeConstraints {
            $0.trailing.equalToSuperview()
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(40)
        }

        yearDropdownContainerView.snp.makeConstraints {
            $0.top.equalTo(monthHeaderView.snp.bottom).offset(4)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.height.equalTo(0)
        }

        yearTableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        calendar.snp.makeConstraints {
            $0.top.equalTo(yearDropdownContainerView.snp.bottom).offset(4)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(540)
            $0.bottom.equalToSuperview().inset(16).priority(.high)
        }
    }

    override func configureView() {
        super.configureView()

        backgroundColor = .white
        layer.cornerRadius = Constants.UI.CornerRadius.medium
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = Constants.UI.Shadow.opacity
        layer.shadowOffset = Constants.UI.Shadow.offset
        layer.shadowRadius = Constants.UI.Shadow.radius

        monthHeaderView.do {
            $0.backgroundColor = .clear
        }

        previousMonthButton.do {
            $0.setImage(UIImage(systemName: "chevron.left"), for: .normal)
            $0.tintColor = .label
        }

        monthLabel.do {
            $0.font = FontManager.title3
            $0.textColor = .label
            $0.textAlignment = .center
            $0.isUserInteractionEnabled = true
            updateMonthLabel(for: Date())
        }

        nextMonthButton.do {
            $0.setImage(UIImage(systemName: "chevron.right"), for: .normal)
            $0.tintColor = .label
        }

        yearDropdownContainerView.do {
            $0.backgroundColor = .white
            $0.layer.cornerRadius = Constants.UI.CornerRadius.small
            $0.layer.borderWidth = 1
            $0.layer.borderColor = UIColor.systemGray4.cgColor
            $0.clipsToBounds = true
            $0.isHidden = true
        }

        yearTableView.do {
            $0.backgroundColor = .white
            $0.separatorStyle = .singleLine
            $0.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
            $0.rowHeight = 44
            $0.showsVerticalScrollIndicator = false
            $0.isScrollEnabled = true
            $0.register(UITableViewCell.self, forCellReuseIdentifier: "YearCell")
        }

        calendar.do {
            $0.backgroundColor = .clear
            $0.appearance.headerTitleColor = .clear
            $0.appearance.headerMinimumDissolvedAlpha = 1.0
            $0.headerHeight = 0
            $0.rowHeight = 90
            $0.appearance.weekdayTextColor = .secondaryLabel
            $0.appearance.titleDefaultColor = .label
            $0.appearance.titleWeekendColor = .systemRed
            // 선택 관련 색상 제거
            $0.appearance.selectionColor = .clear
            $0.appearance.titleSelectionColor = .label  // 선택된 날짜 텍스트도 기본 색상 유지
            $0.appearance.todayColor = .clear
            $0.appearance.todaySelectionColor = .clear
            $0.appearance.titleTodayColor = .bluePastel
            $0.appearance.subtitleDefaultColor = .secondaryLabel
            $0.appearance.subtitleTodayColor = .secondaryLabel
            $0.appearance.subtitleSelectionColor = .secondaryLabel
            $0.appearance.subtitleOffset = CGPoint(x: 0, y: 4)
            $0.appearance.titleOffset = CGPoint(x: 0, y: -2)
            $0.appearance.borderRadius = 0.3
            $0.appearance.borderDefaultColor = .clear
            $0.appearance.borderSelectionColor = .clear  // 선택 시 테두리도 제거
            $0.appearance.caseOptions = [.weekdayUsesUpperCase]
            $0.locale = Locale(identifier: "ko_KR")
            $0.scrollEnabled = false
            $0.scope = .month
            $0.placeholderType = .none
            $0.adjustsBoundingRectWhenChangingMonths = true
            $0.allowsSelection = false  // 날짜 선택 비활성화
        }
    }

    // MARK: - Public Methods

    func updateMonthLabel(for date: Date) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 M월"
        formatter.locale = Locale(identifier: "ko_KR")
        monthLabel.text = formatter.string(from: date)
        currentMonth = date
    }

    func moveCalendar(to date: Date) {
        calendar.setCurrentPage(date, animated: true)
        updateMonthLabel(for: date)
    }

    func toggleYearDropdown() {
        isYearDropdownVisible.toggle()

        UIView.animate(withDuration: 0.3, animations: {
            self.yearDropdownContainerView.isHidden = !self.isYearDropdownVisible
            self.yearDropdownContainerView.snp.updateConstraints {
                $0.height.equalTo(self.isYearDropdownVisible ? 200 : 0)
            }
            self.layoutIfNeeded()
        })
    }

    func hideYearDropdown() {
        guard isYearDropdownVisible else { return }
        isYearDropdownVisible = false

        UIView.animate(withDuration: 0.3, animations: {
            self.yearDropdownContainerView.isHidden = true
            self.yearDropdownContainerView.snp.updateConstraints {
                $0.height.equalTo(0)
            }
            self.layoutIfNeeded()
        })
    }
}
