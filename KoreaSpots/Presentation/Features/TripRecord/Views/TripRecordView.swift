//
//  TripRecordView.swift
//  KoreaSpots
//
//  Created by YoungJin on 10/10/25.
//

import UIKit
import SnapKit
import Then
import FSCalendar

final class TripRecordView: BaseView {

    // MARK: - UI Components

    let statisticsHeaderView = TripStatisticsHeaderView()

    // Segment control
    let segmentedControl = UISegmentedControl(
        items: TripRecordSegment.allCases.map { $0.title }
    ).then {
        $0.selectedSegmentIndex = 0
    }

    // Container for switching views
    let containerView = UIView()

    // MARK: - List View Components

    // List header (전체 n개 + 필터)
    let listHeaderView = UIView()

    let totalCountLabel = UILabel().then {
        $0.font = FontManager.bodyBold
        $0.textColor = .textPrimary
    }

    let filterButton = UIButton(configuration: .plain()).then {
        var config = UIButton.Configuration.plain()
        config.title = "전체보기"
        config.image = UIImage(systemName: "chevron.down")
        config.imagePlacement = .trailing
        config.imagePadding = 4
        config.baseForegroundColor = .textSecondary
        var titleAttr = AttributeContainer()
        titleAttr.font = FontManager.body
        config.attributedTitle = AttributedString("전체보기", attributes: titleAttr)
        $0.configuration = config
    }

    // Filter dropdown
    let filterDropdownView = UIView().then {
        $0.backgroundColor = .backGround
        $0.layer.cornerRadius = 8
        $0.layer.shadowColor = UIColor.black.cgColor
        $0.layer.shadowOpacity = 0.15
        $0.layer.shadowOffset = CGSize(width: 0, height: 2)
        $0.layer.shadowRadius = 8
        $0.isHidden = true
    }

    let filterStackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 0
    }

    // Year/Month selector (연도별, 월별 선택 시 표시)
    let yearMonthSelectorView = UIView().then {
        $0.backgroundColor = .secondBackGround
        $0.isHidden = true
    }

    let yearPickerButton = UIButton(configuration: .plain()).then {
        var config = UIButton.Configuration.plain()
        config.title = "2025년"
        config.image = UIImage(systemName: "chevron.down")
        config.imagePlacement = .trailing
        config.imagePadding = 4
        config.baseForegroundColor = .textPrimary
        var titleAttr = AttributeContainer()
        titleAttr.font = FontManager.body
        config.attributedTitle = AttributedString("2025년", attributes: titleAttr)
        $0.configuration = config
    }

    let monthPickerButton = UIButton(configuration: .plain()).then {
        var config = UIButton.Configuration.plain()
        config.title = "1월"
        config.image = UIImage(systemName: "chevron.down")
        config.imagePlacement = .trailing
        config.imagePadding = 4
        config.baseForegroundColor = .textPrimary
        var titleAttr = AttributeContainer()
        titleAttr.font = FontManager.body
        config.attributedTitle = AttributedString("1월", attributes: titleAttr)
        $0.configuration = config
        $0.isHidden = true
    }

    // Year dropdown
    let yearDropdownView = UIView().then {
        $0.backgroundColor = .backGround
        $0.layer.cornerRadius = 8
        $0.layer.shadowColor = UIColor.black.cgColor
        $0.layer.shadowOpacity = 0.15
        $0.layer.shadowOffset = CGSize(width: 0, height: 2)
        $0.layer.shadowRadius = 8
        $0.isHidden = true
    }

    let yearTableView = UITableView().then {
        $0.register(UITableViewCell.self, forCellReuseIdentifier: "YearCell")
        $0.separatorStyle = .none
        $0.layer.cornerRadius = 8
        $0.isScrollEnabled = true
    }

    // Month dropdown
    let monthDropdownView = UIView().then {
        $0.backgroundColor = .backGround
        $0.layer.cornerRadius = 8
        $0.layer.shadowColor = UIColor.black.cgColor
        $0.layer.shadowOpacity = 0.15
        $0.layer.shadowOffset = CGSize(width: 0, height: 2)
        $0.layer.shadowRadius = 8
        $0.isHidden = true
    }

    let monthTableView = UITableView().then {
        $0.register(UITableViewCell.self, forCellReuseIdentifier: "MonthCell")
        $0.separatorStyle = .none
        $0.layer.cornerRadius = 8
        $0.isScrollEnabled = true
    }

    // List view (for infinite scroll)
    let listView = TripListView()

    // MARK: - Calendar View Components

    let calendarContainerView = UIView()
    let calendarScrollView = UIScrollView()
    let calendarContentView = UIView()
    let calendarView = TripCalendarView()

    // MARK: - Properties

    var trips: [Trip] = []

    var currentFilterMode: ListFilterMode = .all {
        didSet {
            updateFilterUI()
        }
    }

    var selectedYear: Int = Calendar.current.component(.year, from: Date()) {
        didSet {
            updateYearMonthButtons()
        }
    }

    var selectedMonth: Int = Calendar.current.component(.month, from: Date()) {
        didSet {
            updateYearMonthButtons()
        }
    }

    var currentSegment: TripRecordSegment = .list {
        didSet {
            updateVisibleView()
        }
    }

    // Callbacks
    var onFilterModeChanged: ((ListFilterMode) -> Void)?
    var onYearSelected: ((Int) -> Void)?
    var onMonthSelected: ((Int) -> Void)?
}

// MARK: - Hierarchy & Layout

extension TripRecordView {
    override func configureHierarchy() {
        addSubviews(statisticsHeaderView, segmentedControl, containerView)

        // List container
        containerView.addSubviews(
            listHeaderView,
            yearMonthSelectorView,
            listView,
            calendarContainerView,
            filterDropdownView,
            yearDropdownView,
            monthDropdownView
        )

        listHeaderView.addSubviews(totalCountLabel, filterButton)
        yearMonthSelectorView.addSubviews(yearPickerButton, monthPickerButton)

        filterDropdownView.addSubview(filterStackView)
        yearDropdownView.addSubview(yearTableView)
        monthDropdownView.addSubview(monthTableView)

        // Calendar container (달력만)
        calendarContainerView.addSubview(calendarScrollView)
        calendarScrollView.addSubview(calendarContentView)
        calendarContentView.addSubview(calendarView)

        // Setup filter buttons
        setupFilterButtons()
    }

    override func configureLayout() {
        statisticsHeaderView.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(150)
        }

        segmentedControl.snp.makeConstraints {
            $0.top.equalTo(statisticsHeaderView.snp.bottom).offset(12)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(32)
        }

        containerView.snp.makeConstraints {
            $0.top.equalTo(segmentedControl.snp.bottom).offset(12)
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalTo(safeAreaLayoutGuide)
        }

        // List header
        listHeaderView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(44)
        }

        totalCountLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.centerY.equalToSuperview()
        }

        filterButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-16)
            $0.centerY.equalToSuperview()
        }

        // Year/Month selector
        yearMonthSelectorView.snp.makeConstraints {
            $0.top.equalTo(listHeaderView.snp.bottom)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(0)
        }

        yearPickerButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.centerY.equalToSuperview()
        }

        monthPickerButton.snp.makeConstraints {
            $0.leading.equalTo(yearPickerButton.snp.trailing).offset(16)
            $0.centerY.equalToSuperview()
        }

        // List view
        listView.snp.makeConstraints {
            $0.top.equalTo(yearMonthSelectorView.snp.bottom)
            $0.horizontalEdges.bottom.equalToSuperview()
        }

        // Filter dropdown
        filterDropdownView.snp.makeConstraints {
            $0.top.equalTo(filterButton.snp.bottom).offset(4)
            $0.trailing.equalToSuperview().offset(-16)
            $0.width.equalTo(120)
        }

        filterStackView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(8)
        }

        // Year dropdown
        yearDropdownView.snp.makeConstraints {
            $0.top.equalTo(yearPickerButton.snp.bottom).offset(4)
            $0.leading.equalToSuperview().offset(16)
            $0.width.equalTo(100)
            $0.height.equalTo(200)
        }

        yearTableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        // Month dropdown
        monthDropdownView.snp.makeConstraints {
            $0.top.equalTo(monthPickerButton.snp.bottom).offset(4)
            $0.leading.equalTo(yearPickerButton.snp.trailing).offset(16)
            $0.width.equalTo(80)
            $0.height.equalTo(300)
        }

        monthTableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        // Calendar container
        calendarContainerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        calendarScrollView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        calendarContentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
        }

        calendarView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(620)
            $0.bottom.equalToSuperview()
        }
    }

    override func configureView() {
        super.configureView()

        calendarScrollView.do {
            $0.showsVerticalScrollIndicator = true
            $0.alwaysBounceVertical = true
        }

        calendarContentView.do {
            $0.backgroundColor = .clear
        }

        // Initially show list view
        updateVisibleView()
        updateFilterUI()
        updateYearMonthButtons()
    }

    private func setupFilterButtons() {
        for mode in ListFilterMode.allCases {
            var config = UIButton.Configuration.plain()
            config.baseForegroundColor = .textSecondary
            config.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0)
            var titleAttr = AttributeContainer()
            titleAttr.font = FontManager.body
            config.attributedTitle = AttributedString(mode.title, attributes: titleAttr)

            let button = UIButton(configuration: config)
            button.contentHorizontalAlignment = .leading
            button.tag = mode.rawValue
            button.addTarget(self, action: #selector(filterOptionTapped(_:)), for: .touchUpInside)

            button.snp.makeConstraints {
                $0.height.equalTo(40)
            }

            filterStackView.addArrangedSubview(button)
        }
    }

    @objc private func filterOptionTapped(_ sender: UIButton) {
        guard let mode = ListFilterMode(rawValue: sender.tag) else { return }
        currentFilterMode = mode
        hideFilterDropdown()
        onFilterModeChanged?(mode)
    }

    private func updateVisibleView() {
        let isListMode = currentSegment == .list
        listHeaderView.isHidden = !isListMode
        yearMonthSelectorView.isHidden = !isListMode || currentFilterMode == .all
        listView.isHidden = !isListMode
        calendarContainerView.isHidden = currentSegment != .calendar

        // Hide all dropdowns when switching
        hideAllDropdowns()

        // 캘린더 탭으로 전환 시 레이아웃 업데이트 후 캘린더 리로드
        if currentSegment == .calendar {
            layoutIfNeeded()
            calendarView.layoutIfNeeded()
            calendarView.calendar.reloadData()
        }
    }

    private func updateFilterUI() {
        // Update filter button configuration
        var config = filterButton.configuration ?? UIButton.Configuration.plain()
        var titleAttr = AttributeContainer()
        titleAttr.font = FontManager.body
        config.attributedTitle = AttributedString(currentFilterMode.title, attributes: titleAttr)
        filterButton.configuration = config

        // Show/hide year-month selector
        let showSelector = currentFilterMode != .all
        yearMonthSelectorView.isHidden = !showSelector

        yearMonthSelectorView.snp.updateConstraints {
            $0.height.equalTo(showSelector ? 44 : 0)
        }

        // Show month picker only for monthly filter
        monthPickerButton.isHidden = currentFilterMode != .byMonth

        UIView.animate(withDuration: 0.2) {
            self.layoutIfNeeded()
        }
    }

    private func updateYearMonthButtons() {
        // Update year picker button configuration
        var yearConfig = yearPickerButton.configuration ?? UIButton.Configuration.plain()
        var yearTitleAttr = AttributeContainer()
        yearTitleAttr.font = FontManager.body
        yearConfig.attributedTitle = AttributedString("\(selectedYear)년", attributes: yearTitleAttr)
        yearPickerButton.configuration = yearConfig

        // Update month picker button configuration
        var monthConfig = monthPickerButton.configuration ?? UIButton.Configuration.plain()
        var monthTitleAttr = AttributeContainer()
        monthTitleAttr.font = FontManager.body
        monthConfig.attributedTitle = AttributedString("\(selectedMonth)월", attributes: monthTitleAttr)
        monthPickerButton.configuration = monthConfig
    }

    // MARK: - Public Methods

    func updateTotalCount(_ count: Int) {
        totalCountLabel.text = "전체 \(count)개"
    }

    func showFilterDropdown() {
        filterDropdownView.isHidden = false
        yearDropdownView.isHidden = true
        monthDropdownView.isHidden = true
    }

    func hideFilterDropdown() {
        filterDropdownView.isHidden = true
    }

    func toggleFilterDropdown() {
        if filterDropdownView.isHidden {
            showFilterDropdown()
        } else {
            hideFilterDropdown()
        }
    }

    func showYearDropdown() {
        yearDropdownView.isHidden = false
        filterDropdownView.isHidden = true
        monthDropdownView.isHidden = true
    }

    func hideYearDropdown() {
        yearDropdownView.isHidden = true
    }

    func toggleYearDropdown() {
        if yearDropdownView.isHidden {
            showYearDropdown()
        } else {
            hideYearDropdown()
        }
    }

    func showMonthDropdown() {
        monthDropdownView.isHidden = false
        filterDropdownView.isHidden = true
        yearDropdownView.isHidden = true
    }

    func hideMonthDropdown() {
        monthDropdownView.isHidden = true
    }

    func toggleMonthDropdown() {
        if monthDropdownView.isHidden {
            showMonthDropdown()
        } else {
            hideMonthDropdown()
        }
    }

    func hideAllDropdowns() {
        filterDropdownView.isHidden = true
        yearDropdownView.isHidden = true
        monthDropdownView.isHidden = true
    }
}


// MARK: - Calendar Helpers

extension TripRecordView {
    /// 특정 날짜에 해당하는 여행 찾기 (첫 번째)
    func trip(for date: Date) -> Trip? {
        return trips.first { trip in
            let calendar = Calendar.current
            let startOfDay = calendar.startOfDay(for: date)
            let startOfTripStart = calendar.startOfDay(for: trip.startDate)
            let startOfTripEnd = calendar.startOfDay(for: trip.endDate)

            return startOfDay >= startOfTripStart && startOfDay <= startOfTripEnd
        }
    }

    /// 특정 날짜에 해당하는 모든 여행 찾기 (겹치는 여행 포함)
    func trips(for date: Date) -> [Trip] {
        return trips.filter { trip in
            let calendar = Calendar.current
            let startOfDay = calendar.startOfDay(for: date)
            let startOfTripStart = calendar.startOfDay(for: trip.startDate)
            let startOfTripEnd = calendar.startOfDay(for: trip.endDate)

            return startOfDay >= startOfTripStart && startOfDay <= startOfTripEnd
        }
    }

    /// 특정 날짜가 여행 시작일인지 확인
    func isTripStart(date: Date) -> Bool {
        return trips.contains { trip in
            Calendar.current.isDate(date, inSameDayAs: trip.startDate)
        }
    }

    /// 특정 날짜가 여행 종료일인지 확인
    func isTripEnd(date: Date) -> Bool {
        return trips.contains { trip in
            Calendar.current.isDate(date, inSameDayAs: trip.endDate)
        }
    }

    /// 특정 날짜가 여행 기간 중간인지 확인
    func isTripMiddle(date: Date) -> Bool {
        return trip(for: date) != nil && !isTripStart(date: date) && !isTripEnd(date: date)
    }
}
