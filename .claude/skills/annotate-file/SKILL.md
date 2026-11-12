---
name: annotate-file
description: Add Claude-oriented Korean comments to a Swift file (header summary + "why" comments). Use when asked to add/clean comments in KoreaSpots.
---

Purpose: let a future Claude session understand a file without reading its dependencies. Comments are Korean, short, and about intent.

## File header (below the Xcode header, above imports are fine either way)
```swift
// 역할: 장소 상세 화면의 상태 관리 (Action -> Mutation -> State)
// 의존: FetchPlaceDetailUseCase, FavoriteUseCase
// 사용처: PlaceDetailViewController
```
- 1 line role, 1 line dependencies, 1 line used-by. Omit a line if trivially obvious.

## Inline rules
- Write "why", constraints, side effects, gotchas: Realm thread confinement, quota -> mock fallback, API quirks (contentTypeId differences), ordering dependencies.
- Reactor: one line above `mutate`/`reduce` for non-obvious Action->Mutation mappings.
- Use `//MARK: -` sections (existing convention).
- Do NOT add comments that restate code (`// 버튼 생성`). Remove such existing comments when touching the file.
- Never change code while annotating; comment-only diffs. Verify with `git diff` that only comment lines changed.
- Keep TODOs; format `// TODO: 내용`.
