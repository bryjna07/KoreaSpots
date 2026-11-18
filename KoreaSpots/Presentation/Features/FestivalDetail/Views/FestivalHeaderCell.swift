//
//  FestivalHeaderCell.swift
//  KoreaSpots
//
//  Created by YoungJin on 11/13/26.
//

import UIKit
import SnapKit
import Then

/// 축제 상세 상단: 상태 배지 + 제목 + 기간/장소
final class FestivalHeaderCell: BaseCollectionViewCell {

    // MARK: - UI Components
    private let statusBadge = UIView()
    private let statusLabel = UILabel()
    private let titleLabel = UILabel()
    private let periodRow = IconTextRow(symbol: "calendar")
    private let placeRow = IconTextRow(symbol: "mappin.and.ellipse")
    private let infoStack = UIStackView()

    // MARK: - Configuration
    func configure(with info: FestivalHeaderInfo) {
        titleLabel.text = info.title
        configureStatus(info.status)

        periodRow.setText(info.period)
        placeRow.setText(info.place)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        periodRow.setText(nil)
        placeRow.setText(nil)
    }

    private func configureStatus(_ status: FestivalStatus?) {
        guard let status else {
            statusBadge.isHidden = true
            return
        }

        statusBadge.isHidden = false
        switch status {
        case .ongoing:
            statusLabel.text = LocalizedKeys.FestivalDetail.statusOngoing.localized
            statusBadge.backgroundColor = .greenPastel
        case .upcoming(let daysLeft):
            statusLabel.text = String(format: LocalizedKeys.FestivalDetail.statusUpcoming.localized, daysLeft)
            statusBadge.backgroundColor = .redPastel
        case .ended:
            statusLabel.text = LocalizedKeys.FestivalDetail.statusEnded.localized
            statusBadge.backgroundColor = .systemGray
        }
    }
}

// MARK: - ConfigureUI
extension FestivalHeaderCell {

    override func configureHierarchy() {
        statusBadge.addSubview(statusLabel)
        infoStack.addArrangedSubview(periodRow)
        infoStack.addArrangedSubview(placeRow)
        contentView.addSubviews(statusBadge, titleLabel, infoStack)
    }

    override func configureLayout() {
        statusBadge.snp.makeConstraints {
            $0.top.equalToSuperview().inset(Constants.Layout.mediumPadding)
            $0.leading.equalToSuperview()
        }

        statusLabel.snp.makeConstraints {
            $0.verticalEdges.equalToSuperview().inset(Constants.Layout.smallPadding / 2)
            $0.horizontalEdges.equalToSuperview().inset(Constants.Layout.mediumPadding)
        }

        titleLabel.snp.makeConstraints {
            $0.top.equalTo(statusBadge.snp.bottom).offset(Constants.Layout.smallPadding)
            $0.horizontalEdges.equalToSuperview()
        }

        infoStack.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(Constants.Layout.mediumPadding)
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalToSuperview().inset(Constants.Layout.mediumPadding)
        }
    }

    override func configureView() {
        super.configureView()

        statusBadge.do {
            $0.layer.cornerRadius = Constants.UI.CornerRadius.small
        }

        statusLabel.do {
            $0.font = FontManager.caption2Bold
            $0.textColor = .white
            $0.textAlignment = .center
        }

        titleLabel.do {
            $0.font = FontManager.largeTitle
            $0.textColor = .label
            $0.numberOfLines = 0
        }

        infoStack.do {
            $0.axis = .vertical
            $0.spacing = Constants.Layout.smallPadding
        }
    }
}

// MARK: - IconTextRow
/// 아이콘 + 한 줄 텍스트 (값이 없으면 자동으로 숨김)
final class IconTextRow: UIView {

    private let iconView = UIImageView()
    private let label = UILabel()

    init(symbol: String) {
        super.init(frame: .zero)

        addSubviews(iconView, label)

        iconView.do {
            $0.image = UIImage(systemName: symbol)
            $0.tintColor = .secondaryLabel
            $0.contentMode = .scaleAspectFit
        }

        label.do {
            $0.font = FontManager.body
            $0.textColor = .secondaryLabel
            $0.numberOfLines = 0
        }

        iconView.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.top.equalToSuperview().offset(2)
            $0.size.equalTo(18)
        }

        label.snp.makeConstraints {
            $0.top.bottom.trailing.equalToSuperview()
            $0.leading.equalTo(iconView.snp.trailing).offset(Constants.Layout.smallPadding)
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setText(_ text: String?) {
        label.text = text
        isHidden = (text?.isEmpty ?? true)
    }
}
