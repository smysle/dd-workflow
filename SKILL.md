---
name: dd-workflow
description: >
  DesignDoc Driven Development — a structured workflow for building features
  that require upfront design. Covers multi-step development, cross-agent
  collaboration (design agent + implementation agent), and design document
  lifecycle management. Triggers when the user asks to build a new feature,
  refactor a system, or tackle any task complex enough to warrant a design doc.
---

# DD Workflow — DesignDoc Driven Development

A lightweight, agent-native development workflow: **write a design doc first,
then implement against it.** Every non-trivial feature goes through a
structured design → review → implement → verify cycle.

## 6 Core Rules

1. **Plan Mode** — Research first, then plan. Never jump straight into code.
2. **Write the DesignDoc first** — Background, goals, non-goals, proposal,
   risks, test plan, rollback plan.
3. **Store per-project** — `{repo_root}/docs/design/NNNN-slug.md`. Don't mix
   projects. Global assets (template, scripts) live in `{workspace}/docs/design/`.
4. **Commit doc before code** — Code commits reference `DD-NNNN`.
5. **Plan before executing** — Output an execution plan, then implement
   step-by-step with verification.
6. **Log deviations** — Any departure from the doc must be recorded in §8
   (Decision Log).

## Roles (7-Role Compact)

Assign by **capability**, not by job title — one model per role, the
orchestrator picks the right one based on context.

| Role | Suggested Model | Responsibility |
|------|----------------|----------------|
| **Orchestrator** | Main agent (e.g. Claude Opus 4.6) | Understand requirements, decompose tasks, dispatch, accept deliverables |
| **Feasibility Review** | `gemini-3.1-pro` | Requirement analysis, hidden-risk discovery, feasibility assessment |
| **Design Review** | `gemini-3.1-pro` | Architecture / security review, UI / design-mockup review (multimodal) |
| **Design + Implementation** | `openai/gpt-5.4` + `thinking: high` | Write DesignDoc, write code, commit |
| **Grunt Work** | `step-3.5-flash` | Code exploration, research, quick Q&A, simple tasks |
| **Long Document** | `minimax-m2.5` | Long-form document generation / consolidation (rate-limit: 5 req/min) |
| **Plan Review** | `kimi-k2.5` | Evaluate plan completeness, second opinion |

### Supplementary

- **Light multimodal** → `gemini-3-flash-preview` (when 3.1 Pro is overkill)
- Models are suggestions — swap freely based on your provider setup.
- The same model never needs two roles; the orchestrator decides by task context.

The orchestrator dispatches tasks using the templates in
`references/WORKFLOW.md`. For concrete workspace-level routing rules and
`sessions_spawn` templates, see `docs/design/MULTI_MODEL_ROUTING.md`.

## Quick Start (5 Steps)

- [ ] **1. Allocate ID** — `bash {workspace}/docs/design/allocate-dd-id.sh <slug>`
      (first run in a new repo: copy script + TEMPLATE.md into `{repo_root}/docs/design/`)
- [ ] **2. Spawn Design Agent** — Hand it the Design Task template from
      `references/WORKFLOW.md` with the requirement, DD ID, and slug filled in.
      Agent writes the doc and commits.
- [ ] **3. Review** — Present the doc to the user for approval. Gate on this —
      no implementation without sign-off.
- [ ] **4. Spawn Implementation Agent** — Hand it the Implementation Task template.
      Agent reads the doc, outputs a plan, implements, tests, and commits.
      Recommended timeout: 43200 s (12 h).
- [ ] **5. Verify** — Check: `.gitignore` present, build passes, tests pass,
      two commits exist (doc + code), DD status updated to `Implemented`.

## Reference Files

| File | Purpose |
|------|---------|
| `references/WORKFLOW.md` | Detailed workflow, task templates, variable table, checklist |
| `references/TEMPLATE.md` | DesignDoc template (8 sections, bilingual headings) |
| `scripts/allocate-dd-id.sh` | Atomic ID allocator — reads/increments `.next-id` |

## Pitfall Notes

1. **Don't skip the implementation plan.** The implementation agent's Phase 1
   output (execution plan) is expected behavior, not wasted tokens. It catches
   misunderstandings before code is written.
2. **git config: local only.** Always use `git config user.name` (no `--global`)
   inside the repo to avoid polluting the host.
3. **One doc per commit, one feature per doc.** Mixing concerns in a single DD
   defeats the purpose of traceability.
4. **Variables are placeholders, not magic.** When spawning agents, replace
   `{repo_root}`, `{workspace}`, `{dd_id}`, `{slug}` etc. with actual values.
5. **Timeout matters for implementation.** Complex features need long timeouts
   (`runTimeoutSeconds: 43200`). The default is usually too short for full
   build + test cycles.
