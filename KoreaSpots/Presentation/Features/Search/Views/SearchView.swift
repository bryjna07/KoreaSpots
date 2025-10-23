//
//  SearchView.swift
//  KoreaSpots
//
//  Created by YoungJin on 10/09/25.
//

import UIKit
import SnapKit
import Then

final class SearchView: BaseView {

    // MARK: - UI Components

    // Search Bar
    let searchBar = UISearchBar()
    let searchButton = UIButton(type: .system)

    // Recent Keywords Section
    let recentKeywordsContainerView = UIView()
    private let recentKeywordsHeaderView = UIView()
    private let recentKeywordsLabel = UILabel()
    let clearAllButton = UIButton(type: .system)

    let recentKeywordsCollectionView: UICollectionView = {
        // Left-aligned layout using Compositional Layout
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .estimated(100),
            heightDimension: .estimated(32)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(32)
        )
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitems: [item]
        )
        group.interItemSpacing = .fixed(8)

        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 8
        section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)

        let layout = UICollectionViewCompositionalLayout(section: section)

        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .backGround
        cv.showsVerticalScrollIndicator = false
        cv.contentInsetAdjustmentBehavior = .never
        return cv
    }()

    // Filter Section
    let filterContainerView = UIView()
    let regionChipScrollView = UIScrollView()
    let regionChipStackView = UIStackView()
    let contentTypeChipScrollView = UIScrollView()
    let contentTypeChipStackView = UIStackView()

    // Results Collection View
    let resultsCollectionView: UICollectionView = {
        // Compositional Layout with .list style
        var configuration = UICollectionLayoutListConfiguration(appearance: .plain)
        configuration.backgroundColor = .backGround
        configuration.showsSeparators = false

        let layout = UICollectionViewCompositionalLayout.list(using: configuration)

        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .backGround
        cv.showsVerticalScrollIndicator = true
        cv.contentInsetAdjustmentBehavior = .never
        cv.isHidden = true // Initially hidden
        return cv
    }()

    // Empty State
    let emptyStateView = UIView()
    let emptyStateLabel = UILabel()

    // MARK: - Hierarchy & Layout

    override func configureHierarchy() {
        recentKeywordsHeaderView.addSubviews(recentKeywordsLabel, clearAllButton)
        recentKeywordsContainerView.addSubviews(recentKeywordsHeaderView, recentKeywordsCollectionView)

        regionChipScrollView.addSubview(regionChipStackView)
        contentTypeChipScrollView.addSubview(contentTypeChipStackView)
        filterContainerView.addSubviews(regionChipScrollView, contentTypeChipScrollView)

        emptyStateView.addSubview(emptyStateLabel)

        addSubviews(
            searchBar,
            searchButton,
            recentKeywordsContainerView,
            filterContainerView,
            resultsCollectionView,
            emptyStateView
        )
    }

    override func configureLayout() {
        searchBar.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide).offset(8)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalTo(searchButton.snp.leading).offset(-8)
        }

        searchButton.snp.makeConstraints {
            $0.centerY.equalTo(searchBar)
            $0.trailing.equalToSuperview().offset(-16)
            $0.width.equalTo(60)
            $0.height.equalTo(36)
        }

        recentKeywordsContainerView.snp.makeConstraints {
            $0.top.equalTo(searchBar.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(200)
        }

        recentKeywordsHeaderView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(44)
        }

        recentKeywordsLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.centerY.equalToSuperview()
        }

        clearAllButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-16)
            $0.centerY.equalToSuperview()
        }

        recentKeywordsCollectionView.snp.makeConstraints {
            $0.top.equalTo(recentKeywordsHeaderView.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }

        filterContainerView.snp.makeConstraints {
            $0.top.equalTo(searchBar.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(100)
        }

        regionChipScrollView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(44)
        }

        regionChipStackView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16))
            $0.height.equalToSuperview()
        }

        contentTypeChipScrollView.snp.makeConstraints {
            $0.top.equalTo(regionChipScrollView.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(44)
        }

        contentTypeChipStackView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16))
            $0.height.equalToSuperview()
        }

        resultsCollectionView.snp.makeConstraints {
            $0.top.equalTo(filterContainerView.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }

        emptyStateView.snp.makeConstraints {
            $0.top.equalTo(filterContainerView.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }

        emptyStateLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(40)
        }
    }

    override func configureView() {
        super.configureView()
        backgroundColor = .backGround

        searchBar.do {
            $0.placeholder = "여행지, 지역명으로 검색"
            $0.searchBarStyle = .minimal
            $0.enablesReturnKeyAutomatically = true
            $0.returnKeyType = .search
        }

        searchButton.do {
            $0.setTitle("검색", for: .normal)
            $0.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
            $0.backgroundColor = .textPrimary
            $0.setTitleColor(.white, for: .normal)
            $0.layer.cornerRadius = 8
        }

        recentKeywordsContainerView.do {
            $0.backgroundColor = .backGround
        }

        recentKeywordsLabel.do {
            $0.text = "최근 검색어"
            $0.font = .systemFont(ofSize: 16, weight: .bold)
            $0.textColor = .label
        }

        clearAllButton.do {
            $0.setTitle("전체 삭제", for: .normal)
            $0.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
            $0.setTitleColor(.secondaryLabel, for: .normal)
        }

        filterContainerView.do {
            $0.backgroundColor = .backGround
            $0.isHidden = true
        }

        regionChipScrollView.do {
            $0.showsHorizontalScrollIndicator = false
            $0.showsVerticalScrollIndicator = false
        }

        regionChipStackView.do {
            $0.axis = .horizontal
            $0.spacing = 8
            $0.distribution = .fill
            $0.alignment = .center
        }

        contentTypeChipScrollView.do {
            $0.showsHorizontalScrollIndicator = false
            $0.showsVerticalScrollIndicator = false
        }

        contentTypeChipStackView.do {
            $0.axis = .horizontal
            $0.spacing = 8
            $0.distribution = .fill
            $0.alignment = .center
        }

        emptyStateView.do {
            $0.backgroundColor = .backGround
            $0.isHidden = true
        }

        emptyStateLabel.do {
            $0.font = .systemFont(ofSize: 16, weight: .medium)
            $0.textColor = .secondaryLabel
            $0.textAlignment = .center
            $0.numberOfLines = 0
            $0.text = "검색 결과가 없습니다."
        }
    }

    // MARK: - Helper Methods

    func createChipButton(title: String, isSelected: Bool, isSmall: Bool = false) -> UIButton {
        var config = UIButton.Configuration.plain()

        var titleAttr = AttributedString(title)
        titleAttr.font = isSmall
            ? .systemFont(ofSize: 12, weight: .medium)
            : .systemFont(ofSize: 14, weight: .semibold)
        config.attributedTitle = titleAttr

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

    func updateChipSelection(in stackView: UIStackView, selectedIndex: Int) {
        stackView.arrangedSubviews.enumerated().forEach { index, view in
            guard let button = view as? UIButton, var config = button.configuration else { return }

            let isSelected = index == selectedIndex
            config.baseForegroundColor = isSelected ? .textPrimary : .label
            config.baseBackgroundColor = isSelected ? .textPrimary.withAlphaComponent(0.1) : .clear
            config.background.strokeColor = isSelected ? .textPrimary : .separator

            button.configuration = config
        }
    }

    func showRecentKeywordsSection() {
        recentKeywordsContainerView.isHidden = false
        filterContainerView.isHidden = true
        resultsCollectionView.isHidden = true
        emptyStateView.isHidden = true
    }

    func showSearchResults() {
        recentKeywordsContainerView.isHidden = true
        filterContainerView.isHidden = false
        resultsCollectionView.isHidden = false
        emptyStateView.isHidden = true
    }

    func showEmptyState() {
        recentKeywordsContainerView.isHidden = true
        filterContainerView.isHidden = false
        resultsCollectionView.isHidden = true
        emptyStateView.isHidden = false
    }
}
