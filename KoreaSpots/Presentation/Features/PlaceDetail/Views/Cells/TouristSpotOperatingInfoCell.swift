//
//  TouristSpotOperatingInfoCell.swift
//  KoreaSpots
//
//  Created by YoungJin on 10/28/25.
//

import UIKit
import SnapKit
import Then

final class TouristSpotOperatingInfoCell: BaseCollectionViewCell {

    // MARK: - UI Components
    private let containerView = UIView()
    private let stackView = UIStackView()

    // MARK: - Configuration
    func configure(with operatingInfo: OperatingInfo) {
        guard let specificInfo = operatingInfo.specificInfo,
              case .touristSpot(let touristSpotInfo) = specificInfo else {
            return
        }

        setupInfoRows(operatingInfo: operatingInfo, touristSpotInfo: touristSpotInfo)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        clearStackView()
    }
}

// MARK: - ConfigureUI
extension TouristSpotOperatingInfoCell {

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
private extension TouristSpotOperatingInfoCell {

    func clearStackView() {
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
    }

    func setupInfoRows(operatingInfo: OperatingInfo, touristSpotInfo: TouristSpotSpecificInfo) {
        clearStackView()

        // Heritage 정보 (세계문화유산, 세계자연유산, 세계기록유산)
        var heritageList: [String] = []
        if let heritage1 = touristSpotInfo.heritage1, !heritage1.isEmpty, heritage1 != "0" {
            heritageList.append("세계문화유산")
        }
        if let heritage2 = touristSpotInfo.heritage2, !heritage2.isEmpty, heritage2 != "0" {
            heritageList.append("세계자연유산")
        }
        if let heritage3 = touristSpotInfo.heritage3, !heritage3.isEmpty, heritage3 != "0" {
            heritageList.append("세계기록유산")
        }
        if !heritageList.isEmpty {
            addInfoRow(title: "문화유산", content: heritageList.joined(separator: ", "))
        }

        // 문의 및 안내
        if let infoCenter = touristSpotInfo.infocenter, !infoCenter.isEmpty {
            addInfoRow(title: "문의 및 안내", content: infoCenter)
        }

        // 개장일
        if let openDate = touristSpotInfo.opendate, !openDate.isEmpty {
            addInfoRow(title: "개장일", content: openDate)
        }

        // 쉬는날
        if let restDate = touristSpotInfo.restdate, !restDate.isEmpty {
            addInfoRow(title: "휴무일", content: restDate)
        }

        // 이용시기
        if let useSeason = touristSpotInfo.useseason, !useSeason.isEmpty {
            addInfoRow(title: "이용시기", content: useSeason)
        }

        // 이용시간
        if let useTime = touristSpotInfo.usetime, !useTime.isEmpty {
            addInfoRow(title: "이용시간", content: useTime)
        }

        // 주차시설
        if let parking = touristSpotInfo.parking, !parking.isEmpty {
            addInfoRow(title: "주차시설", content: parking)
        }

        // 유모차 대여
        if let babyCarriage = touristSpotInfo.chkbabycarriage, !babyCarriage.isEmpty {
            addInfoRow(title: "유모차", content: babyCarriage)
        }

        // 반려동물 동반
        if let pet = touristSpotInfo.chkpet, !pet.isEmpty {
            addInfoRow(title: "반려동물", content: pet)
        }

        // 체험안내
        if let expGuide = touristSpotInfo.expguide, !expGuide.isEmpty {
            addInfoRow(title: "체험안내", content: expGuide)
        }

        // 체험가능연령
        if let expAgeRange = touristSpotInfo.expagerange, !expAgeRange.isEmpty {
            addInfoRow(title: "체험연령", content: expAgeRange)
        }

        // 수용인원
        if let accomCount = touristSpotInfo.accomcount, !accomCount.isEmpty {
            addInfoRow(title: "수용인원", content: accomCount)
        }

        // 신용카드
        if let creditCard = touristSpotInfo.chkcreditcard, !creditCard.isEmpty {
            addInfoRow(title: "신용카드", content: creditCard)
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
            $0.top.leading.equalToSuperview()
            $0.width.equalTo(80)
        }

        contentLabel.snp.makeConstraints {
            $0.top.trailing.bottom.equalToSuperview()
            $0.leading.equalTo(titleLabel.snp.trailing).offset(Constants.Layout.standardPadding)
        }

        return containerView
    }
}
