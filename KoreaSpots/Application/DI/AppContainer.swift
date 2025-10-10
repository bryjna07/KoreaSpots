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

    // MARK: - Configuration
    private var useMockData: Bool {
        return AppEnvironment.shouldUseMockData
    }

    /// 런타임에서 Mock/Real 데이터 소스를 전환하는 메서드
    /// 사용법: AppContainer.shared.setUseMockData(true) // Mock 데이터 사용
    ///        AppContainer.shared.setUseMockData(false) // 실제 API 사용
    func setUseMockData(_ useMock: Bool) {
        AppEnvironment.forceMockData = useMock
        print("🔄 DataSource switched to: \(useMock ? "Mock" : "Real API")")
        print("ℹ️  앱을 재실행하면 새로운 설정이 적용됩니다.")
    }

    // MARK: - DataSources
    private lazy var tourRemoteDataSource: TourRemoteDataSource = {
        if useMockData {
            return MockTourRemoteDataSource()
        } else {
            let provider = MoyaProviderFactory.makeTourProvider(useMock: false)
            return RemoteTourDataSourceImpl(provider: provider)
        }
    }()

    private lazy var tourLocalDataSource: TourLocalDataSource = {
        TourLocalDataSourceImpl()
    }()

    // MARK: - Repositories
    private lazy var tourRepository: TourRepository = {
        TourRepositoryImpl(
            remoteDataSource: tourRemoteDataSource,
            localDataSource: tourLocalDataSource,
            useMockData: useMockData
        )
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
            fetchLocationBasedPlacesUseCase: fetchLocationBasedPlacesUseCase
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
            fetchAreaBasedPlacesUseCase: fetchAreaBasedPlacesUseCase
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

    // MARK: Search
    func makeSearchReactor() -> SearchReactor {
        return SearchReactor(
            searchPlacesUseCase: searchPlacesUseCase,
            getRecentKeywordsUseCase: getRecentKeywordsUseCase,
            deleteRecentKeywordUseCase: deleteRecentKeywordUseCase,
            clearAllRecentKeywordsUseCase: clearAllRecentKeywordsUseCase
        )
    }

    func makeSearchViewController() -> SearchViewController {
        let reactor = makeSearchReactor()
        let viewController = SearchViewController()
        viewController.reactor = reactor
        return viewController
    }
}
