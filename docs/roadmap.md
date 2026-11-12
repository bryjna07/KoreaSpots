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
