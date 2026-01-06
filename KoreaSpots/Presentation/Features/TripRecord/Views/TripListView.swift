//
//  TripListView.swift
//  KoreaSpots
//
//  Created by Watson22_YJ on 1/5/26.
//

import UIKit
import SnapKit
import Then

final class TripListView: BaseView {

    // MARK: - UI Components

    lazy var collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: createLayout()
    ).then {
        $0.backgroundColor = .backGround
        $0.showsVerticalScrollIndicator = true
        $0.alwaysBounceVertical = true
    }

    private let emptyStateView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 12
        $0.alignment = .center
        $0.isHidden = true
    }

    private let emptyImageView = UIImageView().then {
        $0.image = UIImage(systemName: "airplane.departure")
        $0.tintColor = .tertiaryLabel
        $0.contentMode = .scaleAspectFit
    }

    private let emptyLabel = UILabel().then {
        $0.text = "여행 기록이 없습니다."
        $0.font = FontManager.body
        $0.textColor = .secondaryLabel
        $0.textAlignment = .center
    }

    private let emptySubLabel = UILabel().then {
        $0.text = "새로운 여행을 기록해보세요!"
        $0.font = FontManager.caption1
        $0.textColor = .tertiaryLabel
        $0.textAlignment = .center
    }

    let loadingIndicator = UIActivityIndicatorView(style: .medium).then {
        $0.hidesWhenStopped = true
    }

    // MARK: - Properties

    var isEmpty: Bool = true {
        didSet {
            emptyStateView.isHidden = !isEmpty
            collectionView.isHidden = isEmpty
        }
    }

    // MARK: - Hierarchy & Layout

    override func configureHierarchy() {
        addSubviews(collectionView, emptyStateView, loadingIndicator)
        emptyStateView.addArrangedSubviews(emptyImageView, emptyLabel, emptySubLabel)
    }

    override func configureLayout() {
        collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        emptyStateView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.horizontalEdges.equalToSuperview().inset(32)
        }

        emptyImageView.snp.makeConstraints {
            $0.size.equalTo(80)
        }

        loadingIndicator.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-32)
        }
    }

    override func configureView() {
        super.configureView()
        backgroundColor = .backGround
    }

    // MARK: - Layout

    private func createLayout() -> UICollectionViewCompositionalLayout {
        var configuration = UICollectionLayoutListConfiguration(appearance: .plain)
        configuration.showsSeparators = false
        configuration.backgroundColor = .clear

        return UICollectionViewCompositionalLayout.list(using: configuration)
    }
}
