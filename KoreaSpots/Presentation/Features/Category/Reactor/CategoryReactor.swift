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
        case cat2(LclsCategory)

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
        case reloadCategories // Cat3 데이터 로드 완료 후 재로드
        case selectCat2(LclsCategory) // 왼쪽 사이드바 탭
        case scrollToCat2(LclsCategory) // 오른쪽 스크롤로 인한 사이드바 하이라이트
        case toggleExpandSection(LclsCategory) // 더보기 버튼
        case selectArea(AreaCode?)
        case selectSigungu(Int?)
    }

    // MARK: - Mutation
    enum Mutation {
        case setDataLoaded(Bool)
        case setSelectedCat2(LclsCategory)
        case setHighlightedCat2(LclsCategory) // 스크롤로 인한 하이라이트
        case toggleSectionExpanded(LclsCategory)
        case setScrollToCat2(LclsCategory)
        case clearScrollTarget
        case setSelectedArea(AreaCode?)
        case setSelectedSigungu(Int?)
    }

    // MARK: - State
    struct State {
        var isDataLoaded: Bool = false
        var selectedCat2: LclsCategory = LclsCategory(rawValue: "NA01") // 기본: 자연관광지
        var highlightedCat2: LclsCategory = LclsCategory(rawValue: "NA01") // 스크롤로 인한 하이라이트
        var expandedSections: Set<LclsCategory> = [] // 펼쳐진 섹션들
        var scrollToCat2: LclsCategory? // 스크롤 타겟
        var selectedArea: AreaCode? // 선택된 지역
        var selectedSigungu: Int? // 선택된 시군구

        // Computed
        var categories: [CategoryDetail] {
            // Cat3 데이터가 로드되기 전에는 빈 배열 반환
            guard CodeBookStore.Lcls.isLoaded else { return [] }
            return CategoryDetail.allCategories()
        }

        var sidebarItems: [LclsCategory] {
            // 중복 제거: 순서 유지하면서 첫 번째 등장만 유지
            var seen = Set<LclsCategory>()
            return categories.compactMap { detail in
                guard !seen.contains(detail.cat2) else { return nil }
                seen.insert(detail.cat2)
                return detail.cat2
            }
        }

        func visibleCat3Items(for cat2: LclsCategory) -> [String] {
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

        func shouldShowExpandButton(for cat2: LclsCategory) -> Bool {
            guard let category = categories.first(where: { $0.cat2 == cat2 }) else {
                return false
            }
            return category.cat3Items.count > 6
        }

        func isExpanded(cat2: LclsCategory) -> Bool {
            return expandedSections.contains(cat2)
        }
    }

    let initialState = State()

    // MARK: - Mutation
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewDidLoad:
            // Cat3 데이터가 이미 로드되어 있으면 바로 시작
            if CodeBookStore.Lcls.isLoaded {
                return .just(.setDataLoaded(true))
            }
            // 로드되지 않았으면 대기 후 재확인 (최대 1초)
            return Observable<Int>.interval(.milliseconds(100), scheduler: MainScheduler.instance)
                .take(10) // 최대 1초 (100ms * 10)
                .flatMap { _ -> Observable<Mutation> in
                    if CodeBookStore.Lcls.isLoaded {
                        return .just(.setDataLoaded(true))
                    }
                    return .empty()
                }
                .take(1) // 첫 번째 성공만 받음

        case .reloadCategories:
            return .just(.setDataLoaded(true))

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
        case .setDataLoaded(let isLoaded):
            newState.isDataLoaded = isLoaded

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

///TODO:- 카테고리 스크롤 관련 문제 - 추후 업데이트
