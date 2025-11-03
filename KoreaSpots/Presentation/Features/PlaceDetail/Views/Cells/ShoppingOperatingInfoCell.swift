//
//  ShoppingOperatingInfoCell.swift
//  KoreaSpots
//
//  Created by YoungJin on 10/28/25.
//

import UIKit
import SnapKit
import Then

final class ShoppingOperatingInfoCell: BaseCollectionViewCell {

    // MARK: - UI Components
    private let containerView = UIView()
    private let stackView = UIStackView()

    // MARK: - Configuration
    func configure(with operatingInfo: OperatingInfo) {
        guard let specificInfo = operatingInfo.specificInfo,
              case .shopping(let shoppingInfo) = specificInfo else {
            return
        }

        setupInfoRows(operatingInfo: operatingInfo, shoppingInfo: shoppingInfo)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        clearStackView()
    }
}

// MARK: - ConfigureUI
extension ShoppingOperatingInfoCell {

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
private extension ShoppingOperatingInfoCell {

    func clearStackView() {
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
    }

    func setupInfoRows(operatingInfo: OperatingInfo, shoppingInfo: ShoppingSpecificInfo) {
        clearStackView()

        // 문의 및 안내
        if let infoCenter = shoppingInfo.infocentershopping, !infoCenter.isEmpty {
            addInfoRow(title: "문의", content: infoCenter)
        }

        // 영업시간
        if let openTime = shoppingInfo.opentime, !openTime.isEmpty {
            addInfoRow(title: "영업시간", content: openTime)
        }

        // 개장일
        if let openDate = shoppingInfo.opendateshopping, !openDate.isEmpty {
            addInfoRow(title: "개장일", content: openDate)
        }

        // 쉬는날
        if let restDate = shoppingInfo.restdateshopping, !restDate.isEmpty {
            addInfoRow(title: "쉬는날", content: restDate)
        }

        // 장서는날
        if let fairDay = shoppingInfo.fairday, !fairDay.isEmpty {
            addInfoRow(title: "장서는날", content: fairDay)
        }

        // 매장안내
        if let shopGuide = shoppingInfo.shopguide, !shopGuide.isEmpty {
            addInfoRow(title: "매장안내", content: shopGuide)
        }

        // 판매품목
        if let saleItem = shoppingInfo.saleitem, !saleItem.isEmpty {
            addInfoRow(title: "판매품목", content: saleItem)
        }

        // 판매품목별 가격
        if let saleItemCost = shoppingInfo.saleitemcost, !saleItemCost.isEmpty {
            addInfoRow(title: "품목별 가격", content: saleItemCost)
        }

        // 규모
        if let scale = shoppingInfo.scaleshopping, !scale.isEmpty {
            addInfoRow(title: "규모", content: scale)
        }

        // 화장실
        if let restroom = shoppingInfo.restroom, !restroom.isEmpty {
            addInfoRow(title: "화장실", content: restroom)
        }

        // 주차시설
        if let parking = shoppingInfo.parkingshopping, !parking.isEmpty {
            addInfoRow(title: "주차시설", content: parking)
        }

        // 문화센터
        if let culturecenter = shoppingInfo.culturecenter, !culturecenter.isEmpty {
            addInfoRow(title: "문화센터", content: culturecenter)
        }

        // 유모차 대여
        if let babyCarriage = shoppingInfo.chkbabycarriageshopping, !babyCarriage.isEmpty {
            addInfoRow(title: "유모차", content: babyCarriage)
        }

        // 반려동물 동반
        if let pet = shoppingInfo.chkpetshopping, !pet.isEmpty {
            addInfoRow(title: "반려동물", content: pet)
        }

        // 신용카드
        if let creditCard = shoppingInfo.chkcreditcardshopping, !creditCard.isEmpty {
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
