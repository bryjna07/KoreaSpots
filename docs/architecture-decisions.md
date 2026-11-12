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

## Open architecture items
- Cache policy (intent: cut Tour API usage; re-fetch occasionally in case data changed). Actual behavior, verified in code:
  - Place detail: read-time check `PlaceR.needsRefresh()` = refresh once per day after 04:00 KST (not 7 days; the `TourRepositoryImpl` comment says "long TTL").
  - Operating info: read-time `OperatingInfoE.isValid()` = 7 days.
  - `clearExpiredCache` (delete non-favorite places older than 7 days) is storage cleanup only; its call in `AppDelegate` is commented out, so old non-favorite rows are never pruned (DB grows, API usage unaffected).
  - History (commit `fd5b9bd`, 2025-10-23, "API 권장사항에 맞게 1일 1회 갱신"): replaced TTLs (location lists 3h, other lists 1h, place detail 7 days) with one daily refresh at 04:00 KST to follow the Tour API's recommendation; same commit added `modifiedtime` change detection. The reason for 04:00 itself is not documented (likely the data sync window; unverified).
  - Decision needed: keep daily refresh for place detail or move to 7 days; enable or delete `clearExpiredCache`.
- Split `TourRepositoryImpl` (~780 lines) by extension; replace deprecated `catchError` with `catch` in a separate commit.
