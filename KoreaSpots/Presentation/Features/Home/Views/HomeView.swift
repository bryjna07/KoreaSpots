//
//  HomeView.swift
//  KoreaSpots
//
//  Created by YoungJin on 9/25/25.
//

import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa
import SkeletonView

final class HomeView: BaseView {

    // MARK: - UI Components
    let searchButton = UIButton(type: .system)
    lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
//    let refreshControl = UIRefreshControl()

    // MARK: - Auto Paging Properties
    private var autoScrollTimer: Timer?
    private var currentFestivalPage = 0
    private var totalFestivalPages = 0

    var currentPage: Int {
        return currentFestivalPage
    }
    
    deinit {
        stopAutoScroll()
    }
}


// MARK: - ConfigureUI
extension HomeView {
    override func configureHierarchy() {
        addSubviews(searchButton, collectionView)
    }
    
    override func configureLayout() {
        
        searchButton.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide).inset(16)
            $0.leading.trailing.equalToSuperview().inset(Constants.UI.Spacing.large)
            $0.height.equalTo(Constants.UI.Button.searchHeight)
        }
        
        collectionView.snp.makeConstraints {
            $0.top.equalTo(searchButton.snp.bottom).offset(Constants.UI.Spacing.medium)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    override func configureView() {
        super.configureView()
        
        searchButton.do {
            var config = UIButton.Configuration.filled()
            config.baseBackgroundColor = .secondBackGround
            config.baseForegroundColor = .secondaryLabel
            config.cornerStyle = .fixed
            config.background.cornerRadius = Constants.UI.Button.cornerRadius

            config.title = LocalizedKeys.Search.placeholder.localized
            config.image = UIImage(systemName: Constants.Icon.System.magnifyingGlass)
            config.imagePlacement = .leading
            config.imagePadding = Constants.UI.CollectionView.PageIndicator.imagePadding
            config.contentInsets = NSDirectionalEdgeInsets(
                top: 0,
                leading: Constants.UI.CollectionView.PageIndicator.contentLeading,
                bottom: 0,
                trailing: Constants.UI.CollectionView.PageIndicator.contentTrailing
            )

            $0.configuration = config
            $0.contentHorizontalAlignment = .leading
        }

        collectionView.do {
            $0.backgroundColor = .clear
            $0.contentInsetAdjustmentBehavior = .automatic
//            $0.refreshControl = refreshControl
            $0.register(cell: FestivalCardCell.self)
            $0.register(cell: PlaceCardCell.self)
            $0.register(cell: RectangleCell.self)
            $0.register(cell: RoundCell.self)
            $0.register(cell: PlaceholderCardCell.self)
            $0.register(header: SectionHeaderView.self)
            $0.register(supplementary: FestivalPageIndicatorView.self)
            // Skeleton configuration
            $0.isSkeletonable = true
        }
    }
}

// MARK: - Auto Paging
extension HomeView {
    func startAutoScroll() {
        stopAutoScroll() // 기존 타이머 정리

        guard totalFestivalPages > 1 else { return }

        autoScrollTimer = Timer.scheduledTimer(withTimeInterval: Constants.UI.CollectionView.AutoScroll.timeInterval, repeats: true) { [weak self] _ in
            self?.scrollToNextPage()
        }
    }

    func stopAutoScroll() {
        autoScrollTimer?.invalidate()
        autoScrollTimer = nil
    }

    private func scrollToNextPage() {
        guard totalFestivalPages > 0 else { return }

        currentFestivalPage = (currentFestivalPage + 1) % totalFestivalPages

        let indexPath = IndexPath(item: currentFestivalPage, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)

        // Update page indicator in footer
        updatePageIndicator()
    }

    private func updatePageIndicator() {
        // Find and update the footer view directly
        let footerKind = FestivalPageIndicatorView.elementKind
        let indexPath = IndexPath(item: 0, section: 0)

        if let footerView = collectionView.supplementaryView(forElementKind: footerKind, at: indexPath) as? FestivalPageIndicatorView {
            footerView.configure(currentPage: currentFestivalPage + 1, totalPages: totalFestivalPages)
        }
    }

    func updateFestivalPageCount(_ count: Int) {
        totalFestivalPages = count
        if count > 1 {
            startAutoScroll()
        } else {
            stopAutoScroll()
        }
    }

    func pauseAutoScroll() {
        stopAutoScroll()
    }

    func resumeAutoScroll() {
        startAutoScroll()
    }

    
}
