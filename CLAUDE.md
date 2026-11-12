# KoreaSpots

Released iOS app "어디로" (v1.1.1, build 9) for discovering Korean tourist spots/festivals and recording trips. Data from the Korea Tour API (data.go.kr).

## Stack
- UIKit (programmatic, SnapKit + Then), no storyboards for screens. iPhone only, Swift 5.
- ReactorKit on RxSwift/RxCocoa. Moya for networking. Realm for local storage. Firebase. Kingfisher, FSCalendar, SkeletonView.
- All dependencies via SPM. Single target/scheme: `KoreaSpots`. No tests yet.

## Build
- `xcodebuild -project KoreaSpots.xcodeproj -scheme KoreaSpots -destination 'generic/platform=iOS Simulator' build`
- Delegate builds to the `build-verifier` subagent (keeps logs out of main context). Prefer XcodeBuildMCP for simulator runs.
- Deployment target: iOS 16.0 (target level, matches the released app; do not raise without a user decision). Project-level 18.5 is an unused Xcode default overridden by the target.

## Layout
- `KoreaSpots/Application` - AppDelegate, SceneDelegate, DI (`AppContainer`)
- `KoreaSpots/Core` - `Domain` (Entities, Repository protocols, UseCases), `Data` (DTO, Mapper, DataSources, RepositoryImpl, Persistence), `Networking`, `Navigation`, `Common`, `Utilities`
- `KoreaSpots/Presentation` - `Base`, `Features/<Name>/{ViewControllers,Views,Reactor,Models,Sections}`
- `KoreaSpots/Resources` - Info.plist, localization (ko only), fonts, mock JSON, code-book JSON
- Details: `docs/architecture.md`, `docs/api.md`, `docs/roadmap.md`

## Conventions
- Code comments and commit messages in Korean. Commit format: `Feat: 설명 #이슈번호` (prefixes: Feat, Fix, Refactor, ...). Release commits: `1.1.1 업데이트`.
- Section markers: `//MARK: -`. File header: Xcode default.
- Each Reactor has nested `Action`, `Mutation`, `State`.
- UseCase / Repository / DataSource = protocol + `*Impl`.
- Realm models use `R` suffix (`PlaceR`, `TripR`); mappers named `Xxx+Mapping`.
- New screens: add factory `makeXxxViewController()` in `AppContainer`; navigate via `Navigator`.
- User-facing strings go to `LocalizedKeys` / `Localizable.strings` (some legacy hardcoded Korean remains).

## Context scope
- Focus: `KoreaSpots/{Application,Core,Presentation}`. Avoid reading: `*.xcassets`, `Resources/Mock/*.json` (large), `DerivedData`, `Resources/Config/Secrets/`.
- If more context is needed, propose a file list first instead of scanning the whole repo.

## Definition of done
- Build passes (`build-verifier`), no new warnings. UI bindings on main thread. No hardcoded user-facing strings/colors. Behavior-preserving refactors: `refactor-reviewer` says SAFE.

## Rules
- NEVER read, print, or commit `KoreaSpots/Resources/Config/Secrets/` (API key xcconfig, git-ignored) or GoogleService plist.
- Do not hand-edit `project.pbxproj`; warn first if unavoidable.
- No scope creep. Discuss a plan before multi-file changes.
- Realm schema changes require bumping `schemaVersion` and a migration (AppDelegate).
- Never embed LLM/Anthropic API keys in the app; use a backend proxy.

## Purpose
Portfolio for a new-grad iOS / AI-agent developer role. Goals: clean structure, and visible, token-efficient Claude Code workflow (see `docs/claude-workflow.md`). Refactors must be behavior-preserving (no tests exist): one change per commit.

## Claude tooling (`.claude/`)
- Agents: `build-verifier` (build summary), `refactor-reviewer` (verifies a split is behavior-preserving).
- Skills: `split-file`, `annotate-file` (comment convention), `smoke-check` (simulator check). Global: `commit-ko`, `devlog`, `save-context`, `resume-context`.
- Session continuity: before `/clear`, run `save-context`; new session starts with `/resume-context`. Keep CLAUDE.md/docs/memory in English.
- Branch for structure work: `refactor/structure`. Never push without asking.

## Work order
Quality cleanup -> bug fixes -> AI chatbot (place recommendation). See `docs/roadmap.md`.
