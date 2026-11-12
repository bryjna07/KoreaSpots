# Architecture

## Pattern
UIKit + ReactorKit (MVVM-like) + clean layering. No Coordinator.

```
Presentation (VC/View/Reactor)  ->  Domain (UseCase, Repository protocol, Entity)  <-  Data (RepositoryImpl, DataSource, DTO, Mapper)
```

## DI
`Application/DI/AppContainer.swift` - hand-written lazy singleton. Builds DataSources -> Repositories -> UseCases, exposes `makeXxxViewController()` factories.

Rationale for layering/DI/schema decisions: `architecture-decisions.md`.

## Navigation
`Core/Navigation/Navigator.swift` - `Navigator` protocol adopted by view controllers. Unimplemented: MapViewController, FestivalDetailViewController (TODO at lines ~64, 73). Suspect: default `present` may recurse (unverified).

## Data
- Remote: Moya `TourAPI` (`Core/Networking/API/`), `MoyaProviderFactory`.
- Mock: `MockTourRemoteDataSource` serving `Resources/Mock/*.json`.
- `DataSourceMode` (`Core/Common/AppEnvironment.swift`): `normal`, `mockFallback` (API quota/server error), `offline` (`NetworkMonitor`).
- Local: Realm schemas in `Core/Data/Persistence/Schemas/` (`PlaceR`, `TripR`, `RecentSearchKeywordR`, `OperatingInfoE`), `schemaVersion` 3 (v3: region codes -> legal-dong codes, `Core/Data/Persistence/Migration/RealmRegionMigration.swift`), migration block in AppDelegate.
- Code books: `Core/Common/CodeBook/` (`TourCodeBook.swift` enums AreaCode/ContentTypeID/Theme12, `CodeBookStore.swift` Ldong/Lcls, `ThemeCatalog.swift`); JSON `ldong_codes.json`, `lcls_codes.json`, `themes.json`, `legacy_region_map.json` in Resources.

## Features (`Presentation/Features/`)
TabBar (Category, Home, TripRecord, Favorite), Home, Category, PlaceList, Search, PlaceDetail (per-contentType operating-info cells), Favorite, TripRecord (calendar/stats/list), TripEditor, TripDetail (route map, photos, timeline), PlaceSelector.

## Base classes
`Presentation/Base/` (+ `Protocols/`: Configurable, ConfigureUI, ReusableView): BaseViewController, BaseView, BaseCollectionViewCell, BaseListCell, SkeletonableCell, ReusableView, alert extensions.

## Other
- Font: GwangyangSunshine via `FontManager`.
- Localization: `ko.lproj` only (`en.lproj` empty).
- Large files to split: `TripEditorView` (760 lines), `TripRecordViewController` (588), `TripRecordView` (547), `SearchReactor` (539).
