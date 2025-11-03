//
//  AccommodationOperatingInfoCell.swift
//  KoreaSpots
//
//  Created by YoungJin on 10/28/25.
//

import UIKit
import SnapKit
import Then

final class AccommodationOperatingInfoCell: BaseCollectionViewCell {

    // MARK: - UI Components
    private let containerView = UIView()
    private let stackView = UIStackView()

    // MARK: - Configuration
    func configure(with operatingInfo: OperatingInfo) {
        guard let specificInfo = operatingInfo.specificInfo,
              case .accommodation(let accommodationInfo) = specificInfo else {
            return
        }

        setupInfoRows(operatingInfo: operatingInfo, accommodationInfo: accommodationInfo)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        clearStackView()
    }
}

// MARK: - ConfigureUI
extension AccommodationOperatingInfoCell {

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
private extension AccommodationOperatingInfoCell {

    func clearStackView() {
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
    }

    func setupInfoRows(operatingInfo: OperatingInfo, accommodationInfo: AccommodationSpecificInfo) {
        clearStackView()

        // 문의
        if let infoCenter = accommodationInfo.infocenterlodging, !infoCenter.isEmpty {
            addInfoRow(title: "문의", content: infoCenter)
        }

        // 예약안내
        if let reservation = accommodationInfo.reservationlodging, !reservation.isEmpty {
            addInfoRow(title: "예약안내", content: reservation)
        }

        // 체크인/체크아웃
        if let checkin = accommodationInfo.checkintime, !checkin.isEmpty,
           let checkout = accommodationInfo.checkouttime, !checkout.isEmpty {
            addInfoRow(title: "입실/퇴실", content: "\(checkin) / \(checkout)")
        } else if let checkin = accommodationInfo.checkintime, !checkin.isEmpty {
            addInfoRow(title: "입실시간", content: checkin)
        } else if let checkout = accommodationInfo.checkouttime, !checkout.isEmpty {
            addInfoRow(title: "퇴실시간", content: checkout)
        }

        // 주차시설
        if let parking = accommodationInfo.parkinglodging, !parking.isEmpty {
            addInfoRow(title: "주차시설", content: parking)
        }

        // 규모
        if let scale = accommodationInfo.scalelodging, !scale.isEmpty {
            addInfoRow(title: "규모", content: scale)
        }

        // 객실 정보
        if let roomCount = accommodationInfo.roomcount, !roomCount.isEmpty {
            addInfoRow(title: "객실수", content: roomCount)
        }

        if let roomType = accommodationInfo.roomtype, !roomType.isEmpty {
            addInfoRow(title: "객실유형", content: roomType)
        }

        // 수용인원
        if let accomCount = accommodationInfo.accomcountlodging, !accomCount.isEmpty {
            addInfoRow(title: "수용인원", content: accomCount)
        }

        // 객실내 취사
        if let cooking = accommodationInfo.chkcooking, !cooking.isEmpty {
            addInfoRow(title: "객실내 취사", content: cooking)
        }

        // 환불규정
        if let refund = accommodationInfo.refundregulation, !refund.isEmpty {
            addInfoRow(title: "환불규정", content: refund)
        }

        // 픽업서비스
        if let pickup = accommodationInfo.pickup, !pickup.isEmpty {
            addInfoRow(title: "픽업서비스", content: pickup)
        }

        // 예약 URL
        if let reservationUrl = accommodationInfo.reservationurl, !reservationUrl.isEmpty {
            addInfoRow(title: "예약 홈페이지", content: reservationUrl)
        }

        // 부대시설 정보
        var facilities: [String] = []
        if accommodationInfo.seminar == "1" { facilities.append("세미나실") }
        if accommodationInfo.sports == "1" { facilities.append("스포츠시설") }
        if accommodationInfo.sauna == "1" { facilities.append("사우나") }
        if accommodationInfo.beauty == "1" { facilities.append("뷰티시설") }
        if accommodationInfo.beverage == "1" { facilities.append("식음료장") }
        if accommodationInfo.karaoke == "1" { facilities.append("노래방") }
        if accommodationInfo.barbecue == "1" { facilities.append("바비큐장") }
        if accommodationInfo.campfire == "1" { facilities.append("캠프파이어") }
        if accommodationInfo.bicycle == "1" { facilities.append("자전거대여") }
        if accommodationInfo.fitness == "1" { facilities.append("휘트니스센터") }
        if accommodationInfo.publicpc == "1" { facilities.append("공용PC") }
        if accommodationInfo.publicbath == "1" { facilities.append("공용샤워실") }

        if !facilities.isEmpty {
            addInfoRow(title: "부대시설", content: facilities.joined(separator: ", "))
        }

        // 부대시설 상세
        if let subfacility = accommodationInfo.subfacility, !subfacility.isEmpty {
            addInfoRow(title: "부대시설 상세", content: subfacility)
        }

        // 식음료장
        if let foodplace = accommodationInfo.foodplace, !foodplace.isEmpty {
            addInfoRow(title: "식음료장", content: foodplace)
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
