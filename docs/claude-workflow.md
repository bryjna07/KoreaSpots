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
