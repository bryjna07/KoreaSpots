# Roadmap

Order: 1) quality cleanup -> 2) bug fixes -> 3) AI chatbot. Discuss a plan before each multi-file step.

## 1. Quality cleanup
- (done) Empty `SharedUI/` removed.
- Split large files (see architecture.md).
- Move hardcoded Korean strings to `LocalizedKeys`; decide on English localization.
- Comment/dead-code pass (Korean comments, minimal).
- Add basic tests for Reactors/UseCases (none exist).
- Verify `Navigator` default `present` recursion.

## 2. Bugs / TODO
- `Navigator.swift:64,73` Map/FestivalDetail VCs not implemented
- `HomeViewController.swift:192,233,238,241` map, festival list, category list, theme list navigation
- `HomeSectionModel.swift:55` weekly weather section
- `SkeletonDataProvider.swift:59` API-error placeholder cell
- `FetchFestivalUseCase.swift:61` pageNo handling
- `TripLocalDataSourceImpl.swift:214` region code 0

## 3. AI chatbot (place recommendations)
- LLM key stays server-side: backend proxy (e.g. Firebase Functions). Consult claude-api skill first.
- New module `Presentation/Features/Chat` + Domain UseCase.
- Ground answers in Tour API data (tool use over `searchKeyword2` / `locationBasedList2`).
- UI framework (UIKit vs SwiftUI hosted) - decide before starting.

## Feature ideas (from earlier planning; in git stash on `dev`, verify against current code before use)
- Favorites proximity notification (within ~500m), notification on trip-plan nearby visit, background notifications. Schema draft: `stash@{2}` (`PlaceNotificationSettingR.swift`). `SCHEMA_ANALYSIS.md` (stash@{0}) rates current Realm schema: supports route map/gallery/visit time; lacks notification fields.
- Random place recommendation with region/theme filter and "exclude visited" option (partial schema support via `visitedAreas`).
- Settings screen draft: `stash@{5}` (`SettingViewController`, TabBar rework).
- Code-book fixes: `stash@{4}` (`TourCodeBook`, `sigungu_codes.json`) - may conflict with the new `Core/Common/CodeBook/` path.
- Earlier TripRecord plan (`.claude/plan.md` in stash@{0}): list/calendar segment, cover photo, route preview in editor. Much of it shipped in 1.1.0; re-check.
- Cache TTL intent from old CLAUDE.md (banner 24h, detailIntro 7-14d, code tables 60-90d, location lists 1-3h): unverified whether implemented.

## Portfolio README
Draft exists in `stash@{0}` README.md (app name "어디로", features, tech points, structure). Rewrite after the refactor so the structure section matches; mention the Claude workflow (`docs/claude-workflow.md`).
