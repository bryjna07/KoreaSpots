---
name: split-file
description: Behavior-preserving split of a large Swift file (extension-based). Use when asked to split/shrink a large file in KoreaSpots.
---

Goal: smaller files, zero behavior change. One file per run, one commit per file.

1. Read the target file. Record: line count, list of types/funcs (`grep -nE "^\s*(final )?(class|struct|enum|protocol|extension|func|private func)"`).
2. Plan the split and show it to the user in Korean if the file is >500 lines or the plan is non-obvious. Default strategy (extension-based, light):
   - ViewController: `X.swift` (props, lifecycle) + `X+Bind.swift` (Reactor binding) + `X+DataSource.swift` / `X+Delegate.swift`.
   - View: group subview creation/layout into `X+Layout.swift`; extract reusable subviews only if self-contained.
   - Reactor: keep Action/Mutation/State/mutate/reduce in one file; move pure helpers to `X+Helpers.swift`.
   - RepositoryImpl/DataSource: split by domain (e.g. festival / place / search) via extensions.
3. Create new files next to the original (same folder, `Name+Role.swift`). Use `git mv` for the file that keeps most of the code so history follows. Copy code verbatim; do not rename, reorder logic, or "improve" anything.
4. Fix access control minimally (`private` -> `fileprivate`) only where the compiler requires it. Add `import`s as needed.
5. Add the file-header comment per the `annotate-file` skill.
6. Spawn `build-verifier`. Fix only compile errors caused by the split.
7. Spawn `refactor-reviewer`. Resolve RISKY findings.
8. Use the `commit-ko` skill: `Refactor: <TypeName> 파일 분리`. Do not push.
9. For a notable lesson, offer the `devlog` skill.
