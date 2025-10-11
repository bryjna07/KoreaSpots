//
//  TripEditorView.swift
//  KoreaSpots
//
//  Created by YoungJin on 10/10/25.
//

import UIKit
import SnapKit
import Then

final class TripEditorView: BaseView {

    // MARK: - Properties

    private var dataSource: UICollectionViewDiffableDataSource<Section, VisitedPlace>!

    // Callbacks
    var onAddPlacesTapped: (() -> Void)?
    var onPlaceSelected: ((IndexPath) -> Void)?

    // MARK: - UI Components

    private let scrollView = UIScrollView()
    private let contentView = UIView()

    let formView = TripFormView()

    private let placesHeaderView = UIView()
    private let placesLabel = UILabel()
    private let addPlacesButton = UIButton(type: .system)

    lazy var collectionView: UICollectionView = {
        let layout = createLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.delegate = self
        cv.isScrollEnabled = false
        return cv
    }()

    let saveButton = UIButton(type: .system)

    // MARK: - ConfigureUI

    override func configureHierarchy() {
        addSubview(scrollView)
        scrollView.addSubview(contentView)

        contentView.addSubview(formView)
        contentView.addSubview(placesHeaderView)
        contentView.addSubview(collectionView)
        contentView.addSubview(saveButton)

        placesHeaderView.addSubview(placesLabel)
        placesHeaderView.addSubview(addPlacesButton)
    }

    override func configureLayout() {
        scrollView.snp.makeConstraints {
            $0.edges.equalTo(safeAreaLayoutGuide)
        }

        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
        }

        formView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
        }

        placesHeaderView.snp.makeConstraints {
            $0.top.equalTo(formView.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(44)
        }

        placesLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.centerY.equalToSuperview()
        }

        addPlacesButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-16)
            $0.centerY.equalToSuperview()
            $0.height.equalTo(32)
        }

        collectionView.snp.makeConstraints {
            $0.top.equalTo(placesHeaderView.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(0)
        }

        saveButton.snp.makeConstraints {
            $0.top.equalTo(collectionView.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.bottom.equalToSuperview().offset(-16)
            $0.height.equalTo(50)
        }
    }

    override func configureView() {
        super.configureView()

        placesLabel.do {
            $0.text = "방문 장소"
            $0.font = .systemFont(ofSize: 18, weight: .bold)
            $0.textColor = .label
        }

        addPlacesButton.do {
            $0.setTitle("+ 추가", for: .normal)
            $0.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        }

        saveButton.do {
            $0.setTitle("저장", for: .normal)
            $0.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
            $0.backgroundColor = .bluePastel
            $0.setTitleColor(.white, for: .normal)
            $0.layer.cornerRadius = 12
        }

        configureDataSource()
        setupBindings()
    }

    // MARK: - Private Methods

    private func setupBindings() {
        addPlacesButton.addTarget(self, action: #selector(addPlacesButtonTapped), for: .touchUpInside)
    }

    @objc private func addPlacesButtonTapped() {
        onAddPlacesTapped?()
    }

    // MARK: - Layout

    private func createLayout() -> UICollectionViewCompositionalLayout {
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
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)
        section.interGroupSpacing = 8

        return UICollectionViewCompositionalLayout(section: section)
    }

    // MARK: - DataSource

    private func configureDataSource() {
        let placeCellRegistration = UICollectionView.CellRegistration<TripPlaceCell, VisitedPlace> { cell, _, place in
            cell.configure(with: place)
        }

        dataSource = UICollectionViewDiffableDataSource<Section, VisitedPlace>(
            collectionView: collectionView
        ) { collectionView, indexPath, place in
            return collectionView.dequeueConfiguredReusableCell(
                using: placeCellRegistration,
                for: indexPath,
                item: place
            )
        }
    }

    // MARK: - Public Methods

    func updateForm(title: String, startDate: Date, endDate: Date, memo: String) {
        formView.configure(title: title, startDate: startDate, endDate: endDate, memo: memo)
    }

    func updatePlaces(_ places: [VisitedPlace]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, VisitedPlace>()
        snapshot.appendSections([.places])
        snapshot.appendItems(places, toSection: .places)
        dataSource.apply(snapshot, animatingDifferences: false)

        // Update collection view height based on content
        let itemHeight: CGFloat = 80
        let spacing: CGFloat = 8
        let totalHeight = CGFloat(places.count) * itemHeight + CGFloat(max(0, places.count - 1)) * spacing

        collectionView.snp.updateConstraints {
            $0.height.equalTo(totalHeight)
        }

        layoutIfNeeded()
    }
}

// MARK: - UICollectionViewDelegate

extension TripEditorView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        onPlaceSelected?(indexPath)
    }
}

// MARK: - Models

extension TripEditorView {
    enum Section: Hashable {
        case places
    }
}
