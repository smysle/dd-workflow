# DD Workflow

Core rules:
1. **Plan Mode** — Research first, then plan. Never jump straight into code.
2. **Write the DesignDoc first** — Background / goals / non-goals / proposal / risks / test / rollback.
3. **Store per-project** — `{repo_root}/docs/design/NNNN-slug.md`. Don't mix projects.
4. **Commit doc before code** — Code commits reference DD-NNNN.
5. **Plan before executing** — Output plan, then implement step-by-step.
6. **Log deviations** — Departures from the doc must be recorded in §8.

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
Implement code per DD-{dd_id}. The doc is already in the repo — only write code, do not modify docs/.

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

## Checklist

1. Pick a slug → `bash {workspace}/docs/design/allocate-dd-id.sh <slug>`
2. Spawn design agent (`{design_model}`) → doc + commit
3. Present doc to user for review
4. Spawn implementation agent (`{implement_model}`, 43200 s timeout) → code + commit
5. Verify: .gitignore / build / test / two commits / DD status → Implemented
6. Report results
