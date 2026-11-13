# Code Review (Opus, 2026-11-13)

Scope: whole-project review on branch `review/opus-audit` (renamed to `fix/review-findings` once fixes landed; from `refactor/structure` @ `d7540c3`). Read in full: Application (3), DI, Navigator, AppStateManager, APIErrorType, MoyaProviderFactory, TourAPI+Builder, TourRepositoryImpl (+Places, +ErrorHandling), FavoriteRepositoryImpl, parts of TourLocalDataSourceImpl / TripLocalDataSourceImpl, DateFormatterUtil, FetchFestivalUseCase, BaseViewController, Category (VC, Reactor), PlaceDetailReactor, transform() in Search/PlaceList/Favorite reactors. The rest was checked by grep for patterns. No code was changed.

Verdict legend: **CONFIRMED** = verified by reading code plus a run/script; **CODE** = follows from the code, not run in the app; **VERIFY** = plausible, needs a simulator/device check.

## Strengths (keep, and mention in the portfolio)
- Clean layering with protocol + `*Impl` at every boundary; constructor injection from one `AppContainer` -> every Reactor/UseCase can get mocks in tests.
- Realm thread confinement done right: a fresh `Realm()` per operation on a background scheduler, mapped to domain structs before leaving the thread. No Realm object reaches the UI.
- Explicit degraded state (`DataSourceMode`: normal / mockFallback / offline) instead of silent failure; writes blocked while sample data is shown.
- Data-driven code books (`lcls_codes.json`, `themes.json`) isolate the app from Tour API taxonomy changes.
- Modern UIKit APIs: Diffable data sources, `CellRegistration` / `SupplementaryRegistration`, Compositional Layout with pinned headers, `UINavigationBarAppearance`.
- ReactorKit used consistently; one-shot events use `@Pulse`.
- Decision log (`architecture-decisions.md`) with trade-offs.

## Findings (most severe first)

### High
1. **Mock mode never recovers during a session** (CODE). `AppStateManager.swift:40` returns to `.normal` only from `.offline`; nothing leaves `.mockFallback`. One transient 5xx -> the rest of the session shows `[예시]` data and blocks favorites/trip writes. The alert in `BaseViewController.swift:53` promises "서버 복구 시 자동으로 정확한 데이터가 표시됩니다", which is not true. Fix: probe the real API periodically (or on foreground / next request) while in mock mode and call `enterNormalMode()` on success. Also update decision #7.
2. **Reactor retain cycle in `transform(mutation:)`** (CODE, confirm with Memory Graph). `SearchReactor.swift:~419` and `PlaceListReactor.swift:~260` capture `self` strongly in `flatMap`. ReactorKit keeps the state stream in the reactor's own `disposeBag`, so reactor -> bag -> subscription -> closure -> reactor. Both screens are pushed repeatedly, so one reactor (plus its data) is leaked per visit. `checkFavoriteStatus` `.map { self.currentState }` has the same capture. Fix: `[weak self]` (ReactorKit README pattern). Check: add `deinit { print }` or use Xcode Memory Graph after push/pop.
3. **Fixed-format `DateFormatter` without POSIX locale/Gregorian calendar** (CONFIRMED by script). `DateFormatterUtil.swift:13` (`yyyyMMdd`, used for API params and festival "ongoing" checks), `SceneDelegate.swift:40`. With the iOS calendar set to Buddhist/Japanese the app sends `25691107` / `00081107` instead of `20261107` -> festival queries return nothing. Apple docs ("Working With Fixed Format Date Representations"): set `locale = en_US_POSIX` (and an explicit calendar/time zone, here Gregorian + `Asia/Seoul` since the API is KST). Display formatters (`M.d`, `yyyy.MM.dd`, `HH:mm`) should use `setLocalizedDateFormatFromTemplate` (also needed for localization later).
4. **Location cache hit ignores `contentTypeId` and count** (VERIFY). `TourLocalDataSourceImpl.swift:101` filters only by a lat/lng box; `TourRepositoryImpl+Places.swift:58` treats any non-empty result as a hit. Places cached from festivals/area lists inside the box are returned, even 1 item, and regardless of the requested type (PlaceDetail asks for `contentTypeId: 12`). Expected symptom: "nearby" shows mixed types or too few items. Fix: filter by `contentTypeId`, require `>= numOfRows`, or key the cache by query.

### Medium
5. **Quota/key errors in a 200 response body are not classified** (VERIFY against a real quota response). `APIErrorType` comments mention result codes 22/30/31, but only HTTP status is checked. No `validationType`/`filterSuccessfulStatusCodes`, so the `.statusCode` case (`APIErrorType.swift:72`) is unreachable; everything arrives as `.objectMapping`. data.go.kr is known to return gateway errors as HTTP 200 + XML -> `.unknown` -> empty list, no mock fallback. This is the main scenario the fallback was built for.
6. **API key written to device logs in release** (CODE). `MoyaProviderFactory.swift:15` adds `NetworkLoggerPlugin(.verbose)` unconditionally; the request URL contains `serviceKey`. Wrap in `#if DEBUG`.
7. **Every `BaseViewController` presents the mock alert** (CODE). `BaseViewController.swift:34`: all loaded VCs (4 tab roots + pushed ones) observe `.mockModeEntered`; off-screen ones fail with "not in the window hierarchy", and which one succeeds is arbitrary. Present once from a single owner (TabBarController/SceneDelegate, topmost presented VC).
8. **Favoriting may overwrite cached detail** (VERIFY). `FavoriteRepositoryImpl.swift:30` builds `PlaceR(place:)` from a list item and calls `add(update: .modified)`, which writes every property, so it can null out `overview`/detail fields and reset `cachedAt` of an existing row. Update `isFavorite` on the existing object instead (as `removeFavorite` does).
9. **Fire-and-forget cache writes into a singleton's bag** (CODE). `TourRepositoryImpl.swift:77`, `+Places.swift:80`: `disposed(by: self?.disposeBag ?? DisposeBag())` on an app-lifetime repository -> the bag only grows; errors are dropped. Use `.andThen`/`flatMap` into the returned stream, or subscribe without a bag (Completable finishes) and log errors.
10. **Category screen** (CODE; part of the scroll-sync task): `scrollToCat2` + `distinctUntilChanged` blocks re-tapping the same item (`CategoryViewController.swift:238`); `scrollToItem(.top)` puts row 1 under the pinned header; 0.5 s flag timer instead of `scrollViewDidEndScrollingAnimation`; the sidebar does not scroll to keep the highlight visible. Also VERIFY: "더보기/접기" header title after toggle (diffable apply does not reconfigure existing supplementary views).
17. **Detail cache hit on list-only rows** (VERIFY at runtime; found while planning #8). List/location/festival saves create `PlaceR` rows with `cachedAt = now`; `getPlaceDetail` (`+Detail.swift:31`) treats any fresh row as a detail hit, so a place seen in a list today opens without `overview`/detail fields. `PlaceR.update(from:)` also overwrites a cached `overview` with nil on every list save. Root cause shared with #8: summary and detail data share one row and one `cachedAt`. Fix: keep `overview` when the incoming value is nil; require `overview != nil` for a detail hit (no schema change; a separate `detailCachedAt` would need a migration).
18. **Mock detail is written to the cache** (CODE). `+Detail.swift:57` saves the mock fallback via `savePlaceDetail`, so mock data stays visible after the server recovers (until the 4 AM refresh). Do not cache mock data.

### Low / structure
11. **Layering is inconsistent.** 4 reactors use repositories directly (`PlaceDetail`, `TripEditor`, `PlaceSelector`, `TripDetail`) while others go through UseCases. `PlaceDetailReactor` holds business logic (course merge, phone regex) that belongs in a `FetchPlaceDetailUseCase`. `FavoriteRepositoryImpl` writes Realm directly but reads through `TourLocalDataSource`. Pick one rule and document it (e.g. "Reactors only see UseCases").
12. **API vocabulary in Domain**: `arrange: String` ("O"/"R"/"Q"/"S") in `TourRepository`; `cat1~3` names (accepted in decision #3). An `enum SortOption` mapped in Data would make the protocol self-describing.
13. **Dead/odd code**: `filterChangedPlaces` unused (`+ErrorHandling.swift:65`); `createRealm()` opens Realm twice (`TourLocalDataSourceImpl.swift:22`); `CategoryReactor.reloadCategories` never sent; `getFavorites()` emits the initial value twice (manual `onNext` + `.initial`); `MockDataProvider` has no reference found (check before removing); duplicated cat3 parsing in mock/normal branches of `getAreaBasedPlaces`.
14. **Code book race** (VERIFY, low): `CategoryReactor` polls `CodeBookStore.Lcls.isLoaded` for 1 s; if loading takes longer, the screen stays empty with no retry. Prefer an observable "loaded" signal.
15. **Navigator**: the suspected `present` recursion does **not** happen (CONFIRMED with a minimal Swift reproduction: the UIKit method wins overload resolution). The `present`/`dismiss` defaults are redundant and can be removed. Update `architecture.md` and roadmap.
16. Realm on GCD threads: Realm docs recommend `autoreleasepool` around background-thread Realm work to avoid version pinning (file growth). Low priority; `shouldCompactOnLaunch` partly covers it.

## Suggested order (one change per commit)
1. #6 logger `#if DEBUG` (1 line, safe).
2. #3 date formatters (POSIX + Gregorian + KST for API; templates for display).
3. #2 `[weak self]` in transforms (confirm the leak first with Memory Graph = good blog/interview story).
4. #1 + #7 mock-mode recovery and a single alert owner.
5. #5 parse the error body (needs one captured real error response).
6. #4, #8, #9, #17, #18 cache correctness (order: #8, #17, #18, #9, #4).
7. #10 inside the category scroll-sync task.
8. #11-#16 cleanup when touching those files.
