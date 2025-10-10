//
//  CategoryReactor.swift
//  KoreaSpots
//
//  Created by YoungJin on 9/30/25.
//

import Foundation
import ReactorKit
import RxSwift

final class CategoryReactor: Reactor {

    // MARK: - SectionType
    enum SectionType: Hashable {
        case cat2(Cat2)

        var id: String {
            switch self {
            case .cat2(let cat2):
                return cat2.rawValue
            }
        }
    }

    // MARK: - Action
    enum Action {
        case viewDidLoad
        case selectCat2(Cat2) // 왼쪽 사이드바 탭
        case scrollToCat2(Cat2) // 오른쪽 스크롤로 인한 사이드바 하이라이트
        case toggleExpandSection(Cat2) // 더보기 버튼
        case selectCat3(Cat3)
        case selectArea(AreaCode?)
        case selectSigungu(Int?)
    }

    // MARK: - Mutation
    enum Mutation {
        case setSelectedCat2(Cat2)
        case setHighlightedCat2(Cat2) // 스크롤로 인한 하이라이트
        case toggleSectionExpanded(Cat2)
        case setScrollToCat2(Cat2)
        case clearScrollTarget
        case setSelectedArea(AreaCode?)
        case setSelectedSigungu(Int?)
    }

    // MARK: - State
    struct State {
        var selectedCat2: Cat2 = .A0101 // 기본: 자연관광지
        var highlightedCat2: Cat2 = .A0101 // 스크롤로 인한 하이라이트
        var expandedSections: Set<Cat2> = [] // 펼쳐진 섹션들
        var scrollToCat2: Cat2? // 스크롤 타겟
        var selectedArea: AreaCode? // 선택된 지역
        var selectedSigungu: Int? // 선택된 시군구

        // Computed
        var categories: [CategoryDetail] {
            return CategoryDetail.allCategories()
        }

        var sidebarItems: [Cat2] {
            // 중복 제거: 순서 유지하면서 첫 번째 등장만 유지
            var seen = Set<Cat2>()
            return categories.compactMap { detail in
                guard !seen.contains(detail.cat2) else { return nil }
                seen.insert(detail.cat2)
                return detail.cat2
            }
        }

        func visibleCat3Items(for cat2: Cat2) -> [Cat3] {
            guard let category = categories.first(where: { $0.cat2 == cat2 }) else {
                return []
            }

            let allItems = category.cat3Items
            if expandedSections.contains(cat2) || allItems.count <= 6 {
                return allItems
            } else {
                return Array(allItems.prefix(6))
            }
        }

        func shouldShowExpandButton(for cat2: Cat2) -> Bool {
            guard let category = categories.first(where: { $0.cat2 == cat2 }) else {
                return false
            }
            return category.cat3Items.count > 6
        }

        func isExpanded(cat2: Cat2) -> Bool {
            return expandedSections.contains(cat2)
        }
    }

    let initialState = State()

    // MARK: - Mutation
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewDidLoad:
            return .empty()

        case .selectCat2(let cat2):
            return .concat([
                .just(.setSelectedCat2(cat2)),
                .just(.setHighlightedCat2(cat2)),
                .just(.setScrollToCat2(cat2)),
                .just(.clearScrollTarget).delay(.milliseconds(100), scheduler: MainScheduler.instance)
            ])

        case .scrollToCat2(let cat2):
            return .just(.setHighlightedCat2(cat2))

        case .toggleExpandSection(let cat2):
            return .just(.toggleSectionExpanded(cat2))

        case .selectCat3:
            // TODO: Cat3 선택 시 장소 목록 화면으로 이동
            return .empty()

        case .selectArea(let area):
            return .just(.setSelectedArea(area))

        case .selectSigungu(let sigungu):
            return .just(.setSelectedSigungu(sigungu))
        }
    }

    // MARK: - Reduce
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state

        switch mutation {
        case .setSelectedCat2(let cat2):
            newState.selectedCat2 = cat2

        case .setHighlightedCat2(let cat2):
            newState.highlightedCat2 = cat2

        case .toggleSectionExpanded(let cat2):
            if newState.expandedSections.contains(cat2) {
                newState.expandedSections.remove(cat2)
            } else {
                newState.expandedSections.insert(cat2)
            }

        case .setScrollToCat2(let cat2):
            newState.scrollToCat2 = cat2

        case .clearScrollTarget:
            newState.scrollToCat2 = nil

        case .setSelectedArea(let area):
            newState.selectedArea = area
            newState.selectedSigungu = nil // 지역 변경 시 시군구 초기화

        case .setSelectedSigungu(let sigungu):
            newState.selectedSigungu = sigungu
        }

        return newState
    }
}
