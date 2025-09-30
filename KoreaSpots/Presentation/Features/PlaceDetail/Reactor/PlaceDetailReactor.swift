//
//  PlaceDetailReactor.swift
//  KoreaSpots
//
//  Created by YoungJin on 9/29/25.
//

import Foundation
import ReactorKit
import RxSwift

final class PlaceDetailReactor: Reactor {

    enum Action {
        case viewDidLoad
        case refresh
        case imagePageChanged(Int)
    }

    enum Mutation {
        case setLoading(Bool)
        case setPlaceDetail(PlaceDetail)
        case setError(String?)
        case setCurrentImageIndex(Int)
    }

    struct State {
        var isLoading: Bool = false
        var placeDetail: PlaceDetail?
        var error: String?
        var currentImageIndex: Int = 0
        var sections: [PlaceDetailSectionModel] = []
    }

    let initialState = State()
    private let place: Place
    private let tourRepository: TourRepository
    private let fetchLocationBasedPlacesUseCase: FetchLocationBasedPlacesUseCase

    init(
        place: Place,
        tourRepository: TourRepository,
        fetchLocationBasedPlacesUseCase: FetchLocationBasedPlacesUseCase
    ) {
        self.place = place
        self.tourRepository = tourRepository
        self.fetchLocationBasedPlacesUseCase = fetchLocationBasedPlacesUseCase
    }

    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewDidLoad:
            return Observable.concat([
                Observable.just(.setLoading(true)),
                fetchPlaceDetail(),
                Observable.just(.setLoading(false))
            ])

        case .refresh:
            return Observable.concat([
                Observable.just(.setLoading(true)),
                fetchPlaceDetail(),
                Observable.just(.setLoading(false))
            ])

        case let .imagePageChanged(index):
            return Observable.just(.setCurrentImageIndex(index))
        }
    }

    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state

        switch mutation {
        case let .setLoading(isLoading):
            newState.isLoading = isLoading

        case let .setPlaceDetail(placeDetail):
            newState.placeDetail = placeDetail
            newState.error = nil
            newState.sections = buildSections(placeDetail: placeDetail)

        case let .setError(error):
            newState.error = error

        case let .setCurrentImageIndex(index):
            newState.currentImageIndex = index
        }

        return newState
    }
}

// MARK: - Private Methods
private extension PlaceDetailReactor {

    func fetchPlaceDetail() -> Observable<Mutation> {
        return Observable.combineLatest(
            fetchDetailInfo(),
            fetchDetailImages(),
            fetchNearbyPlaces()
        )
        .map { detailInfo, images, nearbyPlaces -> PlaceDetail in
            let operatingInfo = detailInfo.operatingInfo
            return PlaceDetail(
                place: self.place,
                images: images,
                operatingInfo: operatingInfo,
                nearbyPlaces: nearbyPlaces
            )
        }
        .map { placeDetail -> Mutation in
            .setPlaceDetail(placeDetail)
        }
        .catch { error in
            Observable.just(.setError(LocalizedKeys.Error.fetchPlaceDetailFailed.localized))
        }
    }

    func fetchDetailInfo() -> Observable<(place: Place, operatingInfo: OperatingInfo)> {
        // detailCommon2와 detailIntro2를 결합하여 상세 정보 가져오기
        return Observable.combineLatest(
            tourRepository.getPlaceDetail(contentId: place.contentId, contentTypeId: place.contentTypeId).asObservable(),
            tourRepository.getPlaceOperatingInfo(contentId: place.contentId, contentTypeId: place.contentTypeId).asObservable()
        )
        .map { placeDetail, operatingInfo -> (place: Place, operatingInfo: OperatingInfo) in
            print("✅ PlaceDetailReactor: Got operating info - useTime: \(operatingInfo.useTime ?? "nil")")
            return (place: placeDetail, operatingInfo: operatingInfo)
        }
    }

    func fetchDetailImages() -> Observable<[PlaceImage]> {
        return tourRepository.getPlaceImages(contentId: place.contentId, numOfRows: 10, pageNo: 1)
            .asObservable()
            .catch { _ in Observable.just([]) }
    }

    func fetchNearbyPlaces() -> Observable<[Place]> {
        guard let latitude = place.mapY, let longitude = place.mapX else {
            return Observable.just([])
        }

        let input = FetchLocationBasedPlacesInput(
            latitude: latitude,
            longitude: longitude,
            radius: 1000,
            maxCount: 10,
            sortOption: .distance
        )

        return fetchLocationBasedPlacesUseCase
            .execute(input)
            .asObservable()
            .map { places in
                // 현재 Place는 제외
                places.filter { $0.contentId != self.place.contentId }
            }
            .catch { _ in Observable.just([]) }
    }

    func buildSections(placeDetail: PlaceDetail) -> [PlaceDetailSectionModel] {
        var sections: [PlaceDetailSectionModel] = []

        // 이미지 캐러셀 섹션
        if placeDetail.hasImages {
            let imageItems = placeDetail.images.map { PlaceDetailSectionItem.image($0) }
            sections.append(PlaceDetailSectionModel(section: .imageCarousel, items: imageItems))
        }

        // 기본 정보 섹션
        sections.append(PlaceDetailSectionModel(section: .basicInfo, items: [.basicInfo(placeDetail.place)]))

        // 설명 섹션 (overview가 있는 경우)
        if let overview = placeDetail.place.overview, !overview.isEmpty {
            sections.append(PlaceDetailSectionModel(section: .description, items: [.description(overview)]))
        }

        // 운영 정보 섹션
        if placeDetail.hasOperatingInfo {
            sections.append(PlaceDetailSectionModel(section: .operatingInfo, items: [.operatingInfo(placeDetail.operatingInfo!)]))
        }

        // 위치 정보 섹션
        if placeDetail.place.mapX != nil && placeDetail.place.mapY != nil {
            sections.append(PlaceDetailSectionModel(section: .location, items: [.location(placeDetail.place)]))
        }

        // 주변 명소 섹션
        if placeDetail.hasNearbyPlaces {
            let nearbyItems = placeDetail.nearbyPlaces.map { PlaceDetailSectionItem.nearbyPlace($0) }
            sections.append(PlaceDetailSectionModel(section: .nearbyPlaces, items: nearbyItems))
        }

        return sections
    }
}