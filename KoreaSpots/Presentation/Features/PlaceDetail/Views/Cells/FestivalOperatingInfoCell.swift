//
//  FestivalOperatingInfoCell.swift
//  KoreaSpots
//
//  Created by YoungJin on 10/28/25.
//

import UIKit
import SnapKit
import Then

final class FestivalOperatingInfoCell: BaseCollectionViewCell {

    // MARK: - UI Components
    private let containerView = UIView()
    private let stackView = UIStackView()

    // MARK: - Configuration
    func configure(with operatingInfo: OperatingInfo) {
        guard let specificInfo = operatingInfo.specificInfo,
              case .festival(let festivalInfo) = specificInfo else {
            return
        }

        setupInfoRows(operatingInfo: operatingInfo, festivalInfo: festivalInfo)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        clearStackView()
    }
}

// MARK: - ConfigureUI
extension FestivalOperatingInfoCell {

    override func configureHierarchy() {
        contentView.addSubview(containerView)
        containerView.addSubview(stackView)
    }

    override func configureLayout() {
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(Constants.Layout.standardPadding)
        }

        stackView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(Constants.Layout.standardPadding)
        }
    }

    override func configureView() {
        super.configureView()

        containerView.do {
            $0.backgroundColor = .backGround
            $0.layer.cornerRadius = Constants.UI.CornerRadius.medium
            $0.layer.borderWidth = 1
            $0.layer.borderColor = UIColor.systemGray4.cgColor
        }

        stackView.do {
            $0.axis = .vertical
            $0.spacing = Constants.Layout.smallPadding
            $0.distribution = .fill
            $0.alignment = .fill
        }
    }
}

// MARK: - Private Methods
private extension FestivalOperatingInfoCell {

    func clearStackView() {
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
    }

    func setupInfoRows(operatingInfo: OperatingInfo, festivalInfo: FestivalSpecificInfo) {
        clearStackView()

        // 기간 정보 (시작일 ~ 종료일)
        if let startDate = festivalInfo.eventstartdate, !startDate.isEmpty,
           let endDate = festivalInfo.eventenddate, !endDate.isEmpty {
            let period = DateFormatterUtil.formatPeriodWithYear(start: startDate, end: endDate)
            addInfoRow(title: "행사기간", content: period)
        } else if let startDate = festivalInfo.eventstartdate, !startDate.isEmpty {
            let formattedDate = DateFormatterUtil.formatShortDisplayDate(from: startDate) ?? startDate
            addInfoRow(title: "시작일", content: formattedDate)
        } else if let endDate = festivalInfo.eventenddate, !endDate.isEmpty {
            let formattedDate = DateFormatterUtil.formatShortDisplayDate(from: endDate) ?? endDate
            addInfoRow(title: "종료일", content: formattedDate)
        }

        // 행사장소
        if let eventPlace = festivalInfo.eventplace, !eventPlace.isEmpty {
            addInfoRow(title: "행사장소", content: eventPlace)
        }

        // 공연시간
        if let playTime = festivalInfo.playtime, !playTime.isEmpty {
            addInfoRow(title: "공연시간", content: playTime)
        }

        // 이용요금
        if let useFee = festivalInfo.usetimefestival, !useFee.isEmpty {
            addInfoRow(title: "이용요금", content: useFee)
        }

        // 할인정보
        if let discount = festivalInfo.discountinfofestival, !discount.isEmpty {
            addInfoRow(title: "할인정보", content: discount)
        }

        // 소요시간
        if let spendTime = festivalInfo.spendtimefestival, !spendTime.isEmpty {
            addInfoRow(title: "소요시간", content: spendTime)
        }

        // 관람연령
        if let ageLimit = festivalInfo.agelimit, !ageLimit.isEmpty {
            addInfoRow(title: "관람연령", content: ageLimit)
        }

        // 위치안내
        if let placeInfo = festivalInfo.placeinfo, !placeInfo.isEmpty {
            addInfoRow(title: "위치안내", content: placeInfo)
        }

        // 프로그램
        if let program = festivalInfo.program, !program.isEmpty {
            addInfoRow(title: "프로그램", content: program)
        }

        // 부대행사
        if let subEvent = festivalInfo.subevent, !subEvent.isEmpty {
            addInfoRow(title: "부대행사", content: subEvent)
        }

        // 주최자 정보
        if let sponsor1 = festivalInfo.sponsor1, !sponsor1.isEmpty {
            var sponsorText = sponsor1
            if let tel = festivalInfo.sponsor1tel, !tel.isEmpty {
                sponsorText += " (\(tel))"
            }
            addInfoRow(title: "주최자", content: sponsorText)
        }

        // 주관사 정보
        if let sponsor2 = festivalInfo.sponsor2, !sponsor2.isEmpty {
            var sponsorText = sponsor2
            if let tel = festivalInfo.sponsor2tel, !tel.isEmpty {
                sponsorText += " (\(tel))"
            }
            addInfoRow(title: "주관사", content: sponsorText)
        }

        // 행사 홈페이지
        if let homepage = festivalInfo.eventhomepage, !homepage.isEmpty {
            addInfoRow(title: "행사홈페이지", content: homepage)
        }
    }

    func addInfoRow(title: String, content: String) {
        let row = createInfoRow(title: title, content: content)
        stackView.addArrangedSubview(row)
    }

    func createInfoRow(title: String, content: String) -> UIView {
        let containerView = UIView()
        let titleLabel = UILabel()
        let contentLabel = UILabel()

        containerView.addSubviews(titleLabel, contentLabel)

        titleLabel.do {
            $0.text = title
            $0.font = FontManager.caption1
            $0.textColor = .secondaryLabel
            $0.setContentHuggingPriority(.required, for: .horizontal)
            $0.setContentCompressionResistancePriority(.required, for: .horizontal)
        }

        contentLabel.do {
            $0.text = content
            $0.font = FontManager.body
            $0.textColor = .label
            $0.numberOfLines = 0
        }

        titleLabel.snp.makeConstraints {
            $0.top.leading.bottom.equalToSuperview()
            $0.width.equalTo(80)
        }

        contentLabel.snp.makeConstraints {
            $0.top.trailing.bottom.equalToSuperview()
            $0.leading.equalTo(titleLabel.snp.trailing).offset(Constants.Layout.standardPadding)
        }

        return containerView
    }
}
