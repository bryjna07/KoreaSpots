# Architecture

## Pattern
UIKit + ReactorKit (MVVM-like) + clean layering. No Coordinator.

```
Presentation (VC/View/Reactor)  ->  Domain (UseCase, Repository protocol, Entity)  <-  Data (RepositoryImpl, DataSource, DTO, Mapper)
```

## DI
`Application/DI/AppContainer.swift` - hand-written lazy singleton. Builds DataSources -> Repositories -> UseCases, exposes `makeXxxViewController()` factories.

## Navigation
`Core/Navigation/Navigator.swift` - `Navigator` protocol adopted by view controllers. Unimplemented: MapViewController, FestivalDetailViewController (TODO at lines ~64, 73). Suspect: default `present` may recurse (unverified).

## Data
- Remote: Moya `TourAPI` (`Core/Networking/API/`), `MoyaProviderFactory`.
- Mock: `MockTourRemoteDataSource` serving `Resources/Mock/*.json`.
- `DataSourceMode` (`Core/Common/AppEnvironment.swift`): `normal`, `mockFallback` (API quota/server error), `offline` (`NetworkMonitor`).
- Local: Realm schemas in `Core/Data/Persistence/Schemas/` (`PlaceR`, `TripR`, `RecentSearchKeywordR`, `OperatingInfoE`), `schemaVersion` 2, migration in AppDelegate.
- Code books: `cat3_codes.json`, `sigungu_codes.json` via `CodeBookStore`.

## Features (`Presentation/Features/`)
TabBar (Category, Home, TripRecord, Favorite), Home, Category, PlaceList, Search, PlaceDetail (per-contentType operating-info cells), Favorite, TripRecord (calendar/stats/list), TripEditor, TripDetail (route map, photos, timeline), PlaceSelector.

## Base classes
`Presentation/Base/`: BaseViewController, BaseView, BaseCollectionViewCell, BaseListCell, SkeletonableCell, ReusableView, alert extensions.

## Other
- Font: GwangyangSunshine via `FontManager`.
- Localization: `ko.lproj` only (`en.lproj` empty).
- Large files to split: `TripEditorView` (760 lines), `TripRecordViewController` (588), `TripRecordView` (547), `SearchReactor` (539).
