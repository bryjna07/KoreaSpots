//
//  AppContainer.swift
//  KoreaSpots
//
//  Created by YoungJin on 9/26/25.
//

import Foundation
import Moya

//MARK: - 간단 DI 컨테이너(팩토리/싱글턴 주입)
final class AppContainer {

    static let shared = AppContainer()
    private init() {}

    // MARK: - DataSources
    private lazy var tourRemoteDataSource: TourRemoteDataSource = {
        let provider = MoyaProviderFactory.makeTourProvider()
        return RemoteTourDataSourceImpl(provider: provider)
    }()

    private lazy var tourLocalDataSource: TourLocalDataSource = {
        TourLocalDataSourceImpl()
    }()

    private lazy var tripLocalDataSource: TripLocalDataSource = {
        TripLocalDataSourceImpl()
    }()

    // MARK: - Repositories
    private lazy var tourRepository: TourRepository = {
        TourRepositoryImpl(
            remoteDataSource: tourRemoteDataSource,
            localDataSource: tourLocalDataSource
        )
    }()

    private lazy var tripRepository: TripRepository = {
        TripRepositoryImpl(localDataSource: tripLocalDataSource)
    }()

    private lazy var favoriteRepository: FavoriteRepository = {
        FavoriteRepositoryImpl(localDataSource: tourLocalDataSource)
    }()

    // MARK: - Use Cases
    private lazy var fetchFestivalUseCase: FetchFestivalUseCase = {
        FetchFestivalUseCaseImpl(tourRepository: tourRepository)
    }()

    private lazy var fetchLocationBasedPlacesUseCase: FetchLocationBasedPlacesUseCase = {
        FetchLocationBasedPlacesUseCaseImpl(tourRepository: tourRepository)
    }()

    private lazy var fetchAreaBasedPlacesUseCase: FetchAreaBasedPlacesUseCase = {
        FetchAreaBasedPlacesUseCaseImpl(tourRepository: tourRepository)
    }()

    private lazy var searchPlacesUseCase: SearchPlacesUseCase = {
        SearchPlacesUseCaseImpl(tourRepository: tourRepository)
    }()

    private lazy var getRecentKeywordsUseCase: GetRecentKeywordsUseCase = {
        GetRecentKeywordsUseCaseImpl(tourRepository: tourRepository)
    }()

    private lazy var deleteRecentKeywordUseCase: DeleteRecentKeywordUseCase = {
        DeleteRecentKeywordUseCaseImpl(tourRepository: tourRepository)
    }()

    private lazy var clearAllRecentKeywordsUseCase: ClearAllRecentKeywordsUseCase = {
        ClearAllRecentKeywordsUseCaseImpl(tourRepository: tourRepository)
    }()

    // Trip UseCases
    private lazy var getTripsUseCase: GetTripsUseCase = {
        GetTripsUseCaseImpl(tripRepository: tripRepository)
    }()

    private lazy var getTripStatisticsUseCase: GetTripStatisticsUseCase = {
        GetTripStatisticsUseCaseImpl(tripRepository: tripRepository)
    }()

    private lazy var createTripUseCase: CreateTripUseCase = {
        CreateTripUseCaseImpl(tripRepository: tripRepository)
    }()

    private lazy var updateTripUseCase: UpdateTripUseCase = {
        UpdateTripUseCaseImpl(tripRepository: tripRepository)
    }()

    private lazy var deleteTripUseCase: DeleteTripUseCase = {
        DeleteTripUseCaseImpl(tripRepository: tripRepository)
    }()

    // Favorite UseCases
    private lazy var getFavoritesUseCase: GetFavoritesUseCase = {
        GetFavoritesUseCaseImpl(favoriteRepository: favoriteRepository)
    }()

    private lazy var toggleFavoriteUseCase: ToggleFavoriteUseCase = {
        ToggleFavoriteUseCaseImpl(favoriteRepository: favoriteRepository)
    }()

    private lazy var checkFavoriteUseCase: CheckFavoriteUseCase = {
        CheckFavoriteUseCaseImpl(favoriteRepository: favoriteRepository)
    }()

    private lazy var getFavoriteCountUseCase: GetFavoriteCountUseCase = {
        GetFavoriteCountUseCaseImpl(favoriteRepository: favoriteRepository)
    }()

    // MARK: - Services
    private lazy var locationService: LocationService = {
        LocationManager()
    }()

    // MARK: - Factory Methods

    // MARK: TabBar
    func makeTabBarController() -> TabBarController {
        return TabBarController()
    }

    // MARK: Home
    func makeHomeReactor() -> HomeReactor {
        return HomeReactor(
            fetchFestivalUseCase: fetchFestivalUseCase,
            fetchLocationBasedPlacesUseCase: fetchLocationBasedPlacesUseCase,
            locationService: locationService
        )
    }

    func makeHomeViewController() -> HomeViewController {
        let reactor = makeHomeReactor()
        let viewController = HomeViewController()
        viewController.reactor = reactor
        return viewController
    }

    // MARK: PlaceDetail
    func makePlaceDetailViewController(place: Place) -> PlaceDetailViewController {
        let reactor = PlaceDetailReactor(
            place: place,
            tourRepository: tourRepository,
            fetchLocationBasedPlacesUseCase: fetchLocationBasedPlacesUseCase,
            checkFavoriteUseCase: checkFavoriteUseCase,
            toggleFavoriteUseCase: toggleFavoriteUseCase
        )
        let viewController = PlaceDetailViewController()
        viewController.reactor = reactor
        return viewController
    }

    // MARK: Category
    func makeCategoryReactor() -> CategoryReactor {
        return CategoryReactor()
    }

    func makeCategoryViewController() -> CategoryViewController {
        let reactor = makeCategoryReactor()
        let viewController = CategoryViewController()
        viewController.reactor = reactor
        return viewController
    }

    // MARK: Favorite
    func makeFavoriteReactor() -> FavoriteReactor {
        return FavoriteReactor(
            getFavoritesUseCase: getFavoritesUseCase,
            toggleFavoriteUseCase: toggleFavoriteUseCase,
            getFavoriteCountUseCase: getFavoriteCountUseCase
        )
    }

    func makeFavoriteViewController() -> FavoriteViewController {
        let reactor = makeFavoriteReactor()
        let viewController = FavoriteViewController()
        viewController.reactor = reactor
        return viewController
    }

    // MARK: PlaceList
    func makePlaceListReactor(
        initialArea: AreaCode? = nil,
        contentTypeId: Int? = nil,
        cat1: String? = nil,
        cat2: String? = nil,
        cat3: String? = nil
    ) -> PlaceListReactor {
        return PlaceListReactor(
            initialArea: initialArea,
            contentTypeId: contentTypeId,
            cat1: cat1,
            cat2: cat2,
            cat3: cat3,
            fetchAreaBasedPlacesUseCase: fetchAreaBasedPlacesUseCase,
            checkFavoriteUseCase: checkFavoriteUseCase,
            toggleFavoriteUseCase: toggleFavoriteUseCase
        )
    }

    func makePlaceListViewController(
        initialArea: AreaCode? = nil,
        contentTypeId: Int? = nil,
        cat1: String? = nil,
        cat2: String? = nil,
        cat3: String? = nil
    ) -> PlaceListViewController {
        let reactor = makePlaceListReactor(
            initialArea: initialArea,
            contentTypeId: contentTypeId,
            cat1: cat1,
            cat2: cat2,
            cat3: cat3
        )
        let viewController = PlaceListViewController()
        viewController.reactor = reactor
        return viewController
    }

    // MARK: TripRecord
    func makeTripRecordReactor() -> TripRecordReactor {
        return TripRecordReactor(
            getTripsUseCase: getTripsUseCase,
            getTripStatisticsUseCase: getTripStatisticsUseCase,
            deleteTripUseCase: deleteTripUseCase
        )
    }

    func makeTripRecordViewController() -> TripRecordViewController {
        let reactor = makeTripRecordReactor()
        let viewController = TripRecordViewController()
        viewController.reactor = reactor
        return viewController
    }

    // MARK: TripEditor
    func makeTripEditorReactor(trip: Trip?) -> TripEditorReactor {
        return TripEditorReactor(
            trip: trip,
            createTripUseCase: createTripUseCase,
            updateTripUseCase: updateTripUseCase,
            tourRepository: tourRepository
        )
    }

    func makeTripEditorViewController(trip: Trip?) -> TripEditorViewController {
        let reactor = makeTripEditorReactor(trip: trip)
        let viewController = TripEditorViewController(reactor: reactor, appContainer: self)
        return viewController
    }

    // MARK: PlaceSelector
    func makePlaceSelectorReactor(
        maxSelectionCount: Int,
        preSelectedPlaceIds: [String]
    ) -> PlaceSelectorReactor {
        return PlaceSelectorReactor(
            tourRepository: tourRepository,
            maxSelectionCount: maxSelectionCount,
            preSelectedPlaceIds: preSelectedPlaceIds
        )
    }

    func makePlaceSelectorViewController(
        maxSelectionCount: Int = 20,
        preSelectedPlaceIds: [String] = [],
        onConfirm: @escaping ([String]) -> Void
    ) -> PlaceSelectorViewController {
        let reactor = makePlaceSelectorReactor(
            maxSelectionCount: maxSelectionCount,
            preSelectedPlaceIds: preSelectedPlaceIds
        )
        let viewController = PlaceSelectorViewController(
            reactor: reactor,
            maxSelectionCount: maxSelectionCount,
            preSelectedPlaceIds: preSelectedPlaceIds,
            onConfirm: onConfirm
        )
        return viewController
    }

    // MARK: Search
    func makeSearchReactor() -> SearchReactor {
        return SearchReactor(
            searchPlacesUseCase: searchPlacesUseCase,
            getRecentKeywordsUseCase: getRecentKeywordsUseCase,
            deleteRecentKeywordUseCase: deleteRecentKeywordUseCase,
            clearAllRecentKeywordsUseCase: clearAllRecentKeywordsUseCase,
            checkFavoriteUseCase: checkFavoriteUseCase,
            toggleFavoriteUseCase: toggleFavoriteUseCase
        )
    }

    func makeSearchViewController() -> SearchViewController {
        let reactor = makeSearchReactor()
        let viewController = SearchViewController()
        viewController.reactor = reactor
        return viewController
    }
}
