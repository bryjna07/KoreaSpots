//
//  TripPhotosGridView.swift
//  KoreaSpots
//
//  Created by Watson22_YJ on 11/16/25.
//

import UIKit
import SnapKit
import Then

final class TripPhotosGridView: BaseView {

    // MARK: - UI Components

    lazy var collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: createLayout()
    ).then {
        $0.backgroundColor = .systemBackground
        $0.showsVerticalScrollIndicator = true
    }

    private let emptyStateView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 12
        $0.alignment = .center
        $0.isHidden = true
    }

    private let emptyImageView = UIImageView().then {
        $0.image = UIImage(systemName: "photo.on.rectangle.angled")
        $0.tintColor = .tertiaryLabel
        $0.contentMode = .scaleAspectFit
    }

    private let emptyLabel = UILabel().then {
        $0.text = "여행 사진이 없습니다."
        $0.font = FontManager.body
        $0.textColor = .secondaryLabel
        $0.textAlignment = .center
    }

    let addPhotoButton = UIButton().then {
        $0.setTitle("사진 추가", for: .normal)
        $0.setTitleColor(.primary, for: .normal)
        $0.titleLabel?.font = FontManager.bodyBold
        $0.backgroundColor = UIColor.primary.withAlphaComponent(0.1)
        $0.layer.cornerRadius = 8
        $0.contentEdgeInsets = UIEdgeInsets(top: 12, left: 24, bottom: 12, right: 24)
    }

    // MARK: - Properties

    var photos: [TripPhoto] = [] {
        didSet {
            emptyStateView.isHidden = !photos.isEmpty
            collectionView.isHidden = photos.isEmpty
        }
    }

    // Callback
    var onPhotoTapped: ((TripPhoto, Int) -> Void)?
    var onAddPhotoTapped: (() -> Void)?

    // MARK: - Hierarchy & Layout

    override func configureHierarchy() {
        addSubviews(collectionView, emptyStateView)
        emptyStateView.addArrangedSubviews(emptyImageView, emptyLabel, addPhotoButton)
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
    }
 
    override func configureView() {
        backgroundColor = .systemBackground

        addPhotoButton.addTarget(self, action: #selector(addPhotoButtonTapped), for: .touchUpInside)
    }

    // MARK: - Actions

    @objc private func addPhotoButtonTapped() {
        onAddPhotoTapped?()
    }

    // MARK: - Public Methods

    func configure(with photos: [TripPhoto]) {
        self.photos = photos
        collectionView.reloadData()
    }

    // MARK: - CollectionView Layout

    private func createLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1/3),
            heightDimension: .fractionalWidth(1/3)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalWidth(1/3)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 16, trailing: 0)

        return UICollectionViewCompositionalLayout(section: section)
    }
}
