//
//  PlaceListView.swift
//  KoreaSpots
//
//  Created by YoungJin on 10/08/25.
//

import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa

final class PlaceListView: BaseView {

    // MARK: - UI Components
    let regionChipScrollView = UIScrollView()
    let regionChipStackView = UIStackView()
    let sigunguChipScrollView = UIScrollView()
    let sigunguChipStackView = UIStackView()
    lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())

    // MARK: - ConfigureUI
    override func configureHierarchy() {
        addSubview(regionChipScrollView)
        regionChipScrollView.addSubview(regionChipStackView)

        addSubview(sigunguChipScrollView)
        sigunguChipScrollView.addSubview(sigunguChipStackView)

        addSubview(collectionView)
    }

    override func configureLayout() {
        regionChipScrollView.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide).offset(Constants.UI.Spacing.small)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(40)
        }

        regionChipStackView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(UIEdgeInsets(
                top: 0,
                left: Constants.UI.Spacing.xLarge,
                bottom: 0,
                right: Constants.UI.Spacing.xLarge
            ))
            $0.height.equalToSuperview()
        }

        sigunguChipScrollView.snp.makeConstraints {
            $0.top.equalTo(regionChipScrollView.snp.bottom).offset(Constants.UI.Spacing.small)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(36)
        }

        sigunguChipStackView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(UIEdgeInsets(
                top: 0,
                left: Constants.UI.Spacing.xLarge,
                bottom: 0,
                right: Constants.UI.Spacing.xLarge
            ))
            $0.height.equalToSuperview()
        }

        collectionView.snp.makeConstraints {
            $0.top.equalTo(sigunguChipScrollView.snp.bottom).offset(Constants.UI.Spacing.small)
            $0.leading.trailing.bottom.equalTo(safeAreaLayoutGuide)
        }
    }

    override func configureView() {
        super.configureView()
        backgroundColor = .systemBackground

        regionChipScrollView.do {
            $0.showsHorizontalScrollIndicator = false
            $0.showsVerticalScrollIndicator = false
        }

        regionChipStackView.do {
            $0.axis = .horizontal
            $0.spacing = Constants.UI.Spacing.small
            $0.distribution = .fill
            $0.alignment = .center
        }

        sigunguChipScrollView.do {
            $0.showsHorizontalScrollIndicator = false
            $0.showsVerticalScrollIndicator = false
        }

        sigunguChipStackView.do {
            $0.axis = .horizontal
            $0.spacing = Constants.UI.Spacing.small
            $0.distribution = .fill
            $0.alignment = .center
        }

        collectionView.do {
            $0.backgroundColor = .systemBackground
            $0.showsVerticalScrollIndicator = true
            $0.alwaysBounceVertical = true
        }
    }

    // MARK: - Layout
    private func createLayout() -> UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(88)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(88)
        )
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(
            top: Constants.UI.Spacing.small,
            leading: 0,
            bottom: Constants.UI.Spacing.small,
            trailing: 0
        )

        return UICollectionViewCompositionalLayout(section: section)
    }

    // MARK: - Chip Helper
    func createChipButton(title: String, isSelected: Bool, isSmall: Bool = false) -> UIButton {
        var config = UIButton.Configuration.plain()

        // AttributedString으로 폰트와 텍스트 설정
        var titleAttr = AttributedString(title)
        titleAttr.font = isSmall ? .systemFont(ofSize: 13, weight: .medium) : .systemFont(ofSize: 14, weight: .medium)
        config.attributedTitle = titleAttr

        // 선택 상태: 연한 파란 배경 + 파란 글씨 / 미선택: 투명 배경 + 기본 글씨
        config.baseForegroundColor = isSelected ? .systemBlue : .label
        config.baseBackgroundColor = isSelected ? .systemBlue.withAlphaComponent(0.1) : .clear
        config.cornerStyle = .fixed
        config.background.cornerRadius = isSmall ? 16 : 18
        config.background.strokeWidth = 1
        config.background.strokeColor = isSelected ? .systemBlue : .separator
        config.contentInsets = NSDirectionalEdgeInsets(
            top: Constants.UI.Spacing.xSmall,
            leading: Constants.UI.Spacing.medium,
            bottom: Constants.UI.Spacing.xSmall,
            trailing: Constants.UI.Spacing.medium
        )

        let button = UIButton(configuration: config)
        return button
    }

    func updateChipSelection(in stackView: UIStackView, selectedIndex: Int?) {
        stackView.arrangedSubviews.enumerated().forEach { index, view in
            guard let button = view as? UIButton, var config = button.configuration else { return }
            let isSelected: Bool

            if let selectedIndex = selectedIndex {
                isSelected = (index == selectedIndex)
            } else {
                isSelected = (index == 0) // 전체
            }

            config.baseForegroundColor = isSelected ? .systemBlue : .label
            config.baseBackgroundColor = isSelected ? .systemBlue.withAlphaComponent(0.1) : .clear
            config.background.strokeColor = isSelected ? .systemBlue : .separator

            button.configuration = config
        }
    }
}
