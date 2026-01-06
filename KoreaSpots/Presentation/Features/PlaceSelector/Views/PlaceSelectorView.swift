//
//  PlaceSelectorView.swift
//  KoreaSpots
//
//  Created by YoungJin on 10/10/25.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit
import Then

final class PlaceSelectorView: BaseView {

    // MARK: - Properties

    private var dataSource: UICollectionViewDiffableDataSource<Section, Item>!
    let placeSelected = PublishRelay<String>()

    // MARK: - UI Components

    let segmentedControl = UISegmentedControl(items: ["즐겨찾기", "검색"])
    let searchBar = UISearchBar()
    lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
    let emptyLabel = UILabel()
    let activityIndicator = UIActivityIndicatorView(style: .medium)

    // 선택된 장소 표시 영역
    private let selectedPlacesContainerView = UIView()
    private let selectedPlacesTitleLabel = UILabel()
    private let selectedPlacesScrollView = UIScrollView()
    private let selectedPlacesStackView = UIStackView()

    let confirmButton = UIButton(type: .system)

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureDataSource()
    }

    // MARK: - ConfigureUI

    override func configureHierarchy() {
        addSubviews(segmentedControl, searchBar, collectionView, emptyLabel, activityIndicator, selectedPlacesContainerView, confirmButton)
        selectedPlacesContainerView.addSubviews(selectedPlacesTitleLabel, selectedPlacesScrollView)
        selectedPlacesScrollView.addSubview(selectedPlacesStackView)
    }

    override func configureLayout() {
        segmentedControl.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide).offset(16)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(32)
        }

        searchBar.snp.makeConstraints {
            $0.top.equalTo(segmentedControl.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview().inset(8)
            $0.height.equalTo(44)
        }

        collectionView.snp.makeConstraints {
            $0.top.equalTo(searchBar.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(selectedPlacesContainerView.snp.top)
        }

        emptyLabel.snp.makeConstraints {
            $0.center.equalTo(collectionView)
        }

        activityIndicator.snp.makeConstraints {
            $0.center.equalTo(collectionView)
        }

        // 선택된 장소 영역
        selectedPlacesContainerView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(confirmButton.snp.top).offset(-8)
            $0.height.equalTo(0) // 초기에는 숨김
        }

        selectedPlacesTitleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(8)
            $0.leading.equalToSuperview().offset(16)
        }

        selectedPlacesScrollView.snp.makeConstraints {
            $0.top.equalTo(selectedPlacesTitleLabel.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-8)
        }

        selectedPlacesStackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.height.equalToSuperview()
        }

        confirmButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.bottom.equalTo(safeAreaLayoutGuide).inset(16)
            $0.height.equalTo(50)
        }
    }

    override func configureView() {
        super.configureView()

        segmentedControl.do {
            $0.selectedSegmentIndex = 0
        }

        searchBar.do {
            $0.placeholder = "관광지 검색"
            $0.searchBarStyle = .minimal
        }
        collectionView.do {
            $0.backgroundColor = .backGround
            $0.delegate = self
        }

        emptyLabel.do {
            $0.text = "선택 가능한 관광지가 없습니다"
            $0.font = .systemFont(ofSize: 16, weight: .medium)
            $0.textColor = .secondaryLabel
            $0.textAlignment = .center
            $0.isHidden = true
        }

        activityIndicator.do {
            $0.hidesWhenStopped = true
        }

        confirmButton.do {
            $0.setTitle("확인", for: .normal)
            $0.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
            $0.backgroundColor = .bluePastel
            $0.setTitleColor(.white, for: .normal)
            $0.layer.cornerRadius = 12
        }

        // 선택된 장소 영역 설정
        selectedPlacesContainerView.do {
            $0.backgroundColor = .secondBackGround
            $0.clipsToBounds = true
        }

        selectedPlacesTitleLabel.do {
            $0.text = "선택된 장소"
            $0.font = .systemFont(ofSize: 13, weight: .medium)
            $0.textColor = .secondaryLabel
        }

        selectedPlacesScrollView.do {
            $0.showsHorizontalScrollIndicator = false
            $0.contentInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        }

        selectedPlacesStackView.do {
            $0.axis = .horizontal
            $0.spacing = 8
            $0.alignment = .center
        }
    }

    // MARK: - Layout

    private func createLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { _, _ in
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(80)
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)

            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(80)
            )
            let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])

            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = 0
            section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)

            return section
        }
    }

    // MARK: - DataSource

    private func configureDataSource() {
        let cellRegistration = UICollectionView.CellRegistration<PlaceSelectorCell, Place> { [weak self] cell, indexPath, place in
            guard let self = self else { return }
            let isSelected = self.dataSource.snapshot().itemIdentifiers.contains { item in
                if case .place(let p, let selected) = item {
                    return p.contentId == place.contentId && selected
                }
                return false
            }
            cell.configure(with: place, isSelected: isSelected)
        }

        dataSource = UICollectionViewDiffableDataSource<Section, Item>(
            collectionView: collectionView
        ) { collectionView, indexPath, item in
            switch item {
            case .place(let place, _):
                return collectionView.dequeueConfiguredReusableCell(
                    using: cellRegistration,
                    for: indexPath,
                    item: place
                )
            }
        }
    }

    // MARK: - Public Methods

    func applySnapshot(places: [Place], selectedPlaceIds: Set<String>) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        snapshot.appendSections([.places])

        let items = places.map { place in
            Item.place(place, isSelected: selectedPlaceIds.contains(place.contentId))
        }
        snapshot.appendItems(items, toSection: .places)

        dataSource.apply(snapshot, animatingDifferences: true)

        emptyLabel.isHidden = !places.isEmpty
    }

    /// 선택된 장소 목록 업데이트
    func updateSelectedPlaces(_ places: [Place]) {
        // 기존 태그 제거
        selectedPlacesStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        // 새로운 태그 추가
        for place in places {
            let tagView = createSelectedPlaceTag(place: place)
            selectedPlacesStackView.addArrangedSubview(tagView)
        }

        // 컨테이너 높이 애니메이션
        let newHeight: CGFloat = places.isEmpty ? 0 : 70
        UIView.animate(withDuration: 0.25) {
            self.selectedPlacesContainerView.snp.updateConstraints {
                $0.height.equalTo(newHeight)
            }
            self.layoutIfNeeded()
        }
    }

    private func createSelectedPlaceTag(place: Place) -> UIView {
        let containerView = UIView()
        containerView.backgroundColor = .primary.withAlphaComponent(0.15)
        containerView.layer.cornerRadius = 8

        let label = UILabel()
        label.text = place.title
        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.textColor = .primary
        label.lineBreakMode = .byTruncatingTail

        containerView.addSubview(label)
        label.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 6, left: 10, bottom: 6, right: 10))
            $0.width.lessThanOrEqualTo(120)
        }

        // 탭 제스처 추가 (선택 해제)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(selectedPlaceTagTapped(_:)))
        containerView.addGestureRecognizer(tapGesture)
        containerView.isUserInteractionEnabled = true
        containerView.tag = place.contentId.hashValue
        containerView.accessibilityIdentifier = place.contentId

        return containerView
    }

    @objc private func selectedPlaceTagTapped(_ gesture: UITapGestureRecognizer) {
        guard let view = gesture.view,
              let contentId = view.accessibilityIdentifier else { return }
        placeSelected.accept(contentId)
    }
}

// MARK: - UICollectionViewDelegate

extension PlaceSelectorView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = dataSource.itemIdentifier(for: indexPath),
              case .place(let place, _) = item else { return }

        placeSelected.accept(place.contentId)
    }
}

// MARK: - Reactive Extensions

extension Reactive where Base: PlaceSelectorView {
    var isLoading: Binder<Bool> {
        return Binder(base) { view, isLoading in
            if isLoading {
                view.activityIndicator.startAnimating()
                view.collectionView.isHidden = true
                view.emptyLabel.isHidden = true
            } else {
                view.activityIndicator.stopAnimating()
                view.collectionView.isHidden = false
            }
        }
    }
}

// MARK: - Models

extension PlaceSelectorView {
    enum Section: Hashable {
        case places
    }

    enum Item: Hashable {
        case place(Place, isSelected: Bool)

        static func == (lhs: Item, rhs: Item) -> Bool {
            switch (lhs, rhs) {
            case (.place(let l, let ls), .place(let r, let rs)):
                return l.contentId == r.contentId && ls == rs
            }
        }

        func hash(into hasher: inout Hasher) {
            switch self {
            case .place(let place, let isSelected):
                hasher.combine(place.contentId)
                hasher.combine(isSelected)
            }
        }
    }
}
