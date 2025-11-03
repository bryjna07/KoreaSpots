//
//  LeisureSportsOperatingInfoCell.swift
//  KoreaSpots
//
//  Created by YoungJin on 10/28/25.
//

import UIKit
import SnapKit
import Then

final class LeisureSportsOperatingInfoCell: BaseCollectionViewCell {

    // MARK: - UI Components
    private let containerView = UIView()
    private let stackView = UIStackView()

    // MARK: - Configuration
    func configure(with operatingInfo: OperatingInfo) {
        guard let specificInfo = operatingInfo.specificInfo,
              case .leisureSports(let leisureSportsInfo) = specificInfo else {
            return
        }

        setupInfoRows(operatingInfo: operatingInfo, leisureSportsInfo: leisureSportsInfo)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        clearStackView()
    }
}

// MARK: - ConfigureUI
extension LeisureSportsOperatingInfoCell {

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
private extension LeisureSportsOperatingInfoCell {

    func clearStackView() {
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
    }

    func setupInfoRows(operatingInfo: OperatingInfo, leisureSportsInfo: LeisureSportsSpecificInfo) {
        clearStackView()

        // 문의 및 안내
        if let infoCenter = leisureSportsInfo.infocenterleports, !infoCenter.isEmpty {
            addInfoRow(title: "문의 및 안내", content: infoCenter)
        }

        // 개장기간
        if let openPeriod = leisureSportsInfo.openperiod, !openPeriod.isEmpty {
            addInfoRow(title: "개장기간", content: openPeriod)
        }

        // 이용시간
        if let useTime = leisureSportsInfo.usetimeleports, !useTime.isEmpty {
            addInfoRow(title: "이용시간", content: useTime)
        }

        // 쉬는날
        if let restDate = leisureSportsInfo.restdateleports, !restDate.isEmpty {
            addInfoRow(title: "휴무일", content: restDate)
        }

        // 입장료
        if let useFee = leisureSportsInfo.usefeeleports, !useFee.isEmpty {
            addInfoRow(title: "입장료", content: useFee)
        }

        // 예약안내
        if let reservation = leisureSportsInfo.reservation, !reservation.isEmpty {
            addInfoRow(title: "예약안내", content: reservation)
        }

        // 규모
        if let scale = leisureSportsInfo.scaleleports, !scale.isEmpty {
            addInfoRow(title: "규모", content: scale)
        }

        // 수용인원
        if let accomCount = leisureSportsInfo.accomcountleports, !accomCount.isEmpty {
            addInfoRow(title: "수용인원", content: accomCount)
        }

        // 체험가능연령
        if let expAgeRange = leisureSportsInfo.expagerangeleports, !expAgeRange.isEmpty {
            addInfoRow(title: "체험연령", content: expAgeRange)
        }

        // 주차시설
        if let parking = leisureSportsInfo.parkingleports, !parking.isEmpty {
            addInfoRow(title: "주차시설", content: parking)
        }

        // 주차요금
        if let parkingFee = leisureSportsInfo.parkingfeeleports, !parkingFee.isEmpty {
            addInfoRow(title: "주차요금", content: parkingFee)
        }

        // 유모차 대여
        if let babyCarriage = leisureSportsInfo.chkbabycarriageleports, !babyCarriage.isEmpty {
            addInfoRow(title: "유모차", content: babyCarriage)
        }

        // 반려동물 동반
        if let pet = leisureSportsInfo.chkpetleports, !pet.isEmpty {
            addInfoRow(title: "반려동물", content: pet)
        }

        // 신용카드
        if let creditCard = leisureSportsInfo.chkcreditcardleports, !creditCard.isEmpty {
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
