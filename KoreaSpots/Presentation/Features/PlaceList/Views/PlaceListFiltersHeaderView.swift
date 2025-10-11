//
//  PlaceListFiltersHeaderView.swift
//  KoreaSpots
//
//  Created by YoungJin on 10/08/25.
//

import UIKit
import SnapKit
import Then
import RxSwift

final class PlaceListFiltersHeaderView: BaseReusableView {

    // MARK: - Properties
    private let regionScrollView = UIScrollView()
    private let regionStackView = UIStackView()
    private let sigunguScrollView = UIScrollView()
    private let sigunguStackView = UIStackView()
    private let containerStackView = UIStackView()

    private var regionButtons: [(button: UIButton, areaCode: AreaCode?)] = []
    private var sigunguButtons: [(button: UIButton, code: Int?)] = []

    private let disposeBag = DisposeBag()

    var onRegionSelected: ((AreaCode?) -> Void)?
    var onSigunguSelected: ((Int?) -> Void)?

    private var currentSelectedArea: AreaCode?

    // MARK: - Lifecycle
    override func configureHierarchy() {
        super.configureHierarchy()

        regionScrollView.addSubview(regionStackView)
        sigunguScrollView.addSubview(sigunguStackView)
        containerStackView.addArrangedSubviews(regionScrollView, sigunguScrollView)
        addSubview(containerStackView)
    }

    override func configureLayout() {
        super.configureLayout()

        containerStackView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(UIEdgeInsets(
                top: Constants.UI.Spacing.small,
                left: 0,
                bottom: Constants.UI.Spacing.small,
                right: 0
            ))
        }

        regionScrollView.snp.makeConstraints {
            $0.height.equalTo(40)
        }

        regionStackView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(UIEdgeInsets(
                top: 0,
                left: Constants.UI.Spacing.xLarge,
                bottom: 0,
                right: Constants.UI.Spacing.xLarge
            ))
            $0.height.equalToSuperview()
        }

        sigunguScrollView.snp.makeConstraints {
            $0.height.equalTo(36)
        }

        sigunguStackView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(UIEdgeInsets(
                top: 0,
                left: Constants.UI.Spacing.xLarge,
                bottom: 0,
                right: Constants.UI.Spacing.xLarge
            ))
            $0.height.equalToSuperview()
        }
    }

    override func configureView() {
        super.configureView()
        
        regionScrollView.do {
            $0.showsHorizontalScrollIndicator = false
            $0.showsVerticalScrollIndicator = false
        }

        sigunguScrollView.do {
            $0.showsHorizontalScrollIndicator = false
            $0.showsVerticalScrollIndicator = false
        }

        containerStackView.do {
            $0.axis = .vertical
            $0.spacing = Constants.UI.Spacing.small
            $0.distribution = .fill
            $0.alignment = .fill
        }

        regionStackView.do {
            $0.axis = .horizontal
            $0.spacing = Constants.UI.Spacing.small
            $0.distribution = .fill
            $0.alignment = .center
        }

        sigunguStackView.do {
            $0.axis = .horizontal
            $0.spacing = Constants.UI.Spacing.small
            $0.distribution = .fill
            $0.alignment = .center
        }

        // Load sigungu_codes.json into SigunguStore
        SigunguStore.loadFromBundleAsync(fileName: "sigungu_codes") { success in
            if success {
                print("✅ sigungu_codes.json loaded successfully")
            } else {
                print("⚠️ Failed to load sigungu_codes.json")
            }
        }
    }

    // MARK: - Public
    func configure(selectedArea: AreaCode?, selectedSigungu: Int?) {
        currentSelectedArea = selectedArea
        setupRegionChips(selectedArea: selectedArea)
        setupSigunguChips(for: selectedArea, selectedSigungu: selectedSigungu)
    }

    // MARK: - Private
    private func setupRegionChips(selectedArea: AreaCode?) {
        regionStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        regionButtons.removeAll()

        // 전체 + 17개 시도
        let allRegions: [AreaCode?] = [nil] + AreaCode.allCases

        allRegions.forEach { areaCode in
            let title = areaCode?.displayName ?? "전체"
            let isSelected = (areaCode == selectedArea) || (areaCode == nil && selectedArea == nil)
            let button = createChipButton(title: title, isSelected: isSelected, isSmall: false)

            button.rx.tap
                .bind { [weak self] in
                    self?.handleRegionSelection(areaCode: areaCode)
                }
                .disposed(by: disposeBag)

            regionStackView.addArrangedSubview(button)
            regionButtons.append((button: button, areaCode: areaCode))
        }
    }

    private func setupSigunguChips(for areaCode: AreaCode?, selectedSigungu: Int?) {
        sigunguStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        sigunguButtons.removeAll()

        guard let areaCode = areaCode else {
            // 전체 선택 시 시군구 칩 숨김
            sigunguScrollView.isHidden = true
            return
        }

        sigunguScrollView.isHidden = false

        // 시군구 데이터 로드
        let sigungus = getSigungus(for: areaCode)

        // 전체 + 시군구 목록
        let allSigungus: [(code: Int?, name: String)] = [(code: nil, name: "전체")] + sigungus.map { (code: $0.code, name: $0.name) }

        allSigungus.forEach { item in
            let isSelected = (item.code == selectedSigungu) || (item.code == nil && selectedSigungu == nil)
            let button = createChipButton(title: item.name, isSelected: isSelected, isSmall: true)

            button.rx.tap
                .bind { [weak self] in
                    self?.handleSigunguSelection(code: item.code)
                }
                .disposed(by: disposeBag)

            sigunguStackView.addArrangedSubview(button)
            sigunguButtons.append((button: button, code: item.code))
        }
    }

    private func getSigungus(for areaCode: AreaCode) -> [(code: Int, name: String)] {
        guard SigunguStore.isLoaded else {
            print("⚠️ SigunguStore not loaded yet")
            return []
        }

        // SigunguStore에서 시군구 목록 조회
        var sigungus: [(code: Int, name: String)] = []

        // 모든 가능한 시군구 코드를 순회하며 이름 조회 (1~999)
        for code in 1...999 {
            if let name = SigunguStore.name(areaCode: areaCode, sigunguCode: code, preferred: .ko) {
                sigungus.append((code: code, name: name))
            }
        }

        return sigungus
    }

    private func createChipButton(title: String, isSelected: Bool, isSmall: Bool) -> UIButton {
        var config = UIButton.Configuration.plain()

        // AttributedString으로 폰트와 텍스트 설정
        var titleAttr = AttributedString(title)
        titleAttr.font = isSmall
            ? .systemFont(ofSize: 12, weight: .medium)
            : .systemFont(ofSize: 14, weight: .semibold)
        config.attributedTitle = titleAttr

        // 선택 상태: 연한 파란 배경 + 파란 글씨 / 미선택: 투명 배경 + 기본 글씨
        config.baseForegroundColor = isSelected ? .textPrimary : .label
        config.baseBackgroundColor = isSelected ? .textPrimary.withAlphaComponent(0.1) : .clear
        config.cornerStyle = .fixed
        config.background.cornerRadius = isSmall ? 12 : 16
        config.background.strokeWidth = 1
        config.background.strokeColor = isSelected ? .textPrimary : .separator
        config.contentInsets = NSDirectionalEdgeInsets(
            top: isSmall ? 4 : 6,
            leading: isSmall ? 12 : 16,
            bottom: isSmall ? 4 : 6,
            trailing: isSmall ? 12 : 16
        )

        let button = UIButton(configuration: config)
        return button
    }

    private func updateButtonAppearance(_ button: UIButton, isSelected: Bool) {
        guard var config = button.configuration else { return }

        config.baseForegroundColor = isSelected ? .textPrimary : .label
        config.baseBackgroundColor = isSelected ? .textPrimary.withAlphaComponent(0.1) : .clear
        config.background.strokeColor = isSelected ? .textPrimary : .separator

        button.configuration = config
    }

    private func handleRegionSelection(areaCode: AreaCode?) {
        // Update button appearances
        regionButtons.forEach { item in
            let isSelected = item.areaCode == areaCode
            updateButtonAppearance(item.button, isSelected: isSelected)
        }

        currentSelectedArea = areaCode

        // Notify selection
        onRegionSelected?(areaCode)

        // Update sigungu chips
        setupSigunguChips(for: areaCode, selectedSigungu: nil)
    }

    private func handleSigunguSelection(code: Int?) {
        // Update button appearances
        sigunguButtons.forEach { item in
            let isSelected = item.code == code
            updateButtonAppearance(item.button, isSelected: isSelected)
        }

        // Notify selection
        onSigunguSelected?(code)
    }
}
