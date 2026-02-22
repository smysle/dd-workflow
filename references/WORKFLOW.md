# DD Workflow

Core rules:
1. **Plan Mode** — Research first, then plan. Never jump straight into code.
2. **Write the DesignDoc first** — Background / goals / non-goals / proposal / risks / test / rollback.
3. **Store per-project** — `{repo_root}/docs/design/NNNN-slug.md`. Don't mix projects.
4. **Commit doc before code** — Code commits reference DD-NNNN.
5. **Plan before executing** — Output plan, then implement step-by-step.
6. **Log deviations** — Departures from the doc must be recorded in §8.
7. **Clean before publish** — DD docs, legacy source, and temp files must not reach the public repo.
8. **Audit before push** — Spawn an independent agent to verify build, references, and CI readiness.

**{design_model} = Design** | **{implement_model} = Implementation**

---

## Design Agent Task Template

```
Write a DesignDoc and commit it.

Requirement: {requirement_description}
DD ID: DD-{dd_id}
Output: {repo_root}/docs/design/{dd_id}-{slug}.md
Template: {workspace}/docs/design/TEMPLATE.md

1. Research (read {repo_root} source code + web_search as needed)
2. Write DesignDoc following the template (Status: Draft)
3. git init (new projects only) && git config user.name "{author_name}" && git config user.email "{author_email}"
4. git add docs/ && git commit -m "docs: DD-{dd_id} {slug}"

Output a 3-5 sentence summary when done. Stay technical.
```

## Implementation Agent Task Template

```
Implement code per DD-{dd_id}. The doc is already in the repo — only write code, do not modify docs/ except for §8 (Decision Log) where deviations must be recorded.

Document: {repo_root}/docs/design/{dd_id}-{slug}.md

Phase 1 — Read the document, output an execution plan.
Phase 2 — Implement step-by-step per the plan:
  .gitignore → project init → source code → dependency install → build → test
  Any deviation from the doc must be recorded in §8.
Phase 3 — git add -A && git commit -m "feat: {slug} (DD-{dd_id})"

Output the file manifest and test results when done. Stay technical.
```

---

## Notes

- The implementation agent's Phase 1 plan output is expected — do not skip it.
- Timeout: `runTimeoutSeconds: 43200` (12 hours) for complex implementations.
- git config: always use local config (no `--global`).
- Global assets (template, scripts, ID counter): `{workspace}/docs/design/`
- Project-specific docs: `{repo_root}/docs/design/`

## Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `{workspace}` | Agent workspace root | `/home/user/.openclaw/workspace` |
| `{repo_root}` | Target project repository root | `/home/user/.openclaw/workspace/myapp` |
| `{requirement_description}` | Feature requirement in plain language | "Implement auth session refresh" |
| `{dd_id}` | Zero-padded 4-digit DD number | `0001` |
| `{slug}` | Kebab-case feature identifier | `auth-session-refactor` |
| `{author_name}` | Git author name for commits | `Alice` |
| `{author_email}` | Git author email for commits | `alice@example.com` |
| `{design_model}` | Model used for design/doc tasks | `claude-opus-4` |
| `{implement_model}` | Model used for implementation | `codex-1` |

## Pre-Publish Cleanup (Rule 7)

Before pushing to a public repository, the orchestrating agent MUST:

1. **Remove DD docs from tracked files** — `docs/design/` is internal process documentation, not shipped code.
   ```bash
   git rm -r --cached docs/design/ 2>/dev/null
   echo 'docs/design/' >> .gitignore
   ```
2. **Remove reference/legacy source** — If the project was built by rewriting an existing codebase, the original source (e.g. Python `bot/`, old `main.py`, `requirements.txt`) must not be in the public repo. Keep it locally for reference but add to `.gitignore`.
3. **Remove temp/backup files** — Any `*.bak`, `*.orig`, scratch files generated during implementation.
4. **Verify .gitignore completeness** — Must cover: build artifacts, config secrets, DB files, editor/OS noise, AND all of the above.
5. **Commit cleanup** — `git commit -m "chore: pre-publish cleanup"`

This step applies AFTER all implementation phases are complete and BEFORE the audit (Rule 8).

## Pre-Push Audit (Rule 8)

After cleanup, spawn a **separate** agent (not the one that wrote the code) to independently audit the project before pushing. Fresh eyes catch what the author misses.

### Audit Agent Task Template

```
Audit the project at {repo_root} for CI and build readiness. You are NOT the author — you are the reviewer. Be thorough and skeptical.

## Checks (do ALL of them):

### 1. Dead path references
Scan all source files for references to paths that don't exist in git:
  - include_bytes!, include_str!, mod declarations, path imports
  - Any hardcoded absolute paths (/home/*, /tmp/*)
  - References to directories removed from git but present locally

### 2. .gitignore vs Dockerfile cross-check
  - List all gitignored files that exist locally (excluding target/, node_modules/)
  - Read the Dockerfile — verify every COPY source is tracked in git
  - Flag any mismatch

### 3. Build verification
  - cargo build --workspace --locked (or equivalent)
  - cargo test --workspace
  - If Dockerfile exists: verify COPY sources, verify base image tags

### 4. Residual issues
  - grep for TODO, FIXME, HACK, unimplemented!, todo!
  - Check for secrets/tokens accidentally committed
  - Verify CI workflow files reference correct branches and paths

### 5. Fix and commit
  - Fix any issues found
  - cargo check/build/test after fixes
  - git add -A && git commit -m "fix: pre-push audit (DD-{dd_id})"
  - If nothing to fix: output "AUDIT CLEAN" with investigation summary
```

### Why a separate agent?

The implementation agent has "author blindness" — it wrote the code, so it assumes its own paths and context. A fresh agent only sees what's in git, catches:
- References to locally-present but git-ignored files (e.g. `bot/` directory)
- .gitignore rules that are too broad (e.g. `*.sql` blocking `migrations/`)
- Dockerfile assumptions that only work locally

## Checklist

1. Pick a slug → `bash {workspace}/docs/design/allocate-dd-id.sh <slug>`
2. Spawn design agent (`{design_model}`) → doc + commit
3. Present doc to user for review
4. Spawn implementation agent (`{implement_model}`, 43200 s timeout) → code + commit
5. Verify: .gitignore / build / test / two commits / DD status → Implemented
6. **Pre-publish cleanup** (Rule 7) — remove internal docs, legacy source, temp files
7. **Pre-push audit** (Rule 8) — spawn independent agent to verify build + CI readiness
8. Push to remote + report results
