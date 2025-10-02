//
//  CategoryView.swift
//  KoreaSpots
//
//  Created by Claude on 9/30/25.
//

import UIKit
import SnapKit
import Then

final class CategoryView: BaseView {

    // MARK: - UI Components
    let searchBar = UIView()
    private let searchLabel = UILabel()
    private let searchIcon = UIImageView()
    let regionChipScrollView = UIScrollView()
    let regionChipStackView = UIStackView()
    let sigunguChipScrollView = UIScrollView()
    let sigunguChipStackView = UIStackView()
    lazy var sidebarCollectionView = UICollectionView(frame: .zero, collectionViewLayout: createSidebarLayout())
    lazy var gridCollectionView = UICollectionView(frame: .zero, collectionViewLayout: createGridLayout())
    private let contentStackView = UIStackView()

    // MARK: - Properties
    private let sidebarWidth: CGFloat = 80

    // MARK: - ConfigureUI
    override func configureHierarchy() {
        addSubview(searchBar)
        searchBar.addSubviews(searchIcon, searchLabel)

        addSubview(regionChipScrollView)
        regionChipScrollView.addSubview(regionChipStackView)

        addSubview(sigunguChipScrollView)
        sigunguChipScrollView.addSubview(sigunguChipStackView)

        addSubview(contentStackView)
        contentStackView.addArrangedSubviews(sidebarCollectionView, gridCollectionView)
    }

    override func configureLayout() {
        searchBar.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide).offset(Constants.UI.Spacing.small)
            $0.leading.trailing.equalToSuperview().inset(Constants.UI.Spacing.xLarge)
            $0.height.equalTo(Constants.UI.Button.searchHeight)
        }

        searchIcon.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(Constants.UI.Spacing.medium)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(20)
        }

        searchLabel.snp.makeConstraints {
            $0.leading.equalTo(searchIcon.snp.trailing).offset(Constants.UI.Spacing.small)
            $0.trailing.equalToSuperview().offset(-Constants.UI.Spacing.medium)
            $0.centerY.equalToSuperview()
        }

        regionChipScrollView.snp.makeConstraints {
            $0.top.equalTo(searchBar.snp.bottom).offset(Constants.UI.Spacing.medium)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(40)
        }

        regionChipStackView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: Constants.UI.Spacing.xLarge, bottom: 0, right: Constants.UI.Spacing.xLarge))
            $0.height.equalToSuperview()
        }

        sigunguChipScrollView.snp.makeConstraints {
            $0.top.equalTo(regionChipScrollView.snp.bottom).offset(Constants.UI.Spacing.small)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(36)
        }

        sigunguChipStackView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: Constants.UI.Spacing.xLarge, bottom: 0, right: Constants.UI.Spacing.xLarge))
            $0.height.equalToSuperview()
        }

        contentStackView.snp.makeConstraints {
            $0.top.equalTo(sigunguChipScrollView.snp.bottom).offset(Constants.UI.Spacing.small)
            $0.leading.trailing.bottom.equalTo(safeAreaLayoutGuide)
        }

        sidebarCollectionView.snp.makeConstraints {
            $0.width.equalTo(sidebarWidth)
        }
    }

    override func configureView() {
        super.configureView()

        searchBar.do {
            $0.backgroundColor = .systemGray6
            $0.layer.cornerRadius = Constants.UI.CornerRadius.medium
            $0.isUserInteractionEnabled = true
        }

        searchLabel.do {
            $0.text = LocalizedKeys.Search.placeholder.localized
            $0.textColor = .secondaryLabel
            $0.font = .systemFont(ofSize: 16)
        }

        searchIcon.do {
            $0.image = UIImage(systemName: Constants.Icon.System.magnifyingGlass)
            $0.tintColor = .secondaryLabel
            $0.contentMode = .scaleAspectFit
        }

        regionChipScrollView.do {
            $0.showsHorizontalScrollIndicator = false
        }

        regionChipStackView.do {
            $0.axis = .horizontal
            $0.spacing = Constants.UI.Spacing.small
            $0.distribution = .equalSpacing
        }

        sigunguChipScrollView.do {
            $0.showsHorizontalScrollIndicator = false
        }

        sigunguChipStackView.do {
            $0.axis = .horizontal
            $0.spacing = Constants.UI.Spacing.small
            $0.distribution = .equalSpacing
        }

        contentStackView.do {
            $0.axis = .horizontal
            $0.distribution = .fill
            $0.spacing = 0
        }

        sidebarCollectionView.do {
            $0.backgroundColor = .systemBackground
        }

        gridCollectionView.do {
            $0.backgroundColor = .systemBackground
            $0.showsVerticalScrollIndicator = true
        }
    }

    // MARK: - Layout Factory
    private func createSidebarLayout() -> UICollectionViewLayout {
        var config = UICollectionLayoutListConfiguration(appearance: .sidebar)
        config.showsSeparators = false
        config.backgroundColor = .systemBackground
        return UICollectionViewCompositionalLayout.list(using: config)
    }

    private func createGridLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { sectionIndex, environment in
            // 3x2 그리드
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0 / 3.0),
                heightDimension: .estimated(100)
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)

            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(100)
            )
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            group.interItemSpacing = .fixed(Constants.UI.Spacing.small)

            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = Constants.UI.Spacing.small
            section.contentInsets = NSDirectionalEdgeInsets(
                top: Constants.UI.Spacing.small,
                leading: Constants.UI.Spacing.xLarge,
                bottom: Constants.UI.Spacing.xLarge,
                trailing: Constants.UI.Spacing.xLarge
            )

            // Pinned Section Header
            let headerSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(50)
            )
            let header = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: headerSize,
                elementKind: UICollectionView.elementKindSectionHeader,
                alignment: .top
            )
            header.pinToVisibleBounds = true
            section.boundarySupplementaryItems = [header]

            return section
        }
        return layout
    }

    // MARK: - Chip Helper
    func createChipButton(title: String, isSelected: Bool, isSmall: Bool = false) -> UIButton {
        var config = UIButton.Configuration.plain()
        config.title = title
        config.baseForegroundColor = isSelected ? .white : .label
        config.baseBackgroundColor = isSelected ? .systemBlue : .clear
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
        button.titleLabel?.font = isSmall ? .systemFont(ofSize: 13, weight: .medium) : .systemFont(ofSize: 14, weight: .medium)

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

            config.baseForegroundColor = isSelected ? .white : .label
            config.baseBackgroundColor = isSelected ? .systemBlue : .clear
            config.background.strokeColor = isSelected ? .systemBlue : .separator

            button.configuration = config
        }
    }
}
