# Claude Code workflow (portfolio notes)

Why this repo has `.claude/`, `CLAUDE.md`, `docs/`: to show a reproducible, token-efficient AI-assisted workflow on a real released app.

## Token-saving practices
- Config/memory/skills written in English; user-facing talk in Korean.
- CLAUDE.md short; details split into `docs/` and loaded on demand.
- Noisy work delegated to cheap subagents (`build-verifier` on haiku); read-only review in `refactor-reviewer`.
- Repeated procedures captured as skills (`split-file`, `annotate-file`, `smoke-check`) instead of re-explained each time.
- `save-context` + `/resume-context` replace auto-compact: one short handoff memory file, fresh session.
- Secrets protected by `permissions.deny` in `.claude/settings.json`, not just by convention.

## Refactor safety loop (no tests available)
plan -> extension-based split (verbatim move) -> `build-verifier` -> `refactor-reviewer` -> `smoke-check` -> one commit per file.

## Commit history as evidence
One logical change per commit (`Refactor: ...`, `Docs: ...`), Korean messages, issue numbers where applicable.

## Lessons learned (working with Claude Code)

### Build strategy: where do tokens and time actually go?
- Problem: a verification build took ~3 min. Cause was not the subagent but my request: a fresh `-derivedDataPath` forces a full recompile (2000+ files) to avoid hidden warnings.
- Tokens: unfiltered `xcodebuild` output can be tens of thousands of tokens; filtered it is a few hundred. `DerivedData` itself is never read, only logs are.
- Filter pitfall: `grep "BUILD"` also matches `export BUILD_DIR=...` env lines on failure. Use `grep -E "error:|\*\* BUILD"`.
- Policy: small changes -> incremental `xcodebuild` piped through a strict `grep`; final check before commit / multi-file refactors -> `build-verifier` subagent with the default derivedData (incremental). Full recompile only when hidden warnings matter. Manual build by the user only for UI/device checks.

### Reading files cheaply
- A ~800-line Swift file is roughly 10k tokens (Korean comments cost more), and it is re-processed every turn afterwards.
- Locate with `grep -n`, read ranges with `sed -n`. Never read large mock JSON / xcassets.
- Long session -> `save-context`, `/clear`, `/resume-context` instead of auto-compact.

### Verify, do not trust
- Subagent reports are inputs, not approvals: commits happen only after the user says so.
- Line-based `sed -i` deletions were off by one twice (a lost `// MARK`, a stray `}`). The build and `git diff` caught both. Rule: always review the diff and build after scripted edits.
- A "behavior-preserving" claim needs evidence: e.g. `FavoriteRepository.getFavorites()` (Observable, unsorted) looked like a replacement for `getFavoritePlaces()` (Single, sorted by cachedAt) but was not, so a same-signature method was added instead.

### Decision process
- Claude proposes a plan -> user approves -> one change per commit -> build + `refactor-reviewer` -> user approves the commit -> no push without asking.
