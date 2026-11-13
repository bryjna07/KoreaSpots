//
//  FestivalDetailView.swift
//  KoreaSpots
//
//  Created by YoungJin on 11/13/26.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import SnapKit
import Then
import SkeletonView

final class FestivalDetailView: BaseView {

    // MARK: - UI Components
    lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout(sections: []))
    let refreshControl = UIRefreshControl()

    // MARK: - Properties
    lazy var dataSource = createDataSource()

    // MARK: - Public Methods
    func endRefreshing() {
        refreshControl.endRefreshing()
    }

    func showSkeleton() {
        collectionView.showAnimatedGradientSkeleton()
    }

    func hideSkeleton() {
        collectionView.hideSkeleton()
    }

    func updateLayout(with sections: [FestivalDetailSectionModel]) {
        collectionView.setCollectionViewLayout(createLayout(sections: sections), animated: false)
    }
}

// MARK: - BaseView Methods
extension FestivalDetailView {

    override func configureHierarchy() {
        addSubview(collectionView)
    }

    override func configureLayout() {
        collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    override func configureView() {
        super.configureView()

        collectionView.do {
            $0.backgroundColor = .backGround
            $0.showsVerticalScrollIndicator = false
            $0.contentInsetAdjustmentBehavior = .automatic
            $0.isSkeletonable = true
            $0.refreshControl = refreshControl
        }

        collectionView.register(cell: PlaceImageCell.self, forCellWithReuseIdentifier: PlaceImageCell.reuseIdentifier)
        collectionView.register(cell: FestivalHeaderCell.self, forCellWithReuseIdentifier: FestivalHeaderCell.reuseIdentifier)
        collectionView.register(cell: FestivalInfoRowCell.self, forCellWithReuseIdentifier: FestivalInfoRowCell.reuseIdentifier)
        collectionView.register(cell: PlaceDescriptionCell.self, forCellWithReuseIdentifier: PlaceDescriptionCell.reuseIdentifier)
        collectionView.register(cell: PlaceLocationCell.self, forCellWithReuseIdentifier: PlaceLocationCell.reuseIdentifier)
        collectionView.register(header: SectionHeaderView.self, reuseIdentifier: SectionHeaderView.reuseIdentifier)
    }
}

// MARK: - DataSource
extension FestivalDetailView {

    func createDataSource() -> RxCollectionViewSectionedAnimatedDataSource<FestivalDetailSectionModel> {
        return RxCollectionViewSectionedAnimatedDataSource<FestivalDetailSectionModel>(
            configureCell: { dataSource, collectionView, indexPath, item in
                switch item {
                case .image(let image):
                    let cell = collectionView.dequeue(cell: PlaceImageCell.self, for: indexPath)
                    cell.configure(with: image.originImageURL)
                    return cell

                case .header(let info):
                    let cell = collectionView.dequeue(cell: FestivalHeaderCell.self, for: indexPath)
                    cell.configure(with: info)
                    return cell

                case .infoRow(let row):
                    let cell = collectionView.dequeue(cell: FestivalInfoRowCell.self, for: indexPath)
                    cell.configure(with: row)
                    return cell

                case .description(let text):
                    let cell = collectionView.dequeue(cell: PlaceDescriptionCell.self, for: indexPath)
                    cell.configure(with: text)
                    // 더보기 버튼 콜백: 셀 높이 재계산
                    cell.onToggleExpand = { [weak collectionView] in
                        collectionView?.performBatchUpdates(nil, completion: nil)
                    }
                    return cell

                case .location(let place):
                    let cell = collectionView.dequeue(cell: PlaceLocationCell.self, for: indexPath)
                    cell.configure(with: place)
                    return cell
                }
            },
            configureSupplementaryView: { dataSource, collectionView, kind, indexPath in
                guard kind == UICollectionView.elementKindSectionHeader else { return UICollectionReusableView() }
                let header = collectionView.dequeue(supplementary: SectionHeaderView.self, ofKind: kind, for: indexPath)
                header.configure(with: dataSource.sectionModels[indexPath.section].section.headerTitle)
                return header
            }
        )
    }
}

// MARK: - Layout
extension FestivalDetailView {

    private typealias Metrics = Constants.UI.CollectionView.PlaceDetail

    func createLayout(sections: [FestivalDetailSectionModel]) -> UICollectionViewCompositionalLayout {
        let configuration = UICollectionViewCompositionalLayoutConfiguration()
        configuration.interSectionSpacing = Metrics.Spacing.section

        return UICollectionViewCompositionalLayout(
            sectionProvider: { [weak self] sectionIndex, _ in
                guard let self, sectionIndex < sections.count else {
                    return self?.listSection(estimatedHeight: 44, spacing: 0, withHeader: false)
                }

                switch sections[sectionIndex].section {
                case .imageCarousel:
                    return self.imageCarouselSection()
                case .header, .description:
                    return self.listSection(estimatedHeight: Metrics.Description.estimatedHeight, spacing: 0, withHeader: false)
                case .info, .program, .contact:
                    return self.listSection(estimatedHeight: 72, spacing: 0, withHeader: true)
                case .location:
                    return self.locationSection()
                }
            },
            configuration: configuration
        )
    }

    private func imageCarouselSection() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0)))
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: .init(
                widthDimension: .fractionalWidth(Metrics.ImageCarousel.itemWidthFraction),
                heightDimension: .absolute(Metrics.ImageCarousel.height)
            ),
            subitems: [item]
        )

        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPaging
        section.interGroupSpacing = Metrics.ImageCarousel.itemSpacing
        section.contentInsets = .init(top: 0, leading: Metrics.ContentInsets.imageCarousel, bottom: 0, trailing: Metrics.ContentInsets.imageCarousel)
        return section
    }

    private func listSection(estimatedHeight: CGFloat, spacing: CGFloat, withHeader: Bool) -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(estimatedHeight)))
        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: .init(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(estimatedHeight)),
            subitems: [item]
        )

        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = spacing
        section.contentInsets = .init(top: 0, leading: Metrics.ContentInsets.standard, bottom: 0, trailing: Metrics.ContentInsets.standard)
        if withHeader { section.boundarySupplementaryItems = [sectionHeader()] }
        return section
    }

    private func locationSection() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(Metrics.Location.height)))
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: .init(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(Metrics.Location.height)),
            subitems: [item]
        )

        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = .init(top: 0, leading: Metrics.ContentInsets.standard, bottom: 0, trailing: Metrics.ContentInsets.standard)
        section.boundarySupplementaryItems = [sectionHeader()]
        return section
    }

    private func sectionHeader() -> NSCollectionLayoutBoundarySupplementaryItem {
        NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: .init(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(Metrics.Header.height)),
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
    }
}
