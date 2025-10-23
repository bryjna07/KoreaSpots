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

    // MARK: - Auto Paging Properties
    private var autoScrollTimer: Timer?
    private var currentFestivalPage = 0 {
        didSet {
            // 페이지 변경 시 자동으로 UI 업데이트 (단일 소스 오브 트루스)
            if oldValue != currentFestivalPage && !isProgrammaticScroll {
                updatePageIndicator()
            }
        }
    }
    private var totalFestivalPages = 0
    private var isProgrammaticScroll = false  // 프로그래밍 스크롤 중인지 플래그

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
            $0.register(cell: FestivalCardCell.self)
            $0.register(cell: PlaceCardCell.self)
            $0.register(cell: RectangleCell.self)
            $0.register(cell: RoundCell.self)
            $0.register(cell: PlaceholderCardCell.self)
            $0.register(header: SectionHeaderView.self)
            $0.register(supplementary: FestivalPageIndicatorView.self)
            $0.register(supplementary: AttributionFooterView.self)
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

        // 프로그래밍 스크롤 시작 - visibleItemsInvalidationHandler 무시
        isProgrammaticScroll = true

        let previousPage = currentFestivalPage
        currentFestivalPage = (currentFestivalPage + 1) % totalFestivalPages

        // 마지막 페이지에서 첫 페이지로 순환할 때는 페이드 애니메이션 적용
        let isWrappingToFirst = (previousPage == totalFestivalPages - 1 && currentFestivalPage == 0)

        let indexPath = IndexPath(item: currentFestivalPage, section: 0)

        if isWrappingToFirst {
            // 페이드 효과로 부드럽게 전환
            UIView.transition(with: collectionView, duration: 0.3, options: .transitionCrossDissolve, animations: {
                self.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
            }, completion: { [weak self] _ in
                // 스크롤 완료 후 플래그 해제 및 UI 업데이트
                self?.isProgrammaticScroll = false
                self?.updatePageIndicator()
            })
        } else {
            // 일반 페이지 전환은 기본 애니메이션
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)

            // 애니메이션 완료 후 플래그 해제 (약간의 딜레이)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) { [weak self] in
                self?.isProgrammaticScroll = false
                self?.updatePageIndicator()
            }
        }
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

        // 데이터 변경 시 명시적으로 첫 페이지로 리셋
        currentFestivalPage = 0

        // 데이터 변경 시 supplementary view 강제 갱신
        if count > 1 {
            // 레이아웃 무효화로 supplementary view 재생성 유도
            if let layout = collectionView.collectionViewLayout as? UICollectionViewCompositionalLayout {
                layout.invalidateLayout()
            }

            // 초기 인디케이터 강제 업데이트
            DispatchQueue.main.async { [weak self] in
                self?.updatePageIndicator()
            }

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

    // MARK: - Internal (for Layout Extension)
    /// visibleItemsInvalidationHandler에서 호출되는 페이지 업데이트 메서드
    internal func updateFestivalPageFromScroll(_ page: Int) {
        // 프로그래밍 스크롤 중에는 무시
        guard !isProgrammaticScroll else { return }

        guard page >= 0 && page < totalFestivalPages else { return }

        // 페이지가 실제로 변경되었을 때만 업데이트 (단일 소스 오브 트루스)
        guard page != currentFestivalPage else { return }

        currentFestivalPage = page
        // didSet에서 자동으로 updatePageIndicator 호출됨

        // 수동 스크롤로 인한 페이지 변경 시 타이머 리셋
        if totalFestivalPages > 1 {
            startAutoScroll()
        }
    }

}
