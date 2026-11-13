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

### Token usage analysis (measured from session logs, 2026-11-12)
- Method: summed `message.usage` from `~/.claude/projects/<project>/*.jsonl` (deduplicated by message/request id).
- Result for the day: 590 API calls; output ~0.41M, cache write ~1.4M, **cache read ~61.5M**, plain input ~1.5k.
- Takeaway: output was small; cost was dominated by re-reading a large context every call (~100k tokens per call on average). Context size x number of calls is the lever, not prompt length.
- Subagent build check cost ~13k tokens total, so delegation worked as intended.

### Token measurement script
Run from the repo root: `python3 -I token_usage.py` (save the block below as that file anywhere outside the repo, or inline it). It groups usage by session and model so two models can be compared on the same kind of task.
- Columns: `calls`, plain `in`, `c_write` (cache write), `c_read` (cache read), `out`, `avg_ctx` (input + cache write + cache read per call). Timestamps are UTC.
- Logs live in `~/.claude/projects/<cwd with every non-alphanumeric char turned into "-">`. macOS returns Hangul paths decomposed (NFD), so the script normalizes to NFC first; without that the dash count is wrong and it finds no logs.
- Compare models on calls, `avg_ctx`, `c_read`, `out` and the task outcome. Raw tokens are not equal cost across models (price per token differs).

```python
"""Sum Claude Code token usage per session and model, deduplicated by message id."""
import json
import re
import unicodedata
from collections import defaultdict
from pathlib import Path

# Run from the repo root. Logs live under the cwd with every non-alphanumeric char turned into "-";
# macOS returns Hangul decomposed (NFD), so normalize to NFC first or the dash count is wrong.
PROJECT = Path.home() / ".claude/projects" / re.sub(r"[^A-Za-z0-9]", "-", unicodedata.normalize("NFC", str(Path.cwd())))
FIELDS = ("input_tokens", "cache_creation_input_tokens", "cache_read_input_tokens", "output_tokens")

seen: set[str] = set()
# (session, model) -> totals
rows: dict[tuple[str, str], dict] = defaultdict(
    lambda: {"calls": 0, "first": None, "last": None, **{f: 0 for f in FIELDS}}
)

for path in sorted(PROJECT.rglob("*.jsonl")):
    for line in path.open(encoding="utf-8"):
        try:
            d = json.loads(line)
        except json.JSONDecodeError:
            continue
        m = d.get("message")
        if not isinstance(m, dict) or "usage" not in m or not m.get("id"):
            continue
        if m["id"] in seen:
            continue
        seen.add(m["id"])
        key = (d.get("sessionId", path.stem)[:8], m.get("model", "?"))
        r = rows[key]
        r["calls"] += 1
        ts = d.get("timestamp")
        r["first"] = min(filter(None, [r["first"], ts])) if ts else r["first"]
        r["last"] = max(filter(None, [r["last"], ts])) if ts else r["last"]
        for f in FIELDS:
            r[f] += m["usage"].get(f) or 0

def fmt(n: int) -> str:
    return f"{n/1e6:.2f}M" if n >= 1e6 else f"{n/1e3:.1f}k"

print(f"{'session':9}{'model':20}{'calls':>6}{'in':>8}{'c_write':>9}{'c_read':>9}{'out':>8}{'avg_ctx':>9}  first -> last")
tot = defaultdict(lambda: defaultdict(int))
for (sess, model), r in sorted(rows.items(), key=lambda kv: kv[1]["first"] or ""):
    ctx = (r["input_tokens"] + r["cache_creation_input_tokens"] + r["cache_read_input_tokens"]) / r["calls"]
    print(f"{sess:9}{model:20}{r['calls']:>6}{fmt(r['input_tokens']):>8}{fmt(r['cache_creation_input_tokens']):>9}"
          f"{fmt(r['cache_read_input_tokens']):>9}{fmt(r['output_tokens']):>8}{fmt(int(ctx)):>9}  "
          f"{(r['first'] or '')[:16]} -> {(r['last'] or '')[:16]}")
    for k in ("calls", *FIELDS):
        tot[model][k] += r[k]
print()
for model, t in tot.items():
    print(f"TOTAL {model}: calls={t['calls']} in={fmt(t['input_tokens'])} c_write={fmt(t['cache_creation_input_tokens'])} "
          f"c_read={fmt(t['cache_read_input_tokens'])} out={fmt(t['output_tokens'])}")
```

### Baseline: Sonnet 5.5 (measured 2026-11-13)
- All sessions so far: Sonnet 616 calls, cache read 68.8M, cache write 1.29M, output 428k. Haiku (subagents) 59 calls, cache read 1.0M, output 34k.
- Average context per call, Sonnet, per session: 93k, 160k, 123k, 104k, 84k, 71k (2026-11-12), 102k for the iPhone Duo session (67 calls, cache read 6.56M, output 36.8k).
- No clear drop in average context after disabling the Figma/Notion MCP servers; the Duo session read many screenshots, so it is not a clean comparison.
- Next: run a similar task on Opus in a fresh session and compare with the table above.

### Where tokens were wasted, and the fix
- Always-loaded tool/skill definitions from MCP servers unrelated to the repo (Figma, Notion, design/computer-use tools) inflate the baseline of every call. Fix: disable them per project with `/mcp`; keep only what the repo uses (`XcodeBuildMCP`, `context7`).
- `WebSearch` in `extended` mode (several times the cost) was used for a new-device question; official Apple docs via `context7` were cheaper and authoritative, and the web result was wrong ("not in official docs"). Policy: Apple/library docs -> `context7` first; web search `standard` first.
- Many tiny sequential tool calls re-read the whole context each time. Batch independent calls in one step.
- Long sessions: run `save-context` -> `/clear` -> `/resume-context` at task boundaries, before the context grows large (see threshold below).

### Context reset threshold
- Each call re-reads the whole context, so cost grows with context size; a reset costs one reload of the fixed baseline (system prompt, CLAUDE.md, handoff) plus any lost detail.
- Rule of thumb: reset at a natural task boundary once context reaches roughly 10-15%, rather than at a fixed 20%; never mid-edit (the handoff loses detail). Re-measure with the log script above.
