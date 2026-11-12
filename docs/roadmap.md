# Roadmap

Order: 1) quality cleanup -> 2) bug fixes -> 3) AI chatbot. Discuss a plan before each multi-file step.

## Release plan
Order agreed with the user (details of each item live in the sections below).
1. **Gate: real-device Realm migration test (1.1.1 -> v3).** No code work; do before any release build.
2. **2.0.0**: category improvements + UI polish + app logo + iPhone Duo check.
   - Build all layout changes with localization in mind (no fixed widths, allow longer text via wrapping/scaling/Auto Layout); the translation itself ships later.
   - Category: two-way scroll sync, per-subcategory images, level-2 merge list (user picks groups).
   - UI polish: font/height/color in `PlaceLocationCell`, `PlaceBasicInfoCell`, `CategorySectionHeader`.
   - App logo: asset replacement (design needed first).
   - iPhone Duo (large foldable): see below.
3. **After 2.0.0** (version TBD): localization. Follow the system language only (no in-app picker, so no Settings dependency). Extend `LocalizedKeys`; ~140 hardcoded KR literals, mostly `PlaceDetail/Views/Cells/*OperatingInfoCell`. Layouts are already prepared for longer strings during 2.0.0, so this step is mostly key extraction and translation.
4. **Later**: AI chatbot, after the separate Python project is finished (see section 3). Then tests (Reactor/UseCase first), last.

### iPhone Duo
Source: Apple HIG "Designing for iPhone Duo" (via context7).
- Outer display = compact width, inner display = regular width. Use size classes, layout margins and safe area insets; avoid fixed widths and display-specific code. Do not build per-pose layouts.
- Fold: prefer an even number of grid columns; use `UIView.ReservedRegion` for content that must avoid the center.
- Plan: capture Home/Category/Detail/Trip on both displays (Xcode Device Hub or Duo simulator), classify what breaks, then fix. Likely first targets: fixed item sizes/column counts in collection views, fixed-width SnapKit constraints.
- Not yet verified: how the iPhone-only target behaves on the inner display (compatibility vs. native).

## 1. Quality cleanup
- (done) Empty `SharedUI/` removed.
- Split large files (see architecture.md).
- Move hardcoded Korean strings to `LocalizedKeys`; decide on English localization.
- Comment/dead-code pass (Korean comments, minimal).
- Add basic tests for Reactors/UseCases (none exist).
- Verify `Navigator` default `present` recursion.

## 2. Bugs / TODO
- `Navigator.swift:64,73` Map/FestivalDetail VCs not implemented
- `HomeViewController.swift:184,225,230,233` map view, festival/category/theme list navigation (header action hook `handleHeaderAction` is unreachable until a header `actionTitle` is set)
- `HomeSectionModel.swift:55` weekly weather section
- `TabBarController.swift:122` Settings screen (draft in `stash@{5}`)
- `TripDetailViewController.swift:206` full-screen photo viewer
- `SkeletonDataProvider.swift:56` API-error placeholder cell
- `FetchFestivalUseCase.swift:61` pageNo handling
- `TripLocalDataSourceImpl.swift:214` region code 0
- `PlaceDetailReactor.swift:236` error handling
- Unreproduced bugs: `SearchReactor.swift:539` recent-keyword first tap shows an alert; `PlaceDescriptionCell.swift:147` info shown only on card tap
- UI polish (font/height/color in `PlaceLocationCell`, `PlaceBasicInfoCell`, `CategorySectionHeader`): one pass later, no per-line TODOs
- `SearchReactor.swift` (3 `Observable.create` sites) `Observable.create` discards the inner `.subscribe(observer)` Disposable and returns `Disposables.create()`, so cancelling the outer stream (e.g. a new search) does not cancel the inner request; stale results may arrive late. Fix: `return ....subscribe(observer)`. Behavior change -> `Fix:` commit, verify on simulator by changing filters/keywords quickly.
- Category screen improvements (after lclsSystm switch; 59 level-2 sections):
  - Sync scroll both ways: left sidebar tap/scroll should also drive the right grid (currently only right -> left)
  - Replace per-item generic icon (`RectangleCell`) with a brief image per subcategory
  - Merge/curate level-2 categories to shorten the list (e.g. via a JSON like `themes.json`)

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
