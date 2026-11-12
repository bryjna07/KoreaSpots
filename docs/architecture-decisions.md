# Architecture Decisions

Log of architecture-relevant decisions made during the portfolio rework (branch `refactor/structure`). Each entry: context -> decision -> why -> interview talking point. Newest last. Overview lives in `architecture.md`.

## 1. Domain must not depend on Data (TourRepositoryError)
- **Context**: `TourRepositoryError` was declared at the bottom of `TourRepositoryImpl.swift` (Data layer), but `PlaceDetailReactor` (Presentation) referenced it.
- **Decision**: Moved to `Core/Domain/Repositories/TourRepositoryError.swift`. Pure file move, no behavior change (commit `1ee6f38`).
- **Why**: Dependency rule: Presentation -> Domain <- Data. A type that callers need to see belongs next to the protocol it belongs to, not in the implementation file.
- **Talking point**: "Dependency Inversion: both outer layers depend on Domain; Domain depends on nothing."

## 2. Split RecentKeywordRepository out of TourRepository
- **Context**: `TourRepository` mixed remote tour data + cache with local user data (recent search keywords, favorites). The 4 keyword methods were pure pass-through to `TourLocalDataSource`.
- **Decision**: New protocol `RecentKeywordRepository` + `RecentKeywordRepositoryImpl` (same shape as `FavoriteRepositoryImpl`, shares `TourLocalDataSource`). `ManageRecentKeywordsUseCase` (3 use cases) now depends on it; `SearchPlacesUseCase` takes both repositories (search via `tourRepository`, save keyword via `recentKeywordRepository`). Wired in `AppContainer`.
- **Why**: Single Responsibility + Interface Segregation. A use case should only see the methods it needs; `TourRepository` shrinks to tour API/cache concerns; easier to mock in tests.
- **Trade-off**: One more class and one more init parameter for `SearchPlacesUseCase`. Accepted: the dependency is explicit instead of hidden inside a fat protocol.
- **Talking point**: "I split a god-repository along responsibility lines and let the compiler find every call site."

## 3. Classification switch: code tables owned by the app (lclsSystm + themes.json)
- **Context**: TourAPI 2026 replaced `cat1/cat2/cat3` with `lclsSystm1~3` and legal-dong region codes. The old enums (`Cat1`, `Cat2`) and `cat3_codes.json` were hard-coded to the old scheme.
- **Decision**:
  - Category code book is data (`lcls_codes.json`, loaded by `CodeBookStore`), not Swift enums.
  - Home "themes" are app-owned data: `Resources/themes.json` (12 themes, matched by lclsSystm code prefix) read through `ThemeCatalog`. The product concept (theme) is separated from the API's taxonomy.
  - Multi-code buttons (e.g. performance/exhibition = `EV02,VE07`): the repository fans out one request per code, merges, and dedupes by `contentId`.
  - Swift parameter names `cat1~3` / `areaCode` kept; only their meaning changed, to avoid a huge rename diff.
- **Why**: When the upstream API changes taxonomy again, the fix is a JSON edit rather than a code change. Keeping names avoids touching every call site in a no-test codebase.
- **Talking point**: "Data-driven configuration over hard-coded enums for things the backend owns; adapter layer isolates the app from API churn."

## 4. Realm schema: one migration version for unreleased changes
- **Context**: Released 1.1.1 is schema v2. Several unreleased changes (region conversion, `PlaceR.lclsSystm3` added, `PlaceR.cat1~3` removed) landed over multiple commits.
- **Decision**: Merge them into a single `schemaVersion = 3`. Realm handles added/removed properties automatically; only the region-code conversion needs a migration block (`RealmRegionMigration`).
- **Why**: Users upgrade from 1.1.1 (v2) directly to the next release, so intermediate versions never exist on their devices. Fewer migration branches = fewer bugs.
- **Risk / TODO**: v2 -> v3 migration is not yet verified with real 1.1.1 data on a device. Do this before release.
- **Talking point**: "Only released schemas need migration steps; I squashed dev-only versions."

## 5. Single owner for favorites
- **Context**: `TourRepository` and `FavoriteRepository` both exposed favorites. `TourRepository.toggleFavorite(contentId:)` had no callers; `getFavoritePlaces()` was used only by `PlaceSelectorReactor`.
- **Decision**: Removed both from `TourRepository`; added `getFavoritePlaces() -> Single<[Place]>` to `FavoriteRepository` (same DataSource call, so same ordering and one-shot semantics). Removed the unused `TourLocalDataSource.toggleFavorite(contentId:)`.
- **Why**: One concept, one owner. Replacing it with `getFavorites()` would silently change behavior (live-observed Observable, no sorting), so the equivalent method was added instead.

## 6. When to split a large file (and when not to)
- **Done**: `TourRepositoryImpl` (745 -> 106 + 5 files by domain), `TripEditorView` (760 -> 326 + DataSource / DragDrop / `EditorPhotoCell`), `TripRecordViewController` (588 -> 466 + `+Delegate`). Each: verbatim move via extensions, build + line-multiset diff by `refactor-reviewer`.
- **Skipped on purpose**: `SearchReactor` (539) is one cohesive Reactor (Action/Mutation/State/mutate/reduce belong together). `TripRecordView` (547) is a single view whose layout is already in its own extension.
- **Self-correction**: my first pass also split `TripRecordViewController+Bind` (a 275-line `bind` moved wholesale) and `TripEditorView+Layout` (63 lines used by one class). Neither separated a responsibility; both only added files to jump between and relaxed `private`. Merged back; `private` restored on the members that no longer cross files (access relaxations: 7 -> 3 and 11 -> 9).
- **Rule**: split only when a file mixes responsibilities (several domains, a view plus its protocol conformances, a nested reusable type). Line count alone is not a reason; an unnecessary split makes maintenance harder.
- **Cost**: members used across files lose `private` (internal instead). Only what the compiler required was relaxed (checked by reverting speculative ones).

## 7. Mock data as an outage fallback (not a test double)
- **Context**: The Tour API (data.go.kr) has a daily quota and occasional server errors. An error screen on every list would leave the app unusable during an outage.
- **Decision**: `MockTourRemoteDataSource` (bundled `Resources/Mock/*.json`) is a production fallback. `AppStateManager` switches `DataSourceMode` to `mockFallback` on quota/server errors; `TourRepositoryImpl` then skips the cache and serves mock data. Mock titles get an `[예시]` prefix, a one-time `mockModeEntered` notification shows a message ("sample data, may differ from real data"), and `shouldRestrictWriteOperations` blocks writes while mock data is shown.
- **Why**: The UI stays usable and the user is told the data is a sample. The prefix and the write restriction stop sample data from being mistaken for, or saved as, real data (e.g. a mock place in a trip or favorites).
- **Trade-off**: Fallback logic lives in `TourRepositoryImpl` (`mockDataSource` injected next to the remote one) and ~140KB of JSON ships in the app. Accepted: the alternative (error/empty screen) gives a worse outage experience. Not a debug-only feature, so no `#if DEBUG`.
- **Talking point**: "Graceful degradation: the app is explicit about degraded state (`DataSourceMode`) instead of failing silently or hiding the outage."

## Open architecture items
- Cache policy (intent: cut Tour API usage; re-fetch occasionally in case data changed). Actual behavior, verified in code:
  - Place detail: read-time check `PlaceR.needsRefresh()` = refresh once per day after 04:00 KST (not 7 days; the `TourRepositoryImpl` comment says "long TTL").
  - Operating info: read-time `OperatingInfoE.isValid()` = 7 days.
  - `clearExpiredCache` (delete non-favorite places older than 7 days) was storage cleanup only; its call in `AppDelegate` had been commented out (likely after the switch to daily refresh), so it was removed as dead code. Old non-favorite rows are never pruned (DB grows, API usage unaffected). Trips do not reference `PlaceR` (snapshot fields only), so a future cleanup is safe for Trip data.
  - History (commit `fd5b9bd`, 2025-10-23, "API 권장사항에 맞게 1일 1회 갱신"): replaced TTLs (location lists 3h, other lists 1h, place detail 7 days) with one daily refresh at 04:00 KST to follow the Tour API's recommendation; same commit added `modifiedtime` change detection. The reason for 04:00 itself is not documented (likely the data sync window; unverified).
  - Decision needed: keep daily refresh for place detail or move to 7 days. (Unused `isCacheValid(for:ttl:)` was also removed.)
