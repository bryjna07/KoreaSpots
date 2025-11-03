//
//  CulturalFacilityOperatingInfoCell.swift
//  KoreaSpots
//
//  Created by YoungJin on 10/28/25.
//

import UIKit
import SnapKit
import Then

final class CulturalFacilityOperatingInfoCell: BaseCollectionViewCell {

    // MARK: - UI Components
    private let containerView = UIView()
    private let stackView = UIStackView()

    // MARK: - Configuration
    func configure(with operatingInfo: OperatingInfo) {
        guard let specificInfo = operatingInfo.specificInfo,
              case .culturalFacility(let culturalFacilityInfo) = specificInfo else {
            return
        }

        setupInfoRows(operatingInfo: operatingInfo, culturalFacilityInfo: culturalFacilityInfo)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        clearStackView()
    }
}

// MARK: - ConfigureUI
extension CulturalFacilityOperatingInfoCell {

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
private extension CulturalFacilityOperatingInfoCell {

    func clearStackView() {
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
    }

    func setupInfoRows(operatingInfo: OperatingInfo, culturalFacilityInfo: CulturalFacilitySpecificInfo) {
        clearStackView()

        // 문의 및 안내
        if let infoCenter = culturalFacilityInfo.infocenterculture, !infoCenter.isEmpty {
            addInfoRow(title: "문의 및 안내", content: infoCenter)
        }

        // 이용시간
        if let useTime = culturalFacilityInfo.usetimeculture, !useTime.isEmpty {
            addInfoRow(title: "이용시간", content: useTime)
        }

        // 쉬는날
        if let restDate = culturalFacilityInfo.restdateculture, !restDate.isEmpty {
            addInfoRow(title: "휴무일", content: restDate)
        }

        // 입장료
        if let useFee = culturalFacilityInfo.usefee, !useFee.isEmpty {
            addInfoRow(title: "입장료", content: useFee)
        }

        // 할인정보
        if let discountInfo = culturalFacilityInfo.discountinfo, !discountInfo.isEmpty {
            addInfoRow(title: "할인정보", content: discountInfo)
        }

        // 규모
        if let scale = culturalFacilityInfo.scale, !scale.isEmpty {
            addInfoRow(title: "규모", content: scale)
        }

        // 관람 소요시간
        if let spendTime = culturalFacilityInfo.spendtime, !spendTime.isEmpty {
            addInfoRow(title: "관람 소요시간", content: spendTime)
        }

        // 수용인원
        if let accomCount = culturalFacilityInfo.accomcountculture, !accomCount.isEmpty {
            addInfoRow(title: "수용인원", content: accomCount)
        }

        // 주차시설
        if let parking = culturalFacilityInfo.parkingculture, !parking.isEmpty {
            addInfoRow(title: "주차시설", content: parking)
        }

        // 주차요금
        if let parkingFee = culturalFacilityInfo.parkingfee, !parkingFee.isEmpty {
            addInfoRow(title: "주차요금", content: parkingFee)
        }

        // 유모차 대여
        if let babyCarriage = culturalFacilityInfo.chkbabycarriageculture, !babyCarriage.isEmpty {
            addInfoRow(title: "유모차", content: babyCarriage)
        }

        // 반려동물 동반
        if let pet = culturalFacilityInfo.chkpetculture, !pet.isEmpty {
            addInfoRow(title: "반려동물", content: pet)
        }

        // 신용카드
        if let creditCard = culturalFacilityInfo.chkcreditcardculture, !creditCard.isEmpty {
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
