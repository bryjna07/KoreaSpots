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
    lazy var sidebarCollectionView = UICollectionView(frame: .zero, collectionViewLayout: createSidebarLayout())
    lazy var gridCollectionView = UICollectionView(frame: .zero, collectionViewLayout: createGridLayout())
    private let contentStackView = UIStackView()

    // MARK: - Properties
    private let sidebarWidth: CGFloat = 110

    // MARK: - ConfigureUI
    override func configureHierarchy() {
        addSubview(searchBar)
        searchBar.addSubviews(searchIcon, searchLabel)

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

        contentStackView.snp.makeConstraints {
            $0.top.equalTo(searchBar.snp.bottom).offset(Constants.UI.Spacing.medium)
            $0.leading.trailing.bottom.equalTo(safeAreaLayoutGuide)
        }

        sidebarCollectionView.snp.makeConstraints {
            $0.width.equalTo(sidebarWidth)
        }
    }

    override func configureView() {
        super.configureView()

        searchBar.do {
            $0.backgroundColor = .secondBackGround
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

        contentStackView.do {
            $0.axis = .horizontal
            $0.distribution = .fill
            $0.spacing = 0
        }

        sidebarCollectionView.do {
            $0.backgroundColor = .backGround
        }

        gridCollectionView.do {
            $0.backgroundColor = .backGround
            $0.showsVerticalScrollIndicator = true
        }
    }

    // MARK: - Layout Factory
    private func createSidebarLayout() -> UICollectionViewLayout {
        var config = UICollectionLayoutListConfiguration(appearance: .sidebar)
        config.showsSeparators = false
        config.backgroundColor = .backGround
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

}
