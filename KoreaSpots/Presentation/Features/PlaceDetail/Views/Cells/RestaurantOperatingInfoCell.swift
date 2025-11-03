//
//  RestaurantOperatingInfoCell.swift
//  KoreaSpots
//
//  Created by YoungJin on 10/28/25.
//

import UIKit
import SnapKit
import Then

final class RestaurantOperatingInfoCell: BaseCollectionViewCell {

    // MARK: - UI Components
    private let containerView = UIView()
    private let stackView = UIStackView()

    // MARK: - Configuration
    func configure(with operatingInfo: OperatingInfo) {
        guard let specificInfo = operatingInfo.specificInfo,
              case .restaurant(let restaurantInfo) = specificInfo else {
            return
        }

        setupInfoRows(operatingInfo: operatingInfo, restaurantInfo: restaurantInfo)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        clearStackView()
    }
}

// MARK: - ConfigureUI
extension RestaurantOperatingInfoCell {

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
private extension RestaurantOperatingInfoCell {

    func clearStackView() {
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
    }

    func setupInfoRows(operatingInfo: OperatingInfo, restaurantInfo: RestaurantSpecificInfo) {
        clearStackView()

        // 대표메뉴
        if let firstMenu = restaurantInfo.firstmenu, !firstMenu.isEmpty {
            addInfoRow(title: "대표메뉴", content: firstMenu)
        }

        // 취급메뉴
        if let treatMenu = restaurantInfo.treatmenu, !treatMenu.isEmpty {
            addInfoRow(title: "취급메뉴", content: treatMenu)
        }

        // 문의 및 안내
        if let infoCenter = restaurantInfo.infocenterfood, !infoCenter.isEmpty {
            addInfoRow(title: "문의", content: infoCenter)
        }

        // 영업시간
        if let openTime = restaurantInfo.opentimefood, !openTime.isEmpty {
            addInfoRow(title: "영업시간", content: openTime)
        }

        // 쉬는날
        if let restDate = restaurantInfo.restdatefood, !restDate.isEmpty {
            addInfoRow(title: "쉬는날", content: restDate)
        }

        // 포장 가능
        if let packing = restaurantInfo.packing, !packing.isEmpty {
            addInfoRow(title: "포장", content: packing)
        }

        // 예약안내
        if let reservation = restaurantInfo.reservationfood, !reservation.isEmpty {
            addInfoRow(title: "예약", content: reservation)
        }

        // 할인정보
        if let discount = restaurantInfo.discountinfofood, !discount.isEmpty {
            addInfoRow(title: "할인정보", content: discount)
        }

        // 주차시설
        if let parking = restaurantInfo.parkingfood, !parking.isEmpty {
            addInfoRow(title: "주차", content: parking)
        }

        // 좌석수
        if let seat = restaurantInfo.seat, !seat.isEmpty {
            addInfoRow(title: "좌석수", content: seat)
        }

        // 규모
        if let scale = restaurantInfo.scalefood, !scale.isEmpty {
            addInfoRow(title: "규모", content: scale)
        }

        // 어린이 놀이방
        if let kidsFacility = restaurantInfo.kidsfacility, !kidsFacility.isEmpty {
            let hasPlayroom = kidsFacility == "1" ? "있음" : "없음"
            addInfoRow(title: "놀이방", content: hasPlayroom)
        }

        // 흡연/금연
        if let smoking = restaurantInfo.smoking, !smoking.isEmpty {
            addInfoRow(title: "흡연", content: smoking)
        }

        // 신용카드
        if let creditCard = restaurantInfo.chkcreditcardfood, !creditCard.isEmpty {
            addInfoRow(title: "신용카드", content: creditCard)
        }

        // 개업일
        if let openDate = restaurantInfo.opendatefood, !openDate.isEmpty {
            addInfoRow(title: "개업일", content: openDate)
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
