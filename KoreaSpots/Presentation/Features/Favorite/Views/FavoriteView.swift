//
//  FavoriteView.swift
//  KoreaSpots
//
//  Created by YoungJin on 10/11/25.
//

import UIKit
import SnapKit
import Then

final class FavoriteView: BaseView {

    // MARK: - UI Components

    // Header
    let headerView = UIView().then {
        $0.backgroundColor = .backGround
    }

    let favoriteCountLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 18, weight: .bold)
        $0.textColor = .textPrimary
        $0.text = "즐겨찾기 0"
    }

    private let separatorView = UIView().then {
        $0.backgroundColor = .separator
    }

    // Collection View
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
//        layout.minimumInteritemSpacing = 12
//        layout.minimumLineSpacing = 16
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)

        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .backGround
        cv.showsVerticalScrollIndicator = true
        cv.contentInsetAdjustmentBehavior = .never
        return cv
    }()

    // Empty State
    let emptyStateView = UIView().then {
        $0.backgroundColor = .backGround
        $0.isHidden = true
    }

    let emptyStateLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 16, weight: .medium)
        $0.textColor = .secondaryLabel
        $0.textAlignment = .center
        $0.numberOfLines = 0
        $0.text = "즐겨찾기한 관광지가 없습니다."
    }

    // MARK: - Hierarchy & Layout

    override func configureHierarchy() {
        headerView.addSubviews(favoriteCountLabel, separatorView)
        emptyStateView.addSubview(emptyStateLabel)
        addSubviews(headerView, collectionView, emptyStateView)
    }

    override func configureLayout() {
        headerView.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide).inset(16)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(60)
        }

        favoriteCountLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(24)
            $0.centerY.equalToSuperview()
        }

        separatorView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(0.5)
        }

        collectionView.snp.makeConstraints {
            $0.top.equalTo(headerView.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }

        emptyStateView.snp.makeConstraints {
            $0.top.equalTo(headerView.snp.bottom)
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
    }

    // MARK: - Helper Methods

    func updateFavoriteCount(_ count: Int) {
        favoriteCountLabel.text = "즐겨찾기 \(count)"
    }

    func showEmptyState() {
        collectionView.isHidden = true
        emptyStateView.isHidden = false
    }

    func showFavorites() {
        collectionView.isHidden = false
        emptyStateView.isHidden = true
    }
}
