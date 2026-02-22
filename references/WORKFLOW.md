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

**{design_model} = Design** | **{implement_model} = Implementation** | **{language} = Output language (default: 中文)**

---

## Design Agent Task Template

```
Write a DesignDoc and commit it.
IMPORTANT: All output, summaries, and commit messages must be in {language}.

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
IMPORTANT: All output, summaries, and deviation logs must be in {language}. Code comments may remain in English.

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
| `{language}` | Output language for agent responses | `中文` |

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
Audit the project at {repo_root} before it gets pushed to a public repo. You are NOT the author — you are the reviewer. Be thorough and skeptical.
IMPORTANT: All output and reports must be in {language}.

## Step 0: Detect & Inventory
Explore the repo root and determine:
  - **Project type:** Cargo.toml, package.json, pyproject.toml, go.mod, Makefile, or pure docs/scripts
  - **Toolchain version locks:** .nvmrc, rust-toolchain.toml, .python-version, .go-version — do they exist? Are they consistent with what the project actually needs?
  - **Lock files:** Cargo.lock, package-lock.json, yarn.lock, go.sum, poetry.lock — present? Tracked in git? In sync with manifest?
  - This determines which checks below are applicable.

## Checks — apply what's relevant, skip what's not:

### A. ALWAYS (all project types):

1. **Dead path references**
   Scan all source/config files for references to paths that don't exist in git:
   - File includes/embeds (include_bytes!, include_str!, require(), import, source)
   - Hardcoded absolute paths (/home/*, /Users/*, /tmp/*)
   - References to directories removed from git but still present locally
   ```bash
   git ls-files > /tmp/tracked.txt
   # grep source files for path-like strings and cross-check
   ```

2. **.gitignore sanity**
   - List gitignored files: `git ls-files --others --ignored --exclude-standard`
   - Are any needed for CI or another machine?
   - Watch for overly broad rules: `*.sql`, `*.json`, `*.lock` catching wanted files

3. **Secrets scan**
   - grep for API keys, tokens, passwords, private keys in tracked files
   - Check .env / .env.* files aren't tracked
   - Scan config example files for real credentials accidentally left in

4. **Residual issues**
   - grep for TODO, FIXME, HACK, XXX — flag unfinished tasks
   - Check for leftover debug code (console.log, print(), dbg!(), println!)

5. **Lint & format check** (best-effort)
   - If linter/formatter is available or easy to install, run it:
     Rust: `cargo fmt --check`, `cargo clippy`
     Node: `npx eslint .`, `npx prettier --check .`
     Python: `ruff check .`, `black --check .`
     Go: `go vet ./...`, `gofmt -l .`
   - If tool is unavailable, note it in report but don't block

6. **Dependency vulnerability scan** (best-effort)
   - If audit tool is available or easy to install, run it:
     Rust: `cargo audit` (install via `cargo install cargo-audit` if needed)
     Node: `npm audit --production`
     Python: `pip-audit` or `safety check`
     Go: `govulncheck ./...`
   - Report findings with severity; critical/high = must fix, medium/low = note in report

7. **License compliance check** (best-effort)
   - Scan dependency licenses for conflicts with the project's license
     Rust: `cargo license` or `cargo deny check licenses`
     Node: `npx license-checker --summary`
   - Flag copyleft (GPL/AGPL) dependencies in permissive-licensed projects
   - If tool unavailable, spot-check major dependencies manually

8. **Documentation completeness**
   - README exists and contains: what the project does, how to build/run, how to configure
   - If API project: are endpoints documented?
   - LICENSE file present and matches declared license

### B. If buildable project:

9. **Build verification**
   - Run project's build command (cargo build, npm run build, go build, make, etc.)
   - Use lock file (--locked, --frozen)
   - Run tests; report any failures

10. **Test coverage baseline** (best-effort)
    - If coverage tool is available:
      Rust: `cargo tarpaulin --out summary` or `cargo llvm-cov`
      Node: `npx jest --coverage` or `npx c8 report`
    - Report coverage %; flag if core logic < 60%
    - If tool unavailable, note in report

11. **Build artifact analysis** (informational)
    - Binary size (Rust: `ls -lh target/release/`)
    - Bundle size (Node: `du -sh dist/`)
    - Flag unusually large artifacts; suggest `cargo bloat` or `webpack-bundle-analyzer` if applicable

### C. If has Dockerfile or CI:

12. **Dockerfile ↔ git cross-check**
    - Every COPY/ADD source must exist in git
    - Base image tags pinned (not just :latest)
    - **Best practices:** multi-stage build? Non-root user? Minimal final image?
    - Suggest `docker scout` or `trivy image` scan if available

13. **CI workflow check**
    - Read .github/workflows/*.yml (or .gitlab-ci.yml, etc.)
    - Verify branches, paths, secrets references
    - Check for references to removed files/directories

14. **IaC config check** (if applicable)
    - If Terraform/K8s/Helm/docker-compose files exist:
      validate syntax, check for hardcoded secrets, verify resource limits

### D. Report

Output a structured report with:

- **Issues found & fixed** — what was broken, what you did
- **Quality metrics** (where available):
  - Test coverage %
  - Lint warnings count
  - Dependency vulnerabilities (critical/high/medium/low)
  - Binary/bundle size
- **Tech debt inventory** — consolidated TODO/FIXME list with file:line, suggested priority
- **Skipped checks** — what and why (tool unavailable, not applicable, etc.)
- **Verdict:** AUDIT CLEAN / AUDIT PASSED WITH NOTES / AUDIT FAILED (blocking issues)

If fixes were made:
  git add -A && git commit -m "fix: pre-push audit (DD-{dd_id})"
If nothing to fix:
  output "AUDIT CLEAN" with full report
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
